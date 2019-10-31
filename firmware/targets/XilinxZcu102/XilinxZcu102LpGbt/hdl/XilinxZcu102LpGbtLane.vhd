-------------------------------------------------------------------------------
-- File       : XilinxZcu102LpGbtLane.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top Level Firmware Target
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 FMC DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS RD53 FMC DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.lpgbtfpga_package.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxZcu102LpGbtLane is
   generic (
      TPD_G            : time     := 1 ns;
      AXIS_CONFIG_G    : AxiStreamConfigType;
      VALID_THOLD_G    : positive := 128;  -- Hold until enough to burst into the interleaving MUX
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- AXI-Lite interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;
      -- DMA interface (axilClk domain)
      dmaIbMaster     : out AxiStreamMasterType;
      dmaIbSlave      : in  AxiStreamSlaveType;
      dmaObMaster     : in  AxiStreamMasterType;
      dmaObSlave      : out AxiStreamSlaveType;
      -- SFP Interface
      gtRefClk320     : in  sl;  -- Using jitter clean FMC 320 MHz reference
      sfpTxP          : out sl;
      sfpTxN          : out sl;
      sfpRxP          : in  sl;
      sfpRxN          : in  sl);
end XilinxZcu102LpGbtLane;

architecture rtl of XilinxZcu102LpGbtLane is

   ------------------------------------------------------------------------------------------------------
   -- Scrambler Taps: G(x) = 1 + x^39 + x^58 (Equation 5-1)
   -- https://www.xilinx.com/support/documentation/ip_documentation/aurora_64b66b_protocol_spec_sp011.pdf
   ------------------------------------------------------------------------------------------------------
   constant SCRAMBLER_TAPS_C : IntegerArray := (0 => 39, 1 => 58);

   constant NUM_ELINK_C : natural := 6;

   constant INT_AXIS_CONFIG_C : AxiStreamConfigType :=
      ssiAxiStreamConfig(
         dataBytes => 8,                -- 64-bit width
         tKeepMode => TKEEP_COMP_C,
         tUserMode => TUSER_FIRST_LAST_C,
         tDestBits => 0,
         tUserBits => 2);

   signal dmaObMasters : AxiStreamMasterArray(NUM_ELINK_C-1 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(NUM_ELINK_C-1 downto 0);

   signal dataMasters : AxiStreamMasterArray(NUM_ELINK_C-1 downto 0);
   signal dataCtrl    : AxiStreamCtrlArray(NUM_ELINK_C-1 downto 0);

   signal txDataMasters : AxiStreamMasterArray(NUM_ELINK_C-1 downto 0);
   signal txDataSlaves  : AxiStreamSlaveArray(NUM_ELINK_C-1 downto 0);

   signal batcherMasters : AxiStreamMasterArray(NUM_ELINK_C-1 downto 0);
   signal batcherSlaves  : AxiStreamSlaveArray(NUM_ELINK_C-1 downto 0);

   signal dmaIbMasters : AxiStreamMasterArray(NUM_ELINK_C-1 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(NUM_ELINK_C-1 downto 0);

   signal cmd : slv(NUM_ELINK_C-1 downto 0);

   signal downlinkUserData : slv(31 downto 0) := (others => '0');
   signal downlinkEcData   : slv(1 downto 0)  := (others => '0');
   signal downlinkIcData   : slv(1 downto 0)  := (others => '0');
   signal downlinkReady    : sl;

   signal uplinkUserData : slv(229 downto 0) := (others => '0');
   signal uplinkEcData   : slv(1 downto 0)   := (others => '0');
   signal uplinkIcData   : slv(1 downto 0)   := (others => '0');
   signal uplinkReady    : sl;

   signal rxAligned : slv(NUM_ELINK_C-1 downto 0);
   signal rxBitSlip : slv(NUM_ELINK_C-1 downto 0);
   signal rxValid   : slv(NUM_ELINK_C-1 downto 0);
   signal rxHeader  : Slv2Array(NUM_ELINK_C-1 downto 0);
   signal rxData    : Slv64Array(NUM_ELINK_C-1 downto 0);

   signal unscramblerValid : slv(NUM_ELINK_C-1 downto 0);
   signal rawHeader        : Slv2Array(NUM_ELINK_C-1 downto 0);
   signal rawData          : Slv64Array(NUM_ELINK_C-1 downto 0);

   signal valid  : slv(NUM_ELINK_C-1 downto 0);
   signal header : Slv2Array(NUM_ELINK_C-1 downto 0);
   signal data   : Slv64Array(NUM_ELINK_C-1 downto 0);

   signal clk320   : sl;
   signal rst320   : sl;
   signal clkEn40  : sl;
   signal clkEn160 : sl;

   signal batchSize   : slv(15 downto 0) := (others => '0');
   signal timerConfig : slv(15 downto 0) := (others => '0');

begin

   U_rst320 : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => axilRst,
         clk    => clk320,
         rstOut => rst320);

   process(clk320)
   begin
      if rising_edge(clk320) then
         if rst320 = '1' then
            clkEn160 <= '0' after TPD_G;
         else
            if (clkEn160 = '0') or (clkEn40 = '1') then
               clkEn160 <= '1' after TPD_G;
            else
               clkEn160 <= '0' after TPD_G;
            end if;
         end if;
      end if;
   end process;

   ---------------------------------------------------------------------
   -- Demux the DMA outbound stream into different steam CMD AXI Streams
   ---------------------------------------------------------------------
   U_DeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => NUM_ELINK_C,
         PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Slave         
         sAxisMaster  => dmaObMaster,
         sAxisSlave   => dmaObSlave,
         -- Masters
         mAxisMasters => dmaObMasters,
         mAxisSlaves  => dmaObSlaves);

   ------------------------
   -- CMD Generation Module
   ------------------------
   GEN_CMD :
   for i in NUM_ELINK_C-1 downto 0 generate

      U_Cmd : entity work.AtlasRd53TxCmdWrapper
         generic map (
            TPD_G         => TPD_G,
            AXIS_CONFIG_G => AXIS_CONFIG_G)
         port map (
            -- Streaming EMU Trig Interface (clk160MHz domain)
            emuTimingMaster => AXI_STREAM_MASTER_INIT_C,
            emuTimingSlave  => open,
            -- Streaming Config Interface (axisClk domain)
            axisClk         => axilClk,
            axisRst         => axilRst,
            sConfigMaster   => dmaObMasters(i),
            sConfigSlave    => dmaObSlaves(i),
            -- Timing Interface
            clkEn160MHz     => clkEn160,
            clk160MHz       => clk320,
            rst160MHz       => rst320,
            -- Command Serial Interface (clk160MHz domain)
            cmdOut          => cmd(i));

      U_Gearbox_Cmd : entity work.Gearbox
         generic map (
            TPD_G          => TPD_G,
            SLAVE_WIDTH_G  => 1,
            MASTER_WIDTH_G => 4)
         port map (
            clk          => clk320,
            rst          => rst320,
            -- Slave Interface
            slaveData(0) => cmd(i),
            slaveValid   => clkEn160,
            slaveReady   => open,
            -- Master Interface
            masterData   => downlinkUserData((i*4)+3 downto i*4),
            masterValid  => open,
            masterReady  => clkEn40);

   end generate GEN_CMD;

   -------------
   -- LpGBT FPGA
   -------------
   lpgbtFpga_top_inst : entity work.LpGbtFpga10g24
      generic map (
         FEC => FEC12)
      port map (
         -- Clocks
         donwlinkClk_i       => clk320,
         downlinkClkEn_i     => clkEn40,
         uplinkClk_o         => clk320,
         uplinkClkEn_o       => clkEn40,
         downlinkRst_i       => rst320,
         uplinkRst_i         => rst320,
         -- Down link
         downlinkUserData_i  => downlinkUserData,
         downlinkEcData_i    => downlinkEcData,
         downlinkIcData_i    => downlinkIcData,
         downlinkReady_o     => downlinkReady,
         -- Up link
         uplinkUserData_o    => uplinkUserData,
         uplinkEcData_o      => uplinkEcData,
         uplinkIcData_o      => uplinkIcData,
         uplinkReady_o       => uplinkReady,
         -- MGT
         clk_mgtrefclk_i     => gtRefClk320,
         clk_mgtfreedrpclk_i => axilClk,
         mgt_rxn_i           => sfpRxN,
         mgt_rxp_i           => sfpRxP,
         mgt_txn_o           => sfpTxN,
         mgt_txp_o           => sfpTxP);

   -------------------------
   -- DATA Generation Module
   -------------------------
   GEN_DATA :
   for i in NUM_ELINK_C-1 downto 0 generate

      U_Gearbox_1280Mbps : entity work.Gearbox
         generic map (
            TPD_G          => TPD_G,
            SLAVE_WIDTH_G  => 32,
            MASTER_WIDTH_G => 66)
         port map (
            clk                     => clk320,
            rst                     => rst320,
            slip                    => rxBitSlip(i),
            -- Slave Interface
            slaveData(31 downto 0)  => uplinkUserData((i*32)+31 downto i*32),
            slaveValid              => clkEn40,
            slaveReady              => open,
            -- Master Interface
            masterData(1 downto 0)  => rxHeader(i),
            masterData(65 downto 2) => rxData(i),
            masterValid             => rxValid(i),
            masterReady             => '1');

      ------------------
      -- Gearbox aligner
      ------------------
      U_GearboxAligner : entity work.AuroraRxGearboxAligner
         generic map (
            TPD_G => TPD_G)
         port map (
            clk           => clk320,
            rst           => rst320,
            rxHeader      => rxHeader(i),
            rxHeaderValid => rxValid(i),
            bitSlip       => rxBitSlip(i),
            locked        => rxAligned(i));

      ---------------------------------
      -- Unscramble the data for 64b66b
      ---------------------------------
      unscramblerValid(i) <= rxAligned(i) and rxValid(i);
      U_Descrambler : entity work.Scrambler
         generic map (
            TPD_G            => TPD_G,
            DIRECTION_G      => "DESCRAMBLER",
            DATA_WIDTH_G     => 64,
            SIDEBAND_WIDTH_G => 2,
            TAPS_G           => SCRAMBLER_TAPS_C)
         port map (
            clk            => clk320,
            rst            => rst320,
            -- Inbound Interface
            inputValid     => unscramblerValid(i),
            inputData      => rxData(i),
            inputSideband  => rxHeader(i),
            -- Outbound Interface
            outputValid    => valid(i),
            outputData     => rawData(i),
            outputSideband => rawHeader(i));

      data(i)   <= bitReverse(rawData(i));
      header(i) <= bitReverse(rawHeader(i));

      ------------------
      -- Gearbox aligner
      ------------------
      U_AuroraRxCh : entity work.AuroraRxChannelFsm
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Timing Interface
            clk160MHz            => clk320,
            rst160MHz            => rst320,
            -- Parallel Interface
            rxLinkUp(0)          => rxAligned(i),
            rxLinkUp(3 downto 1) => (others => '0'),
            valid(0)             => valid(i),
            valid(3 downto 1)    => (others => '0'),
            header(0)            => header(i),
            header(3 downto 1)   => (others => (others => '0')),
            data(0)              => data(i),
            data(3 downto 1)     => (others => (others => '0')),
            -- Status/Control Interface
            enable               => x"1",  -- Only using 1 of the 4 links per chip
            -- AutoReg and Read back Interface
            dataMaster           => dataMasters(i));

      ---------------------         
      -- Outbound Data FIFO
      ---------------------       
      U_DataFifo : entity work.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            SLAVE_READY_EN_G    => false,
            VALID_THOLD_G       => 1,
            -- FIFO configurations
            SYNTH_MODE_G        => "xpm",
            MEMORY_TYPE_G       => "block",
            GEN_SYNC_FIFO_G     => false,
            FIFO_ADDR_WIDTH_G   => 9,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => INT_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => INT_AXIS_CONFIG_C)
         port map (
            -- Slave Port
            sAxisClk    => clk320,
            sAxisRst    => rst320,
            sAxisMaster => dataMasters(i),
            sAxisCtrl   => dataCtrl(i),
            -- Master Port
            mAxisClk    => axilClk,
            mAxisRst    => axilRst,
            mAxisMaster => txDataMasters(i),
            mAxisSlave  => txDataSlaves(i));

      ---------------------------------------------------------
      -- Batch Multiple 64-bit data words into large AXIS frame
      ---------------------------------------------------------
      U_DataBatcher : entity work.AtlasRd53RxDataBatcher
         generic map (
            TPD_G         => TPD_G,
            AXIS_CONFIG_G => INT_AXIS_CONFIG_C)
         port map (
            -- Clock and Reset
            axisClk     => axilClk,
            axisRst     => axilRst,
            -- Configuration/Status Interface
            batchSize   => batchSize,
            timerConfig => timerConfig,
            -- AXI Streaming Interface
            sDataMaster => txDataMasters(i),
            sDataSlave  => txDataSlaves(i),
            mDataMaster => batcherMasters(i),
            mDataSlave  => batcherSlaves(i));

      --------------------
      -- Resize/Burst FIFO
      --------------------
      Burst_FIFO : entity work.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => VALID_THOLD_G,
            VALID_BURST_MODE_G  => true,
            -- FIFO configurations
            SYNTH_MODE_G        => "xpm",
            MEMORY_TYPE_G       => "block",
            GEN_SYNC_FIFO_G     => true,
            FIFO_ADDR_WIDTH_G   => 9,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => INT_AXIS_CONFIG_C,
            MASTER_AXI_CONFIG_G => AXIS_CONFIG_G)
         port map (
            -- Slave Port
            sAxisClk    => axilClk,
            sAxisRst    => axilRst,
            sAxisMaster => batcherMasters(i),
            sAxisSlave  => batcherSlaves(i),
            -- Master Port
            mAxisClk    => axilClk,
            mAxisRst    => axilRst,
            mAxisMaster => dmaIbMasters(i),
            mAxisSlave  => dmaIbSlaves(i));

   end generate GEN_DATA;

   --------------------------------------------------------
   -- MUX the data AXI streams into the DMA outbound stream
   --------------------------------------------------------
   U_MuxData : entity work.AxiStreamMux
      generic map (
         TPD_G          => TPD_G,
         NUM_SLAVES_G   => NUM_ELINK_C,
         ILEAVE_EN_G    => true,
         ILEAVE_REARB_G => VALID_THOLD_G,
         PIPE_STAGES_G  => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Slaves
         sAxisMasters => dmaIbMasters,
         sAxisSlaves  => dmaIbSlaves,
         -- Master
         mAxisMaster  => dmaIbMaster,
         mAxisSlave   => dmaIbSlave);

end rtl;
