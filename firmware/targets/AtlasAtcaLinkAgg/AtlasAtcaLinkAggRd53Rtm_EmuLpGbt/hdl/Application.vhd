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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.I2cPkg.all;

library atlas_rd53_fw_lib;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Application is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
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
      -- mDP DATA/CMD Interface
      dPortDataP      : in    Slv4Array(23 downto 0);
      dPortDataN      : in    Slv4Array(23 downto 0);
      dPortCmdP       : out   slv(31 downto 0);
      dPortCmdN       : out   slv(31 downto 0);
      -- I2C Interface
      i2cScl          : inout slv(3 downto 0);
      i2cSda          : inout slv(3 downto 0);
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
      sfpRxN          : in    slv(3 downto 0));
end Application;

architecture mapping of Application is

   constant NUM_ELINKS_C : positive := 6*12;  -- (6 per lpGBT link) x (4 SFP links + 8 QSFP links)

   constant RX_RECCLK_INDEX_C : natural := 0;  -- Using SFP[0] for the recovered clock reference for jitter cleaner PLL

   impure function RxPhyToApp return Slv7Array is
      variable i      : natural;
      variable j      : natural;
      variable retVar : Slv7Array(127 downto 0);
   begin
      -- Uplink: PHY to Application Mapping
      for i in 0 to 3 loop
         for j in 0 to 5 loop
            -- APP.CH[i*6+j]  <--- PHY.CH[24*i+4*j+3]  = mDP.CH[i*6+j].RX[3]
            retVar(i*6+j) := toSlv((24*i+4*j+3), 7);
         end loop;
      end loop;
      for i in 24 to 127 loop
         -- APP.CH[i]  <--- Unused
         retVar(i) := toSlv(127, 7);
      end loop;
      return retVar;
   end function;
   constant RX_PHY_TO_APP_INIT_C : Slv7Array(127 downto 0) := RxPhyToApp;

   impure function TxAppToPhy return Slv7Array is
      variable i      : natural;
      variable retVar : Slv7Array(31 downto 0);
   begin
      for i in 0 to 31 loop
         retVar(i) := toSlv(i, 7);
      end loop;
      return retVar;
   end function;
   constant TX_APP_TO_PHY_INIT_C : Slv7Array(31 downto 0) := TxAppToPhy;

   constant I2C_CONFIG_C : I2cAxiLiteDevArray(0 to 2) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100000",      -- PCA9555
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'),           -- Repeat Start
      1              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100001",      -- PCA9555
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'),           -- Repeat Start
      2              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100010",      -- PCA9555
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'));          -- Repeat Start

   constant NUM_AXIL_MASTERS_C : positive := 11;

   constant I2C_INDEX_C          : natural := 0;  -- [0:1]
   constant RX_INDEX_C           : natural := 4;  -- [4:7]
   constant LP_GBT_INDEX_C       : natural := 8;
   constant RX_PHY_REMAP_INDEX_C : natural := 9;
   constant TX_PHY_REMAP_INDEX_C : natural := 10;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, APP_AXIL_BASE_ADDR_C, 28, 24);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal rxWriteMasters : AxiLiteWriteMasterArray((3*32)-1 downto 0);
   signal rxWriteSlaves  : AxiLiteWriteSlaveArray((3*32)-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal rxReadMasters  : AxiLiteReadMasterArray((3*32)-1 downto 0);
   signal rxReadSlaves   : AxiLiteReadSlaveArray((3*32)-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal lpgbtWriteMasters : AxiLiteWriteMasterArray(11 downto 0);
   signal lpgbtWriteSlaves  : AxiLiteWriteSlaveArray(11 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal lpgbtReadMasters  : AxiLiteReadMasterArray(11 downto 0);
   signal lpgbtReadSlaves   : AxiLiteReadSlaveArray(11 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal serDesData : Slv8Array(127 downto 0) := (others => (others => '0'));
   signal dlyLoad    : slv(127 downto 0)       := (others => '0');
   signal dlyCfg     : Slv9Array(127 downto 0) := (others => (others => '0'));

   signal cmd    : slv(127 downto 0) := (others => '0');
   signal invCmd : slv(127 downto 0) := (others => '0');
   signal dlyCmd : slv(127 downto 0) := (others => '0');

   signal rxLinkUp : slv(NUM_ELINKS_C-1 downto 0);

   signal ref160Clock : sl;
   signal ref160Clk   : sl;
   signal ref160Rst   : sl;

   signal clk160MHz : sl;
   signal rst160MHz : sl;

   signal smaClk : sl;
   signal drpClk : sl;

   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   signal sfpRef160Clk  : sl;
   signal qsfpRef160Clk : sl;
   signal qsfpPllClk    : sl;

   signal txWordClk160 : slv(11 downto 0);
   signal rxWordClk80  : slv(11 downto 0);
   signal txWordClk40  : sl;
   signal rxWordClk40  : sl;

   signal rxRecClk      : slv(11 downto 0);
   signal qplllock      : Slv2Array(2 downto 0);
   signal qplloutclk    : Slv2Array(2 downto 0);
   signal qplloutrefclk : Slv2Array(2 downto 0);
   signal qpllRst       : slv(11 downto 0);

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   -------------------------
   -- Terminate Unused Ports
   -------------------------
   U_smaClk : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => smaClkP,
         IB    => smaClkN,
         CEB   => '0',
         ODIV2 => smaClk,
         O     => open);

   NOT_SIM : if (SIMULATION_G = false) generate

      ----------------------
      -- AXI-Lite: Power I2C
      ----------------------
      GEN_I2C :
      for i in 3 downto 0 generate

         U_PCA9555 : entity surf.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               DEVICE_MAP_G   => I2C_CONFIG_C,
               I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
               AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
            port map (
               -- I2C Ports
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

   ---------------------------------------------------------------------------------
   -- External Reference clock (required for synchronizing to remote LpGBT receiver)
   ---------------------------------------------------------------------------------
   U_fpgaToPllClk : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => rxRecClk(RX_RECCLK_INDEX_C),  -- emulation LP-GBT recovered clock used as jitter cleaner reference
         clkOutP => fpgaToPllClkP,
         clkOutN => fpgaToPllClkN);

   ---------------------------------------
   -- 160 MHz Free-running Reference Clock
   ---------------------------------------
   U_SFP_refClk160 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => sfpRef160ClkP,
         IB    => sfpRef160ClkN,
         CEB   => '0',
         ODIV2 => open,
         O     => sfpRef160Clk);

   U_QSFP_refClk160 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => qsfpRef160ClkP,
         IB    => qsfpRef160ClkN,
         CEB   => '0',
         ODIV2 => open,
         O     => qsfpRef160Clk);

   ---------------
   -- GT DRP Clock
   ---------------
   U_drp_clk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)
      port map (
         I   => axilClk,                -- 156.25 MHz
         CE  => '1',
         CLR => '0',
         O   => drpClk);                -- 39.0625 MHz

   ------------------------
   -- LP-GBT QPLL Reference
   ------------------------
   U_EmuLpGbtQpll_0 : entity work.xlx_ku_mgt_10g24_emu_qpll
      generic map (
         TPD_G             => TPD_G,
         GT_CLK_SEL_G      => false,    -- false = gtClkP/N
         SELECT_GT_TYPE_G  => false,    -- false = GTH
         QPLL_REFCLK_SEL_G => "010")    -- 010: GTREFCLK1 selected
      port map (
         -- MGT Clock Port (320 MHz)
         gtClkP        => sfpPllClkP,
         gtClkN        => sfpPllClkN,
         -- Quad PLL Interface
         qplllock      => qplllock(0),
         qplloutclk    => qplloutclk(0),
         qplloutrefclk => qplloutrefclk(0),
         qpllRst       => qpllRst(RX_RECCLK_INDEX_C));

   U_EmuLpGbtQpll_1 : entity work.xlx_ku_mgt_10g24_emu_qpll
      generic map (
         TPD_G             => TPD_G,
         GT_CLK_SEL_G      => false,    -- false = gtClkP/N
         SELECT_GT_TYPE_G  => true,     -- true = GTY
         QPLL_REFCLK_SEL_G => "010")    -- 010: GTREFCLK1 selected
      port map (
         -- MGT Clock Port (320 MHz)
         gtClkP        => qsfpPllClkP,
         gtClkN        => qsfpPllClkN,
         gtClkOut      => qsfpPllClk,
         -- Quad PLL Interface
         qplllock      => qplllock(1),
         qplloutclk    => qplloutclk(1),
         qplloutrefclk => qplloutrefclk(1),
         qpllRst       => qpllRst(RX_RECCLK_INDEX_C));

   U_EmuLpGbtQpll_2 : entity work.xlx_ku_mgt_10g24_emu_qpll
      generic map (
         TPD_G             => TPD_G,
         GT_CLK_SEL_G      => true,     -- true = gtClkIn
         SELECT_GT_TYPE_G  => true,     -- true = GTY
         QPLL_REFCLK_SEL_G => "100")    -- 100: GTNORTHREFCLK1 selected
      port map (
         -- MGT Clock Port (320 MHz)
         gtClkIn       => qsfpPllClk,
         -- Quad PLL Interface
         qplllock      => qplllock(2),
         qplloutclk    => qplloutclk(2),
         qplloutrefclk => qplloutrefclk(2),
         qpllRst       => qpllRst(RX_RECCLK_INDEX_C));

   U_tx_wordclk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)
      port map (
         I   => txWordClk160(RX_RECCLK_INDEX_C),
         CE  => '1',
         CLR => '0',
         O   => txWordClk40);

   U_rx_wordclk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 2)
      port map (
         I   => rxWordClk80(RX_RECCLK_INDEX_C),
         CE  => '1',
         CLR => '0',
         O   => rxWordClk40);

   --------------------------
   -- 160 MHz Reference Clock
   --------------------------
   U_IBUFDS_ref160Clk : IBUFDS
      port map (
         I  => pllToFpgaClkP,
         IB => pllToFpgaClkN,
         O  => ref160Clock);

   U_BUFG_ref160Clk : BUFG
      port map (
         I => ref160Clock,
         O => ref160Clk);

   U_ref160Rst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ref160Clk,
         rstIn  => axilRst,
         rstOut => ref160Rst);

   --------------------------
   -- Reference 300 MHz clock
   --------------------------
   U_MMCM : entity surf.ClockManagerUltraScale
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
         clkIn     => axilClk,
         rstIn     => axilRst,
         clkOut(0) => refClk300MHz,
         rstOut(0) => refRst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
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

   U_XBAR_LP_GBT : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 12,
         MASTERS_CONFIG_G   => genAxiLiteConfig(12, AXIL_CONFIG_C(LP_GBT_INDEX_C).baseAddr, 24, 20))
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMasters(LP_GBT_INDEX_C),
         sAxiWriteSlaves(0)  => axilWriteSlaves(LP_GBT_INDEX_C),
         sAxiReadMasters(0)  => axilReadMasters(LP_GBT_INDEX_C),
         sAxiReadSlaves(0)   => axilReadSlaves(LP_GBT_INDEX_C),
         mAxiWriteMasters    => lpgbtWriteMasters,
         mAxiWriteSlaves     => lpgbtWriteSlaves,
         mAxiReadMasters     => lpgbtReadMasters,
         mAxiReadSlaves      => lpgbtReadSlaves);

   GEN_RX_XBAR :
   for i in 2 downto 0 generate

      U_XBAR : entity surf.AxiLiteCrossbar
         generic map (
            TPD_G              => TPD_G,
            NUM_SLAVE_SLOTS_G  => 1,
            NUM_MASTER_SLOTS_G => 32,
            MASTERS_CONFIG_G   => genAxiLiteConfig(32, AXIL_CONFIG_C(RX_INDEX_C+i).baseAddr, 13, 8))
         port map (
            axiClk              => axilClk,
            axiClkRst           => axilRst,
            sAxiWriteMasters(0) => axilWriteMasters(RX_INDEX_C+i),
            sAxiWriteSlaves(0)  => axilWriteSlaves(RX_INDEX_C+i),
            sAxiReadMasters(0)  => axilReadMasters(RX_INDEX_C+i),
            sAxiReadSlaves(0)   => axilReadSlaves(RX_INDEX_C+i),
            mAxiWriteMasters    => rxWriteMasters(i*32+31 downto i*32),
            mAxiWriteSlaves     => rxWriteSlaves(i*32+31 downto i*32),
            mAxiReadMasters     => rxReadMasters(i*32+31 downto i*32),
            mAxiReadSlaves      => rxReadSlaves(i*32+31 downto i*32));

   end generate GEN_RX_XBAR;

   ------------------------------
   -- High Speed SelectIO Modules
   ------------------------------
   U_Selectio : entity work.AtlasRd53HsSelectioWrapper
      generic map(
         TPD_G                => TPD_G,
         SIMULATION_G         => SIMULATION_G,
         RX_PHY_TO_APP_INIT_G => RX_PHY_TO_APP_INIT_C)
      port map (
         ref160Clk       => ref160Clk,
         ref160Rst       => ref160Rst,
         -- Deserialization Interface
         serDesData      => serDesData,
         dlyLoad         => dlyLoad,
         dlyCfg          => dlyCfg,
         iDelayCtrlRdy   => iDelayCtrlRdy,
         -- mDP DATA Interface
         dPortDataP      => dPortDataP,
         dPortDataN      => dPortDataN,
         -- Timing Clock/Reset Interface
         clk160MHz       => clk160MHz,
         rst160MHz       => rst160MHz,
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(RX_PHY_REMAP_INDEX_C),
         axilReadSlave   => axilReadSlaves(RX_PHY_REMAP_INDEX_C),
         axilWriteMaster => axilWriteMasters(RX_PHY_REMAP_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(RX_PHY_REMAP_INDEX_C));

   --------------------------
   -- App-to-Phy CMD Crossbar
   --------------------------
   U_CmdXbar : entity work.CmdPhyMux
      generic map(
         TPD_G                => TPD_G,
         TX_APP_TO_PHY_INIT_G => TX_APP_TO_PHY_INIT_C)
      port map (
         -- mDP CMD Interface
         cmdOutP         => dPortCmdP,
         cmdOutN         => dPortCmdN,
         -- Timing Clock/Reset Interface
         clk160MHz       => clk160MHz,
         rst160MHz       => rst160MHz,
         cmd             => cmd,
         invCmd          => invCmd,
         dlyCmd          => dlyCmd,
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(TX_PHY_REMAP_INDEX_C),
         axilReadSlave   => axilReadSlaves(TX_PHY_REMAP_INDEX_C),
         axilWriteMaster => axilWriteMasters(TX_PHY_REMAP_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(TX_PHY_REMAP_INDEX_C));

   ----------------------------------------------------------
   -- Using AuroraRxLane for this is IDELAY alignment feature
   ----------------------------------------------------------
   GEN_LANE : for i in NUM_ELINKS_C-1 downto 0 generate
      U_Rx : entity work.AuroraRxLaneWrapper
         generic map (
            TPD_G        => TPD_G,
            SIMULATION_G => SIMULATION_G)
         port map (
            -- RD53 ASIC Serial Interface  (clk160MHz domain)
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            serDesData      => serDesData(i),
            dlyLoad         => dlyLoad(i),
            dlyCfg          => dlyCfg(i),
            rxLinkUp        => rxLinkUp(i),
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => rxReadMasters(i),
            axilReadSlave   => rxReadSlaves(i),
            axilWriteMaster => rxWriteMasters(i),
            axilWriteSlave  => rxWriteSlaves(i));
   end generate GEN_LANE;

   ------------------------------------------
   -- LpGBT Links for Rd53 CMD/DATA transport
   ------------------------------------------
   GEN_SFP :
   for i in 3 downto 0 generate
      U_EMU_LP_GBT : entity work.AtlasRd53EmuLpGbtLane
         generic map (
            TPD_G            => TPD_G,
            NUM_ELINK_G      => 6,
            SELECT_GT_TYPE_G => false,  -- false = GTH
            XIL_DEVICE_G     => XIL_DEVICE_C)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => lpgbtReadMasters(i+0),
            axilReadSlave   => lpgbtReadSlaves(i+0),
            axilWriteMaster => lpgbtWriteMasters(i+0),
            axilWriteSlave  => lpgbtWriteSlaves(i+0),
            -- Timing Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- CMD Outputs (clk160MHz domain)
            cmdOut          => cmd(6*(i+0)+5 downto 6*(i+0)),
            invCmdOut       => invCmd(6*(i+0)+5 downto 6*(i+0)),
            dlyCmdOut       => dlyCmd(6*(i+0)+5 downto 6*(i+0)),
            -- Deserialization Interface (clk160MHz domain)
            serDesData      => serDesData(6*(i+0)+5 downto 6*(i+0)),
            rxLinkUp        => rxLinkUp(6*(i+0)+5 downto 6*(i+0)),
            -- SFP Interface
            refClk160       => sfpRef160Clk,
            rxRecClk        => rxRecClk(i+0),
            drpClk          => drpClk,
            txWordClk160    => txWordClk160(i+0),
            rxWordClk80     => rxWordClk80(i+0),
            txWordClk40     => txWordClk40,
            rxWordClk40     => rxWordClk40,
            qplllock        => qplllock(0),
            qplloutclk      => qplloutclk(0),
            qplloutrefclk   => qplloutrefclk(0),
            qpllRst         => qpllRst(i+0),
            sfpTxP          => sfpTxP(i),
            sfpTxN          => sfpTxN(i),
            sfpRxP          => sfpRxP(i),
            sfpRxN          => sfpRxN(i));
   end generate GEN_SFP;

   GEN_QSFP0 :
   for i in 3 downto 0 generate
      U_EMU_LP_GBT : entity work.AtlasRd53EmuLpGbtLane
         generic map (
            TPD_G            => TPD_G,
            NUM_ELINK_G      => 6,
            SELECT_GT_TYPE_G => true,   -- true = GTY
            XIL_DEVICE_G     => XIL_DEVICE_C)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => lpgbtReadMasters(i+4),
            axilReadSlave   => lpgbtReadSlaves(i+4),
            axilWriteMaster => lpgbtWriteMasters(i+4),
            axilWriteSlave  => lpgbtWriteSlaves(i+4),
            -- Timing Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- CMD Outputs (clk160MHz domain)
            cmdOut          => cmd(6*(i+4)+5 downto 6*(i+4)),
            invCmdOut       => invCmd(6*(i+4)+5 downto 6*(i+4)),
            dlyCmdOut       => dlyCmd(6*(i+4)+5 downto 6*(i+4)),
            -- Deserialization Interface (clk160MHz domain)
            serDesData      => serDesData(6*(i+4)+5 downto 6*(i+4)),
            rxLinkUp        => rxLinkUp(6*(i+4)+5 downto 6*(i+4)),
            -- SFP Interface
            refClk160       => qsfpRef160Clk,
            rxRecClk        => rxRecClk(i+4),
            drpClk          => drpClk,
            txWordClk160    => txWordClk160(i+4),
            rxWordClk80     => rxWordClk80(i+4),
            txWordClk40     => txWordClk40,
            rxWordClk40     => rxWordClk40,
            qplllock        => qplllock(1),
            qplloutclk      => qplloutclk(1),
            qplloutrefclk   => qplloutrefclk(1),
            qpllRst         => qpllRst(i+4),
            sfpTxP          => qsfpTxP(0)(i),
            sfpTxN          => qsfpTxN(0)(i),
            sfpRxP          => qsfpRxP(0)(i),
            sfpRxN          => qsfpRxN(0)(i));
   end generate GEN_QSFP0;

   GEN_QSFP1 :
   for i in 3 downto 0 generate
      U_EMU_LP_GBT : entity work.AtlasRd53EmuLpGbtLane
         generic map (
            TPD_G            => TPD_G,
            NUM_ELINK_G      => 6,
            SELECT_GT_TYPE_G => true,   -- true = GTY
            XIL_DEVICE_G     => XIL_DEVICE_C)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => lpgbtReadMasters(i+8),
            axilReadSlave   => lpgbtReadSlaves(i+8),
            axilWriteMaster => lpgbtWriteMasters(i+8),
            axilWriteSlave  => lpgbtWriteSlaves(i+8),
            -- Timing Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- CMD Outputs (clk160MHz domain)
            cmdOut          => cmd(6*(i+8)+5 downto 6*(i+8)),
            invCmdOut       => invCmd(6*(i+8)+5 downto 6*(i+8)),
            dlyCmdOut       => dlyCmd(6*(i+8)+5 downto 6*(i+8)),
            -- Deserialization Interface (clk160MHz domain)
            serDesData      => serDesData(6*(i+8)+5 downto 6*(i+8)),
            rxLinkUp        => rxLinkUp(6*(i+8)+5 downto 6*(i+8)),
            -- SFP Interface
            refClk160       => qsfpRef160Clk,
            rxRecClk        => rxRecClk(i+8),
            drpClk          => drpClk,
            txWordClk160    => txWordClk160(i+8),
            rxWordClk80     => rxWordClk80(i+8),
            txWordClk40     => txWordClk40,
            rxWordClk40     => rxWordClk40,
            qplllock        => qplllock(2),
            qplloutclk      => qplloutclk(2),
            qplloutrefclk   => qplloutrefclk(2),
            qpllRst         => qpllRst(i+8),
            sfpTxP          => qsfpTxP(1)(i),
            sfpTxN          => qsfpTxN(1)(i),
            sfpRxP          => qsfpRxP(1)(i),
            sfpRxN          => qsfpRxN(1)(i));
   end generate GEN_QSFP1;

end mapping;
