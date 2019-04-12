-------------------------------------------------------------------------------
-- File       : Application.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top-Level Application Wrapper
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS ATCA LINK AGG DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.I2cPkg.all;
use work.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Application is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      ETH_CONFIG_G : EthConfigArray);
   port (
      -----------------------------
      --  Interfaces to Application
      -----------------------------
      -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
      axilClk         : in    sl;
      axilRst         : in    sl;
      axilReadMaster  : in    AxiLiteReadMasterType;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- Server Streaming Interface (axilClk domain)
      srvIbMasters    : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvIbSlaves     : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      srvObMasters    : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvObSlaves     : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Client Streaming Interface (axilClk domain)
      cltIbMasters    : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltIbSlaves     : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      cltObMasters    : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltObSlaves     : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Misc. Interface 
      ref156Clk       : in    sl;
      ref156Rst       : in    sl;
      ipmiBsi         : in    BsiBusType;
      --------------------- 
      --  Application Ports
      --------------------- 
      -- Jitter Cleaner PLL Ports
      fpgaToPllClkP   : out   sl;
      fpgaToPllClkN   : out   sl;
      pllToFpgaClkP   : in    sl;
      pllToFpgaClkN   : in    sl;
      -- Front Panel Clock/LED/TTL Ports
      smaClkP         : in    sl;
      smaClkN         : in    sl;
      ledRedL         : out   slv(1 downto 0)                                 := "11";
      ledBlueL        : out   slv(1 downto 0)                                 := "11";
      ledGreenL       : out   slv(1 downto 0)                                 := "11";
      fpTrigInL       : in    sl;
      fpBusyOut       : out   sl                                              := '0';
      fpSpareOut      : out   sl                                              := '0';
      fpSpareInL      : in    sl;
      -- Backplane Clocks Ports
      bpClkIn         : in    slv(5 downto 0);
      bpClkOut        : out   slv(5 downto 0)                                 := (others => '0');
      -- Front Panel QSFP+ Ports
      qsfpEthRefClkP  : in    sl;
      qsfpEthRefClkN  : in    sl;
      qsfpRef160ClkP  : in    sl;
      qsfpRef160ClkN  : in    sl;
      qsfpPllClkP     : in    sl;
      qsfpPllClkN     : in    sl;
      qsfpTxP         : out   Slv4Array(1 downto 0);
      qsfpTxN         : out   Slv4Array(1 downto 0);
      qsfpRxP         : in    Slv4Array(1 downto 0);
      qsfpRxN         : in    Slv4Array(1 downto 0);
      -- Front Panel SFP+ Ports
      sfpEthRefClkP   : in    sl;
      sfpEthRefClkN   : in    sl;
      sfpRef160ClkP   : in    sl;
      sfpRef160ClkN   : in    sl;
      sfpPllClkP      : in    sl;
      sfpPllClkN      : in    sl;
      sfpTxP          : out   slv(3 downto 0);
      sfpTxN          : out   slv(3 downto 0);
      sfpRxP          : in    slv(3 downto 0);
      sfpRxN          : in    slv(3 downto 0);
      -- RTM Ports (188 diff. pairs to RTM interface)
      dpmToRtmP       : inout Slv23Array(3 downto 0);
      dpmToRtmN       : inout Slv23Array(3 downto 0);
      rtmToDpmP       : inout Slv24Array(3 downto 0);
      rtmToDpmN       : inout Slv24Array(3 downto 0));
end Application;

architecture mapping of Application is

   constant VALID_THOLD_C : positive := (8192/8);  -- hold one jumbo frame in store/forward AXI stream FIFOs
   -- constant VALID_THOLD_C : positive := (1024/8);  -- hold one jumbo frame in store/forward AXI stream FIFOs

   constant I2C_CONFIG_C : I2cAxiLiteDevArray(5 downto 0) := (
      others         => MakeI2cAxiLiteDevType(
         i2cAddress  => "1010110",      -- DS32EV400
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian                   
         repeatStart => '1'));          -- Repeat Start                   

   constant NUM_AXIL_MASTERS_C : positive := 9;

   constant RX_PHY_INDEX_C : natural := 0;
   constant EMU_INDEX_C    : natural := 1;  -- [1:2]   
   constant I2C_INDEX_C    : natural := 3;  -- [3:8]

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, APP_AXIL_BASE_ADDR_C, 28, 24);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   constant RX_PHY_CONFIG_C : AxiLiteCrossbarMasterConfigArray(23 downto 0) := genAxiLiteConfig(24, AXIL_CONFIG_C(RX_PHY_INDEX_C).baseAddr, 24, 16);

   signal rxPhyWriteMasters : AxiLiteWriteMasterArray(23 downto 0);
   signal rxPhyWriteSlaves  : AxiLiteWriteSlaveArray(23 downto 0);
   signal rxPhyReadMasters  : AxiLiteReadMasterArray(23 downto 0);
   signal rxPhyReadSlaves   : AxiLiteReadSlaveArray(23 downto 0);

   signal mDataMasters : AxiStreamMasterArray(23 downto 0);
   signal mDataSlaves  : AxiStreamSlaveArray(23 downto 0);
   signal mDataMaster  : AxiStreamMasterType;
   signal mDataSlave   : AxiStreamSlaveType;

   signal mConfigMasters : AxiStreamMasterArray(23 downto 0);
   signal mConfigSlaves  : AxiStreamSlaveArray(23 downto 0);
   signal mConfigMaster  : AxiStreamMasterType;
   signal mConfigSlave   : AxiStreamSlaveType;

   signal sConfigMasters : AxiStreamMasterArray(23 downto 0);
   signal sConfigSlaves  : AxiStreamSlaveArray(23 downto 0);

   signal emuTimingMasters : AxiStreamMasterArray(23 downto 0);
   signal emuTimingSlaves  : AxiStreamSlaveArray(23 downto 0);

   signal dPortDataP : Slv4Array(23 downto 0);
   signal dPortDataN : Slv4Array(23 downto 0);
   signal dPortCmdP  : slv(23 downto 0);
   signal dPortCmdN  : slv(23 downto 0);

   signal i2cSelect : Slv6Array(3 downto 0);
   signal i2cScl    : slv(3 downto 0);
   signal i2cSda    : slv(3 downto 0);

   signal ref160Clock     : sl;
   signal ref160Clk     : sl;
   signal ref160Rst     : sl;
   
   signal iDelayCtrlRdy : sl;
   signal clk300MHz     : sl;
   signal rst300MHz     : sl;
   
   signal clk640MHz     : slv(23 downto 0);
   signal clk160MHz     : slv(23 downto 0);
   signal rst160MHz     : slv(23 downto 0);

   signal smaClk       : sl;
   signal pllToFpgaClk : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   -------------------------
   -- Terminate Unused Ports
   -------------------------
   U_smaClk : IBUFDS
      port map (
         I  => smaClkP,
         IB => smaClkN,
         O  => smaClk);

   U_pllToFpgaClk : IBUFDS
      port map (
         I  => pllToFpgaClkP,
         IB => pllToFpgaClkN,
         O  => pllToFpgaClk);

   U_fpgaToPllClk : entity work.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => '0',
         clkOutP => fpgaToPllClkP,
         clkOutN => fpgaToPllClkN);

   U_TERM_GTs : entity work.Gthe4ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 4)
      port map (
         refClk => ref156Clk,
         gtRxP  => sfpRxP,
         gtRxN  => sfpRxN,
         gtTxP  => sfpTxP,
         gtTxN  => sfpTxN);

   GEN_QSFP :
   for i in 1 downto 0 generate
      U_TERM_GTs : entity work.Gtye4ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 4)
         port map (
            refClk => ref156Clk,
            gtRxP  => qsfpRxP(i),
            gtRxN  => qsfpRxN(i),
            gtTxP  => qsfpTxP(i),
            gtTxN  => qsfpTxN(i));
   end generate GEN_QSFP;

   -----------
   -- Clocking
   -----------
   U_IBUFDS_GTE4 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => qsfpRef160ClkP,
         IB    => qsfpRef160ClkN,
         CEB   => '0',
         ODIV2 => ref160Clock,
         O     => open);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => ref160Clock,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => ref160Clk);

   U_ref160Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ref160Clk,
         rstIn  => ref156Rst,
         rstOut => ref160Rst);   
   
   GEN_PLL :
   for i in 3 downto 0 generate   
      U_ClkRst : entity work.AtlasRd53SelectioPll
         generic map (
            TPD_G        => TPD_G,
            SIMULATION_G => SIMULATION_G)
         port map (
            ref160Clk  => ref160Clk,
            ref160Rst  => ref160Rst,
            -- Timing Clock/Reset Interface
            clk640MHz  => clk640MHz(6*i+5 downto 6*i),
            clk160MHz  => clk160MHz(6*i+5 downto 6*i),
            rst160MHz  => rst160MHz(6*i+5 downto 6*i));
   end generate GEN_PLL;         

   U_MMCM : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 6.0,
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 300 MHz = 937.5 MHz/3.125
      port map(
         clkIn     => ref156Clk,
         rstIn     => ref156Rst,
         clkOut(0) => clk300MHz,
         rstOut(0) => rst300MHz);   
   
   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => clk300MHz,
         RST    => rst300MHz);
         
   --------------
   -- RTM Mapping
   --------------
   U_RTM_Mapping : entity work.AtlasRd53RtmMapping
      generic map (
         TPD_G => TPD_G)
      port map (
         -- mDP DATA/CMD Interface
         dPortDataP => dPortDataP,
         dPortDataN => dPortDataN,
         dPortCmdP  => dPortCmdP,
         dPortCmdN  => dPortCmdN,
         -- I2C Interface
         i2cSelect  => i2cSelect,
         i2cScl     => i2cScl,
         i2cSda     => i2cSda,
         -- RTM Ports (188 diff. pairs to RTM interface)
         dpmToRtmP  => dpmToRtmP,
         dpmToRtmN  => dpmToRtmN,
         rtmToDpmP  => rtmToDpmP,
         rtmToDpmN  => rtmToDpmN);

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
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

   U_RX_PHY_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 24,
         MASTERS_CONFIG_G   => RX_PHY_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMasters(RX_PHY_INDEX_C),
         sAxiWriteSlaves(0)  => axilWriteSlaves(RX_PHY_INDEX_C),
         sAxiReadMasters(0)  => axilReadMasters(RX_PHY_INDEX_C),
         sAxiReadSlaves(0)   => axilReadSlaves(RX_PHY_INDEX_C),
         mAxiWriteMasters    => rxPhyWriteMasters,
         mAxiWriteSlaves     => rxPhyWriteSlaves,
         mAxiReadMasters     => rxPhyReadMasters,
         mAxiReadSlaves      => rxPhyReadSlaves);

   NOT_SIM : if (SIMULATION_G = false) generate

      ----------------------
      -- AXI-Lite: Power I2C
      ----------------------
      GEN_I2C :
      for i in 3 downto 0 generate

         U_DS32EV400 : entity work.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               DEVICE_MAP_G   => I2C_CONFIG_C,
               I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
               AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
            port map (
               -- I2C Ports
               sel            => i2cSelect(i),
               scl            => i2cScl(i),
               sda            => i2cSda(i),
               -- AXI-Lite Register Interface
               axiReadMaster  => axilReadMasters(i+I2C_INDEX_C),
               axiReadSlave   => axilReadSlaves(i+I2C_INDEX_C),
               axiWriteMaster => axilWriteMasters(i+I2C_INDEX_C),
               axiWriteSlave  => axilWriteSlaves(i+I2C_INDEX_C),
               -- Clocks and Resets
               axiClk         => axilClk,
               axiRst         => axilRst);

      end generate GEN_I2C;

   end generate;

   ----------------------------------
   -- Emulation Timing/Trigger Module
   ----------------------------------
   U_EmuTiming : entity work.AtlasRd53EmuTiming
      generic map(
         TPD_G         => TPD_G,
         NUM_AXIS_G    => 24,
         ADDR_WIDTH_G  => 10,
         SYNTH_MODE_G  => "xpm",
         MEMORY_TYPE_G => "block")
      port map(
         -- AXI-Lite Interface (axilClk domain)
         axilClk          => axilClk,
         axilRst          => axilRst,
         axilReadMasters  => axilReadMasters(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilReadSlaves   => axilReadSlaves(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilWriteMasters => axilWriteMasters(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilWriteSlaves  => axilWriteSlaves(EMU_INDEX_C+1 downto EMU_INDEX_C),
         -- Streaming RD53 Trig Interface (clk160MHz domain)
         clk160MHz        => clk160MHz,
         rst160MHz        => rst160MHz,
         emuTimingMasters => emuTimingMasters,
         emuTimingSlaves  => emuTimingSlaves);

   ------------------------   
   -- Rd53 CMD/DATA Modules
   ------------------------   
   GEN_mDP :
   for i in 23 downto 0 generate
      U_Core : entity work.AtlasRd53Core
         generic map (
            TPD_G         => TPD_G,
            SIMULATION_G  => SIMULATION_G,
            AXIS_CONFIG_G => APP_AXIS_CONFIG_C,
            VALID_THOLD_G => VALID_THOLD_C,
            XIL_DEVICE_G  => XIL_DEVICE_C,
            SYNTH_MODE_G  => "xpm",
            MEMORY_TYPE_G => "ultra")
         port map (
            -- I/O Delay Interfaces
            iDelayCtrlRdy   => iDelayCtrlRdy,
            -- AXI-Lite Interface
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => rxPhyReadMasters(i),
            axilReadSlave   => rxPhyReadSlaves(i),
            axilWriteMaster => rxPhyWriteMasters(i),
            axilWriteSlave  => rxPhyWriteSlaves(i),
            -- Streaming EMU Trig Interface (clk160MHz domain)
            emuTimingMaster => emuTimingMasters(i),
            emuTimingSlave  => emuTimingSlaves(i),
            -- Streaming Data/Config Interface (axisClk domain)
            axisClk         => axilClk,
            axisRst         => axilRst,
            mDataMaster     => mDataMasters(i),
            mDataSlave      => mDataSlaves(i),
            sConfigMaster   => sConfigMasters(i),
            sConfigSlave    => sConfigSlaves(i),
            mConfigMaster   => mConfigMasters(i),
            mConfigSlave    => mConfigSlaves(i),
            -- Timing/Trigger Interface
            clk640MHz       => clk640MHz(i),
            clk160MHz       => clk160MHz(i),
            rst160MHz       => rst160MHz(i),
            -- RD53 ASIC Serial Ports
            dPortDataP      => dPortDataP(i),
            dPortDataN      => dPortDataN(i),
            dPortCmdP       => dPortCmdP(i),
            dPortCmdN       => dPortCmdN(i));
   end generate GEN_mDP;

   U_MuxConfig : entity work.AxiStreamMux
      generic map (
         TPD_G          => TPD_G,
         NUM_SLAVES_G   => 24,
         ILEAVE_EN_G    => true,
         ILEAVE_REARB_G => VALID_THOLD_C,
         PIPE_STAGES_G  => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Slaves
         sAxisMasters => mConfigMasters,
         sAxisSlaves  => mConfigSlaves,
         -- Master
         mAxisMaster  => mConfigMaster,
         mAxisSlave   => mConfigSlave);

   U_MuxData : entity work.AxiStreamMux
      generic map (
         TPD_G          => TPD_G,
         NUM_SLAVES_G   => 24,
         ILEAVE_EN_G    => true,
         ILEAVE_REARB_G => VALID_THOLD_C,
         PIPE_STAGES_G  => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Slaves
         sAxisMasters => mDataMasters,
         sAxisSlaves  => mDataSlaves,
         -- Master
         mAxisMaster  => mDataMaster,
         mAxisSlave   => mDataSlave);

   U_Mux : entity work.AxiStreamMux
      generic map (
         TPD_G                => TPD_G,
         NUM_SLAVES_G         => 2,
         TDEST_LOW_G          => 7,  -- mConfig.TDEST=[0x0:0x17], mData.TDEST=[0x80:0x97]
         ILEAVE_EN_G          => true,
         ILEAVE_ON_NOTVALID_G => false,
         ILEAVE_REARB_G       => VALID_THOLD_C,
         PIPE_STAGES_G        => 1)
      port map (
         -- Clock and reset
         axisClk         => axilClk,
         axisRst         => axilRst,
         -- Slaves
         sAxisMasters(0) => mConfigMaster,
         sAxisMasters(1) => mDataMaster,
         sAxisSlaves(0)  => mConfigSlave,
         sAxisSlaves(1)  => mDataSlave,
         -- Master
         mAxisMaster     => srvIbMasters(0)(0),
         mAxisSlave      => srvIbSlaves(0)(0));

   U_DeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => 24,
         PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Slave         
         sAxisMaster  => srvObMasters(0)(0),
         sAxisSlave   => srvObSlaves(0)(0),
         -- Masters
         mAxisMasters => sConfigMasters,
         mAxisSlaves  => sConfigSlaves);

end mapping;
