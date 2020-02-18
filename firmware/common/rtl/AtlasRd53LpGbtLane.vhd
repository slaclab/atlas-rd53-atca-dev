-------------------------------------------------------------------------------
-- File       : AtlasRd53LpGbtLane.vhd
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library atlas_rd53_fw_lib;

use work.lpgbtfpga_package.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53LpGbtLane is
   generic (
      TPD_G            : time     := 1 ns;
      AXIS_CONFIG_G    : AxiStreamConfigType;
      VALID_THOLD_G    : positive := 128;  -- Hold until enough to burst into the interleaving MUX
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- AXI-Lite interface (axilClk domain)
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;
      -- DMA interface (axilClk domain)
      dmaIbMaster      : out AxiStreamMasterType;
      dmaIbSlave       : in  AxiStreamSlaveType;
      dmaObMaster      : in  AxiStreamMasterType;
      dmaObSlave       : out AxiStreamSlaveType;
      -- Streaming Config/Trig Interface (clk160MHz domain)
      emuTimingMasters : in  AxiStreamMasterArray(5 downto 0);
      emuTimingSlaves  : out AxiStreamSlaveArray(5 downto 0);
      -- Clocks and Resets
      refClk320        : in  sl;  -- Using jitter clean FMC 320 MHz reference
      clk160MHz        : in  sl;
      rst160MHz        : in  sl;
      -- Status
      downlinkUp       : out sl;
      uplinkUp         : out sl;
      -- SFP Interface
      sfpTxP           : out sl;
      sfpTxN           : out sl;
      sfpRxP           : in  sl;
      sfpRxN           : in  sl);
end AtlasRd53LpGbtLane;

architecture rtl of AtlasRd53LpGbtLane is

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

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_ELINK_C-1 downto 0) := genAxiLiteConfig(NUM_ELINK_C, AXIL_BASE_ADDR_G, 20, 16);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_ELINK_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_ELINK_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_ELINK_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_ELINK_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

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
   signal donwlinkClk      : sl;
   signal downlinkRst      : sl;
   signal downlinkClkEn    : sl;

   signal uplinkUserData : slv(229 downto 0) := (others => '0');
   signal uplinkEcData   : slv(1 downto 0)   := (others => '0');
   signal uplinkIcData   : slv(1 downto 0)   := (others => '0');
   signal uplinkReady    : sl;
   signal uplinkClk      : sl;
   signal uplinkRst      : sl;
   signal uplinkClkEn    : sl;

   signal rxAligned : Slv4Array(NUM_ELINK_C-1 downto 0) := (others => x"0");
   signal rxBitSlip : Slv4Array(NUM_ELINK_C-1 downto 0) := (others => x"0");
   signal rxValid   : Slv4Array(NUM_ELINK_C-1 downto 0) := (others => x"0");
   signal rxHeader  : Slv2Array(NUM_ELINK_C-1 downto 0);
   signal rxData    : Slv64Array(NUM_ELINK_C-1 downto 0);

   signal unscramblerValid : Slv4Array(NUM_ELINK_C-1 downto 0) := (others => x"0");
   signal rawHeader        : Slv2Array(NUM_ELINK_C-1 downto 0);
   signal rawData          : Slv64Array(NUM_ELINK_C-1 downto 0);

   signal valid  : Slv4Array(NUM_ELINK_C-1 downto 0) := (others => x"0");
   signal header : Slv2Array(NUM_ELINK_C-1 downto 0);
   signal data   : Slv64Array(NUM_ELINK_C-1 downto 0);

   signal batchSize    : Slv16Array(NUM_ELINK_C-1 downto 0);
   signal timerConfig  : Slv16Array(NUM_ELINK_C-1 downto 0);
   signal chBond       : slv(NUM_ELINK_C-1 downto 0);
   signal wrdSent      : slv(NUM_ELINK_C-1 downto 0);
   signal singleHdrDet : slv(NUM_ELINK_C-1 downto 0);
   signal doubleHdrDet : slv(NUM_ELINK_C-1 downto 0);
   signal singleHitDet : slv(NUM_ELINK_C-1 downto 0);
   signal doubleHitDet : slv(NUM_ELINK_C-1 downto 0);
   signal cmdBusy      : slv(NUM_ELINK_C-1 downto 0);
   signal linkUp       : Slv4Array(NUM_ELINK_C-1 downto 0);
   signal hdrErrDet    : Slv4Array(NUM_ELINK_C-1 downto 0);

   signal pwrUpRst          : sl;
   signal downlinkReadySync : sl;
   signal uplinkReadySync   : sl;

begin

   downlinkUp <= downlinkReady;
   uplinkUp   <= uplinkReady;

   ---------------------------
   -- Generate the downlinkRst
   ---------------------------
   U_downlinkRst : entity surf.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => axilRst,
         clk    => donwlinkClk,
         rstOut => downlinkRst);

   U_downlinkReadySync : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk160MHz,
         dataIn  => downlinkReady,
         dataOut => downlinkReadySync);

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_ELINK_C,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   -------------------------
   -- Control/Monitor Module
   -------------------------
   GEN_CTRL_STATUS :
   for i in NUM_ELINK_C-1 downto 0 generate

      U_Ctrl : entity atlas_rd53_fw_lib.AtlasRd53Ctrl
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Monitoring Interface (clk160MHz domain)
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            autoReadReg     => (others => (others => '0')),
            dataDrop        => dataCtrl(i).overflow,
            configDrop      => '0',
            chBond          => chBond(i),
            wrdSent         => wrdSent(i),
            singleHdrDet    => singleHdrDet(i),
            doubleHdrDet    => doubleHdrDet(i),
            singleHitDet    => singleHitDet(i),
            doubleHitDet    => doubleHitDet(i),
            dlyCfg          => (others => (others => '0')),
            hdrErrDet       => hdrErrDet(i),
            linkUp          => linkUp(i),
            cmdBusy         => cmdBusy(i),
            downlinkReady   => downlinkReadySync,
            uplinkReady     => uplinkReadySync,
            bitSlip         => rxBitSlip(i),
            enable          => open,
            selectRate      => open,
            invData         => open,
            invCmd          => open,
            dlyCmd          => open,
            rxPhyXbar       => open,
            debugStream     => open,
            enUsrDlyCfg     => open,
            usrDlyCfg       => open,
            eyescanCfg      => open,
            lockingCntCfg   => open,
            pllRst          => open,
            localRst        => open,
            batchSize       => batchSize(i),
            timerConfig     => timerConfig(i),
            -- AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

   end generate GEN_CTRL_STATUS;

   ---------------------------------------------------------------------
   -- Demux the DMA outbound stream into different steam CMD AXI Streams
   ---------------------------------------------------------------------
   U_DeMux : entity surf.AxiStreamDeMux
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

      U_Cmd : entity atlas_rd53_fw_lib.AtlasRd53TxCmdWrapper
         generic map (
            TPD_G         => TPD_G,
            AXIS_CONFIG_G => AXIS_CONFIG_G)
         port map (
            -- Streaming EMU Trig Interface (clk160MHz domain)
            emuTimingMaster => emuTimingMasters(i),
            emuTimingSlave  => emuTimingSlaves(i),
            -- Streaming Config Interface (axisClk domain)
            axisClk         => axilClk,
            axisRst         => axilRst,
            sConfigMaster   => dmaObMasters(i),
            sConfigSlave    => dmaObSlaves(i),
            -- Timing Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- Command Serial Interface (clk160MHz domain)
            cmdBusy         => cmdBusy(i),
            cmdOut          => cmd(i));

      U_Gearbox_Cmd : entity surf.AsyncGearbox
         generic map (
            TPD_G                => TPD_G,
            SLAVE_WIDTH_G        => 1,
            MASTER_WIDTH_G       => 4,
            -- Pipelining generics
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 0,
            -- Async FIFO generics
            FIFO_MEMORY_TYPE_G   => "distributed",
            FIFO_ADDR_WIDTH_G    => 5)
         port map (
            -- Slave Interface
            slaveClk     => clk160MHz,
            slaveRst     => rst160MHz,
            slaveData(0) => cmd(i),
            slaveValid   => downlinkReadySync,
            slaveReady   => open,
            -- Master Interface
            masterClk    => donwlinkClk,
            masterRst    => downlinkRst,
            masterData   => downlinkUserData((i*4)+3 downto i*4),
            masterValid  => open,
            masterReady  => downlinkClkEn);

   end generate GEN_CMD;

   -------------
   -- LpGBT FPGA
   -------------
   lpgbtFpga_top_inst : entity work.LpGbtFpga10g24
      port map (
         -- Down link
         donwlinkClk_o       => donwlinkClk,    -- 40 MHz
         downlinkClkEn_o     => downlinkClkEn,  -- 40 MHz strobe
         downlinkRst_i       => pwrUpRst,       -- ASYNC RST
         downlinkUserData_i  => downlinkUserData,
         downlinkEcData_i    => downlinkEcData,
         downlinkIcData_i    => downlinkIcData,
         downlinkReady_o     => downlinkReady,
         -- Up link
         uplinkClk_o         => uplinkClk,      -- 40 MHz
         uplinkClkEn_o       => uplinkClkEn,    -- 40 MHz strobe
         uplinkRst_i         => pwrUpRst,       -- ASYNC RST
         uplinkUserData_o    => uplinkUserData,
         uplinkEcData_o      => uplinkEcData,
         uplinkIcData_o      => uplinkIcData,
         uplinkReady_o       => uplinkReady,
         -- MGT
         clk_refclk_i        => refClk320,
         clk_mgtfreedrpclk_i => axilClk,
         mgt_rxn_i           => sfpRxN,
         mgt_rxp_i           => sfpRxP,
         mgt_txn_o           => sfpTxN,
         mgt_txp_o           => sfpTxP);

   U_pwrUpRst : entity surf.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => rst160MHz,
         clk    => axilClk,
         rstOut => pwrUpRst);

   -------------------------
   -- Generate the uplinkRst
   -------------------------
   U_uplinkRst : entity surf.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => axilRst,
         clk    => uplinkClk,
         rstOut => uplinkRst);

   U_uplinkReadySync : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk160MHz,
         dataIn  => uplinkReady,
         dataOut => uplinkReadySync);

   -------------------------
   -- DATA Generation Module
   -------------------------
   GEN_DATA :
   for i in NUM_ELINK_C-1 downto 0 generate

      U_Gearbox_1280Mbps : entity surf.AsyncGearbox
         generic map (
            TPD_G                => TPD_G,
            SLAVE_WIDTH_G        => 32,
            MASTER_WIDTH_G       => 66,
            -- Pipelining generics
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 0,
            -- Async FIFO generics
            FIFO_MEMORY_TYPE_G   => "distributed",
            FIFO_ADDR_WIDTH_G    => 5)
         port map (
            slip                    => rxBitSlip(i)(0),
            -- Slave Interface
            slaveClk                => uplinkClk,
            slaveRst                => uplinkRst,
            slaveData(31 downto 0)  => uplinkUserData((i*32)+31 downto i*32),
            slaveValid              => uplinkClkEn,
            slaveReady              => open,
            -- Master Interface
            masterClk               => clk160MHz,
            masterRst               => rst160MHz,
            masterData(1 downto 0)  => rxHeader(i),
            masterData(65 downto 2) => rxData(i),
            masterValid             => rxValid(i)(0),
            masterReady             => '1');

      ------------------
      -- Gearbox aligner
      ------------------
      U_GearboxAligner : entity atlas_rd53_fw_lib.AuroraRxGearboxAligner
         generic map (
            TPD_G => TPD_G)
         port map (
            clk           => clk160MHz,
            rst           => rst160MHz,
            rxHeader      => rxHeader(i),
            rxHeaderValid => rxValid(i)(0),
            bitSlip       => rxBitSlip(i)(0),
            hdrErrDet     => hdrErrDet(i)(0),
            locked        => rxAligned(i)(0));

      ---------------------------------
      -- Unscramble the data for 64b66b
      ---------------------------------
      unscramblerValid(i)(0) <= rxAligned(i)(0) and rxValid(i)(0);
      U_Descrambler : entity surf.Scrambler
         generic map (
            TPD_G            => TPD_G,
            DIRECTION_G      => "DESCRAMBLER",
            DATA_WIDTH_G     => 64,
            SIDEBAND_WIDTH_G => 2,
            TAPS_G           => SCRAMBLER_TAPS_C)
         port map (
            clk            => clk160MHz,
            rst            => rst160MHz,
            -- Inbound Interface
            inputValid     => unscramblerValid(i)(0),
            inputData      => rxData(i),
            inputSideband  => rxHeader(i),
            -- Outbound Interface
            outputValid    => valid(i)(0),
            outputData     => rawData(i),
            outputSideband => rawHeader(i));

      data(i)   <= bitReverse(rawData(i));
      header(i) <= bitReverse(rawHeader(i));

      ------------------
      -- Gearbox aligner
      ------------------
      U_AuroraRxCh : entity atlas_rd53_fw_lib.AuroraRxChannelFsm
         generic map (
            TPD_G => TPD_G)
         port map (
            -- Timing Interface
            clk160MHz          => clk160MHz,
            rst160MHz          => rst160MHz,
            -- Parallel Interface
            rxLinkUp           => rxAligned(i),
            valid              => valid(i),
            header(0)          => header(i),
            header(3 downto 1) => (others => (others => '0')),
            data(0)            => data(i),
            data(3 downto 1)   => (others => (others => '0')),
            -- Status/Control Interface
            enable             => x"1",  -- Only using 1 of the 4 links per chip
            linkUp             => linkUp(i),
            chBond             => chBond(i),
            wrdSent            => wrdSent(i),
            singleHdrDet       => singleHdrDet(i),
            doubleHdrDet       => doubleHdrDet(i),
            singleHitDet       => singleHitDet(i),
            doubleHitDet       => doubleHitDet(i),
            -- AutoReg and Read back Interface
            dataMaster         => dataMasters(i));

      ---------------------         
      -- Outbound Data FIFO
      ---------------------       
      U_DataFifo : entity surf.AxiStreamFifoV2
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
            sAxisClk    => clk160MHz,
            sAxisRst    => rst160MHz,
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
      U_DataBatcher : entity atlas_rd53_fw_lib.AtlasRd53RxDataBatcher
         generic map (
            TPD_G         => TPD_G,
            AXIS_CONFIG_G => INT_AXIS_CONFIG_C)
         port map (
            -- Clock and Reset
            axisClk     => axilClk,
            axisRst     => axilRst,
            -- Configuration/Status Interface
            batchSize   => batchSize(i),
            timerConfig => timerConfig(i),
            -- AXI Streaming Interface
            sDataMaster => txDataMasters(i),
            sDataSlave  => txDataSlaves(i),
            mDataMaster => batcherMasters(i),
            mDataSlave  => batcherSlaves(i));

      --------------------
      -- Resize/Burst FIFO
      --------------------
      Burst_FIFO : entity surf.AxiStreamFifoV2
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
            FIFO_ADDR_WIDTH_G   => 10,
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
   U_MuxData : entity surf.AxiStreamMux
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
