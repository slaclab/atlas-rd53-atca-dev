-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxZcu102_HybridLpGbt.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
--    SFP[0] = emulation LP-GBT[0]
--    SFP[1] = emulation LP-GBT[1]
--    SFP[2] = LP-GBT[0]
--    SFP[3] = LP-GBT[1]
-------------------------------------------------------------------------------
-- Note: This design requires two FMC cards installed (HPC[0] and HPC[1] bays)
--       HPC[1] mDP used with RD53 ASICs via mDP ports
--       HPC[0] is only used for a LHC free-running clock reference (mDP unused)
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
use surf.I2cPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library atlas_rd53_fw_lib;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxZcu102_HybridLpGbt is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst       : in    sl;
      led          : out   slv(7 downto 0);
      -- Broadcast External Timing Clock
      smaTxP       : out   sl;          -- Copy of 160 MHz clock for debugging
      smaTxN       : out   sl;          -- Copy of 160 MHz clock for debugging
      smaRxP       : in    sl;          -- RX unused
      smaRxN       : in    sl;          -- RX unused
      -- 300Mhz System Clock
      sysClk300P   : in    sl;
      sysClk300N   : in    sl;
      -- FMC Interface
      gtRefClk320P : in    sl;
      gtRefClk320N : in    sl;
      gtRecClk320P : in    sl;
      gtRecClk320N : in    sl;
      fmcHpc0LaP   : inout slv(33 downto 0);
      fmcHpc0LaN   : inout slv(33 downto 0);
      fmcHpc1LaP   : inout slv(29 downto 0);
      fmcHpc1LaN   : inout slv(29 downto 0);
      -- SFP Interface
      sfpClk156P   : in    sl;
      sfpClk156N   : in    sl;
      sfpEnTx      : out   slv(3 downto 0) := x"F";
      sfpTxP       : out   slv(3 downto 0);
      sfpTxN       : out   slv(3 downto 0);
      sfpRxP       : in    slv(3 downto 0);
      sfpRxN       : in    slv(3 downto 0));
end AtlasRd53FmcXilinxZcu102_HybridLpGbt;

architecture TOP_LEVEL of AtlasRd53FmcXilinxZcu102_HybridLpGbt is

   constant NUM_ELINKS_C : positive := 7*2;  -- (6 per lpGBT link) x (4 SFP links + 8 QSFP links)

   constant RX_RECCLK_INDEX_C : natural := 0;  -- Using SFP[0] for the recovered clock reference for jitter cleaner PLL

   impure function RxPhyToApp return Slv7Array is
      variable i      : natural;
      variable retVar : Slv7Array(127 downto 0);
   begin
      -- Uplink: PHY to Application Mapping
      for i in 0 to 3 loop
         -- APP.CH[i]  <--- PHY.CH[4*i+3]  = mDP.CH[i].RX[3]
         retVar(i) := toSlv((4*i+3), 7);
      end loop;
      for i in 4 to 127 loop
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

   constant XIL_DEVICE_C : string := "ULTRASCALE_PLUS";

   constant PLL_GPIO_I2C_CONFIG_C : I2cAxiLiteDevArray(0 to 1) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100000",      -- PCA9505DGG
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'),           -- Repeat Start
      1              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1011000",      -- PCA9505DGG
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'));          -- Repeat Start

   constant AXIL_CLK_FREQ_C : real := 156.25E+6;  -- Units of Hz

   constant NUM_AXIL_MASTERS_C : positive := 14;

   --------------------------
   -- Emulation lpGBT Devices
   --------------------------
   constant VERSION_INDEX_C      : natural := 0;
   constant PLL_INDEX_C          : natural := 1;  -- [1:2]
   constant I2C_INDEX_C          : natural := 3;
   constant EMU_LP_GBT_INDEX_C   : natural := 4;  -- [4:5]
   constant RX_INDEX_C           : natural := 6;
   constant RX_PHY_REMAP_INDEX_C : natural := 7;
   constant TX_PHY_REMAP_INDEX_C : natural := 8;

   --------------------------
   -- lpGBT Devices
   --------------------------
   constant SMA_TX_CLK_INDEX_C : natural := 9;
   constant EMU_TIMING_INDEX_C : natural := 10;  -- [10:11]
   constant LP_GBT_INDEX_C     : natural := 12;  -- [12:13]

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"B400_0000", 26, 20);

   constant RX_CONFIG_C : AxiLiteCrossbarMasterConfigArray(15 downto 0) := genAxiLiteConfig(16, AXIL_CONFIG_C(RX_INDEX_C).baseAddr, 16, 8);

   signal axilClk         : sl                    := '0';
   signal axilRst         : sl                    := '0';
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal coreClk         : sl                    := '0';
   signal coreRst         : sl                    := '0';
   signal coreReadMaster  : AxiLiteReadMasterType;
   signal coreReadSlave   : AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
   signal coreWriteMaster : AxiLiteWriteMasterType;
   signal coreWriteSlave  : AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal dmaClk       : slv(3 downto 0)                  := (others => '0');
   signal dmaRst       : slv(3 downto 0)                  := (others => '0');
   signal dmaIbMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaIbSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal dmaObMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaObSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal emuTimingMasters : AxiStreamMasterArray(11 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal emuTimingSlaves  : AxiStreamSlaveArray(11 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal rxWriteMasters : AxiLiteWriteMasterArray(15 downto 0);
   signal rxWriteSlaves  : AxiLiteWriteSlaveArray(15 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal rxReadMasters  : AxiLiteReadMasterArray(15 downto 0);
   signal rxReadSlaves   : AxiLiteReadSlaveArray(15 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal sysClk300NB   : sl;
   signal sysClk300     : sl;
   signal sysRst300     : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;
   signal iDelayCtrlRdy : sl;

   signal phyReady : sl;

   signal clk160MHz : sl;
   signal rst160MHz : sl;
   signal pllClkOut : sl;

   signal txWordClk160 : slv(1 downto 0);
   signal rxWordClk80  : slv(1 downto 0);
   signal txWordClk40  : sl;
   signal rxWordClk40  : sl;

   signal refClk320     : sl;
   signal refClk160     : sl;
   signal refClk160Bufg : sl;
   signal recClk320     : sl;
   signal recClk320Bufg : sl;
   signal rxRecClk      : slv(1 downto 0);
   signal drpClk        : sl;
   signal qplllock      : slv(1 downto 0);
   signal qplloutclk    : slv(1 downto 0);
   signal qplloutrefclk : slv(1 downto 0);
   signal qpllRst       : slv(1 downto 0);

   signal pllCsL : sl;
   signal pllSck : sl;
   signal pllSdi : sl;
   signal pllSdo : sl;

   signal dPortCmdP : slv(3 downto 0);
   signal dPortCmdN : slv(3 downto 0);

   signal cmd    : slv(127 downto 0) := (others => '0');
   signal invCmd : slv(127 downto 0) := (others => '0');
   signal dlyCmd : slv(127 downto 0) := (others => '0');

   signal serDesData : Slv8Array(15 downto 0) := (others => (others => '0'));
   signal dlyLoad    : slv(15 downto 0)       := (others => '0');
   signal rxLinkUp   : slv(15 downto 0)       := (others => '0');
   signal dlyCfg     : Slv9Array(15 downto 0) := (others => (others => '0'));
   signal selectRate : Slv2Array(15 downto 0) := (others => (others => '0'));

   signal i2cScl : sl;
   signal i2cSda : sl;

   signal downlinkUp : slv(3 downto 0) := (others => '0');
   signal uplinkUp   : slv(3 downto 0) := (others => '0');

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   led(7 downto 4) <= downlinkUp;
   led(3 downto 0) <= uplinkUp;

   ---------------------------------------
   -- 320 MHz Free-running Reference Clock
   ---------------------------------------
   U_IBUFDS_refClk320 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "01",  -- 2'b01: ODIV2 = Divide-by-2 version of O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => gtRefClk320P,
         IB    => gtRefClk320N,
         CEB   => '0',
         ODIV2 => refClk160,
         O     => refClk320);

   U_BUFG_refClk160 : BUFG_GT
      port map (
         I       => refClk160,
         CE      => '1',
         CLR     => '0',
         CEMASK  => '1',
         CLRMASK => '1',
         DIV     => "000",              -- Divide by 1
         O       => refClk160Bufg);

   ------------------------------------
   -- 320 MHz Recovered Reference Clock
   ------------------------------------
   U_IBUFDS_recClk320 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => gtRecClk320P,
         IB    => gtRecClk320N,
         CEB   => '0',
         ODIV2 => recClk320,
         O     => open);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => recClk320,
         CE      => '1',
         CLR     => '0',
         CEMASK  => '1',
         CLRMASK => '1',
         DIV     => "000",              -- Divide by 1
         O       => recClk320Bufg);

   ------------------------
   -- LP-GBT QPLL Reference
   ------------------------
   U_EmuLpGbtQpll : entity work.xlx_ku_mgt_10g24_emu_qpll
      generic map (
         TPD_G             => TPD_G,
         GT_CLK_SEL_G      => true,
         QPLL_REFCLK_SEL_G => "111")    -- 111: GTGREFCLK selected
      port map (
         -- MGT Clock Port (320 MHz)
         gtClkIn       => recClk320Bufg,
         -- Quad PLL Interface
         qplllock      => qplllock,
         qplloutclk    => qplloutclk,
         qplloutrefclk => qplloutrefclk,
         qpllRst       => qpllRst(RX_RECCLK_INDEX_C));

   -----------------------------
   -- 300 IDELAY Reference Clock
   -----------------------------
   U_SysClk300IBUFDS : IBUFDS
      generic map (
         DIFF_TERM    => false,
         IBUF_LOW_PWR => false)
      port map (
         I  => sysClk300P,
         IB => sysClk300N,
         O  => sysClk300);

   U_SysclkBUFG : BUFG
      port map (
         I => sysClk300,
         O => refClk300MHz);

   U_SysclkRstSync : entity surf.RstSync
      port map (
         clk      => refClk300MHz,
         asyncRst => extRst,
         syncRst  => refRst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   -----------
   -- RCE Core
   -----------
   U_Core : entity rce_gen3_fw_lib.XilinxZcu102Core
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => BUILD_INFO_G)
      port map (
         -- AXI-Lite Register Interface [0xB4000000:0xB7FFFFFF]
         axiClk             => coreClk,
         axiClkRst          => coreRst,
         extAxilReadMaster  => coreReadMaster,
         extAxilReadSlave   => coreReadSlave,
         extAxilWriteMaster => coreWriteMaster,
         extAxilWriteSlave  => coreWriteSlave,
         -- AXI Stream DMA Interfaces
         dmaClk             => dmaClk,
         dmaClkRst          => dmaRst,
         dmaObMaster        => dmaObMasters,
         dmaObSlave         => dmaObSlaves,
         dmaIbMaster        => dmaIbMasters,
         dmaIbSlave         => dmaIbSlaves);

   dmaClk <= (others => axilClk);
   dmaRst <= (others => axilRst);

   ----------------------------------------
   -- Move AXI-Lite to another clock domain
   ----------------------------------------
   U_AxiLiteAsync : entity surf.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 32)
      port map (
         -- Slave Interface
         sAxiClk         => coreClk,
         sAxiClkRst      => coreRst,
         sAxiReadMaster  => coreReadMaster,
         sAxiReadSlave   => coreReadSlave,
         sAxiWriteMaster => coreWriteMaster,
         sAxiWriteSlave  => coreWriteSlave,
         -- Master Interface
         mAxiClk         => axilClk,
         mAxiClkRst      => axilRst,
         mAxiReadMaster  => axilReadMaster,
         mAxiReadSlave   => axilReadSlave,
         mAxiWriteMaster => axilWriteMaster,
         mAxiWriteSlave  => axilWriteSlave);

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

   U_RX_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 16,
         MASTERS_CONFIG_G   => RX_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMasters(RX_INDEX_C),
         sAxiWriteSlaves(0)  => axilWriteSlaves(RX_INDEX_C),
         sAxiReadMasters(0)  => axilReadMasters(RX_INDEX_C),
         sAxiReadSlaves(0)   => axilReadSlaves(RX_INDEX_C),
         mAxiWriteMasters    => rxWriteMasters,
         mAxiWriteSlaves     => rxWriteSlaves,
         mAxiReadMasters     => rxReadMasters,
         mAxiReadSlaves      => rxReadSlaves);

   -------------------
   -- FMC Port Mapping
   -------------------
   U_FmcMapping : entity work.AtlasRd53FmcMappingWithMux
      generic map (
         TPD_G                => TPD_G,
         XIL_DEVICE_G         => XIL_DEVICE_C,
         FMC_WIDTH_G          => 30,
         RX_PHY_TO_APP_INIT_G => RX_PHY_TO_APP_INIT_C)
      port map (
         -- Deserialization Interface
         serDesData      => serDesData,
         dlyLoad         => dlyLoad,
         dlyCfg          => dlyCfg,
         iDelayCtrlRdy   => iDelayCtrlRdy,
         -- Timing/Trigger Interface
         clk160MHz       => clk160MHz,
         rst160MHz       => rst160MHz,
         pllClkOut       => pllClkOut,
         -- PLL Clocking Interface
         fpgaPllClkIn    => rxRecClk(RX_RECCLK_INDEX_C),  -- emulation LP-GBT recovered clock used as jitter cleaner reference
         -- PLL SPI Interface
         pllRst          => x"0",
         pllCsL          => pllCsL,
         pllSck          => pllSck,
         pllSdi          => pllSdi,
         pllSdo          => pllSdo,
         -- mDP CMD Interface
         dPortCmdP       => dPortCmdP,
         dPortCmdN       => dPortCmdN,
         -- I2C Interface
         i2cScl          => i2cScl,
         i2cSda          => i2cSda,
         -- FMC LPC Ports
         fmcLaP          => fmcHpc1LaP,
         fmcLaN          => fmcHpc1LaN,
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
         cmdOutP(3 downto 0)  => dPortCmdP,
         cmdOutP(31 downto 4) => open,
         cmdOutN(3 downto 0)  => dPortCmdN,
         cmdOutN(31 downto 4) => open,
         -- Timing Clock/Reset Interface
         clk160MHz            => clk160MHz,
         rst160MHz            => rst160MHz,
         cmd                  => cmd,
         invCmd               => invCmd,
         dlyCmd               => dlyCmd,
         -- AXI-Lite Interface (axilClk domain)
         axilClk              => axilClk,
         axilRst              => axilRst,
         axilReadMaster       => axilReadMasters(TX_PHY_REMAP_INDEX_C),
         axilReadSlave        => axilReadSlaves(TX_PHY_REMAP_INDEX_C),
         axilWriteMaster      => axilWriteMasters(TX_PHY_REMAP_INDEX_C),
         axilWriteSlave       => axilWriteSlaves(TX_PHY_REMAP_INDEX_C));

   --------------------
   -- AxiVersion Module
   --------------------
   U_AxiVersion : entity surf.AxiVersion
      generic map (
         TPD_G        => TPD_G,
         CLK_PERIOD_G => (1.0/AXIL_CLK_FREQ_C),
         BUILD_INFO_G => BUILD_INFO_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         axiReadMaster  => axilReadMasters(VERSION_INDEX_C),
         axiReadSlave   => axilReadSlaves(VERSION_INDEX_C),
         axiWriteMaster => axilWriteMasters(VERSION_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(VERSION_INDEX_C),
         axiClk         => axilClk,
         axiRst         => axilRst);

   --------------------
   -- AXI-Lite: PLL SPI
   --------------------
   U_PLL0 : entity surf.Si5345
      generic map (
         TPD_G              => TPD_G,
         MEMORY_INIT_FILE_G => "AtlasRd53Fmc_EmuLpGbt.mem",
         CLK_PERIOD_G       => (1/AXIL_CLK_FREQ_C),
         SPI_SCLK_PERIOD_G  => (1/10.0E+6))  -- 1/(10 MHz SCLK)
      port map (
         -- AXI-Lite Register Interface
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(PLL_INDEX_C+0),
         axiReadSlave   => axilReadSlaves(PLL_INDEX_C+0),
         axiWriteMaster => axilWriteMasters(PLL_INDEX_C+0),
         axiWriteSlave  => axilWriteSlaves(PLL_INDEX_C+0),
         -- SPI Ports
         coreSclk       => pllSck,
         coreSDin       => pllSdo,
         coreSDout      => pllSdi,
         coreCsb        => pllCsL);

   U_PLL1 : entity surf.Si5345
      generic map (
         TPD_G              => TPD_G,
         MEMORY_INIT_FILE_G => "AtlasRd53Fmc_lpcRefClk.mem",
         CLK_PERIOD_G       => (1/AXIL_CLK_FREQ_C),
         SPI_SCLK_PERIOD_G  => (1/10.0E+6))  -- 1/(10 MHz SCLK)
      port map (
         -- AXI-Lite Register Interface
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(PLL_INDEX_C+1),
         axiReadSlave   => axilReadSlaves(PLL_INDEX_C+1),
         axiWriteMaster => axilWriteMasters(PLL_INDEX_C+1),
         axiWriteSlave  => axilWriteSlaves(PLL_INDEX_C+1),
         -- SPI Ports
         coreSclk       => fmcHpc0LaP(3),
         coreSDin       => fmcHpc0LaN(4),
         coreSDout      => fmcHpc0LaN(3),
         coreCsb        => fmcHpc0LaP(4));

   ---------------------------
   -- AXI-Lite: I2C Reg Access
   ---------------------------
   U_PLL_RX_QUAL : entity surf.AxiI2cRegMaster
      generic map (
         TPD_G          => TPD_G,
         DEVICE_MAP_G   => PLL_GPIO_I2C_CONFIG_C,
         I2C_SCL_FREQ_G => 100.0E+3,    -- units of Hz
         AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
      port map (
         -- I2C Ports
         scl            => i2cScl,
         sda            => i2cSda,
         -- AXI-Lite Register Interface
         axiReadMaster  => axilReadMasters(I2C_INDEX_C),
         axiReadSlave   => axilReadSlaves(I2C_INDEX_C),
         axiWriteMaster => axilWriteMasters(I2C_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(I2C_INDEX_C),
         -- Clocks and Resets
         axiClk         => axilClk,
         axiRst         => axilRst);

   ----------------------------------------------------------
   -- Using AuroraRxLane for this is IDELAY alignment feature
   ----------------------------------------------------------
   GEN_LANE : for i in 15 downto 0 generate
      U_Rx : entity work.AuroraRxLaneWrapper
         generic map (
            TPD_G => TPD_G)
         port map (
            -- RD53 ASIC Serial Interface  (clk160MHz domain)
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            serDesData      => serDesData(i),
            dlyLoad         => dlyLoad(i),
            dlyCfg          => dlyCfg(i),
            rxLinkUp        => rxLinkUp(i),
            selectRate      => selectRate(i),
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => rxReadMasters(i),
            axilReadSlave   => rxReadSlaves(i),
            axilWriteMaster => rxWriteMasters(i),
            axilWriteSlave  => rxWriteSlaves(i));
   end generate GEN_LANE;

   GEN_SFP :
   for i in 1 downto 0 generate

      U_EMU_LP_GBT : entity work.AtlasRd53EmuLpGbtLane
         generic map (
            TPD_G             => TPD_G,
            NUM_ELINK_G       => 7,
            CPLL_REFCLK_SEL_G => "111",  -- 111: GTGREFCLK selected
            XIL_DEVICE_G      => XIL_DEVICE_C)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(EMU_LP_GBT_INDEX_C+i),
            axilReadSlave   => axilReadSlaves(EMU_LP_GBT_INDEX_C+i),
            axilWriteMaster => axilWriteMasters(EMU_LP_GBT_INDEX_C+i),
            axilWriteSlave  => axilWriteSlaves(EMU_LP_GBT_INDEX_C+i),
            -- Timing Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- CMD Outputs (clk160MHz domain)
            cmdOut          => cmd(7*i+6 downto 7*i),
            invCmdOut       => invCmd(7*i+6 downto 7*i),
            dlyCmdOut       => dlyCmd(7*i+6 downto 7*i),
            -- Deserialization Interface (clk160MHz domain)
            serDesData      => serDesData(7*i+6 downto 7*i),
            rxLinkUp        => rxLinkUp(7*i+6 downto 7*i),
            -- Clocks Interfaces
            refClk160       => refClk160Bufg,
            drpClk          => drpClk,
            txWordClk160    => txWordClk160(i),
            rxWordClk80     => rxWordClk80(i),
            txWordClk40     => txWordClk40,
            rxWordClk40     => rxWordClk40,
            rxRecClk        => rxRecClk(i),
            -- QPLL Interface
            qplllock        => qplllock,
            qplloutclk      => qplloutclk,
            qplloutrefclk   => qplloutrefclk,
            qpllRst         => qpllRst(i),
            -- Status
            downlinkUp      => downlinkUp(i+0),
            uplinkUp        => uplinkUp(i+0),
            -- SFP Interface
            sfpTxP          => sfpTxP(i+0),
            sfpTxN          => sfpTxN(i+0),
            sfpRxP          => sfpRxP(i+0),
            sfpRxN          => sfpRxN(i+0));

      U_LP_GBT : entity work.AtlasRd53LpGbtLane
         generic map (
            TPD_G            => TPD_G,
            AXIS_CONFIG_G    => ite((i = 2), RCEG3_AXIS_DMA_ACP_CONFIG_C, RCEG3_AXIS_DMA_CONFIG_C),
            AXIL_BASE_ADDR_G => AXIL_CONFIG_C(LP_GBT_INDEX_C+i).baseAddr)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk          => axilClk,
            axilRst          => axilRst,
            axilReadMaster   => axilReadMasters(LP_GBT_INDEX_C+i),
            axilReadSlave    => axilReadSlaves(LP_GBT_INDEX_C+i),
            axilWriteMaster  => axilWriteMasters(LP_GBT_INDEX_C+i),
            axilWriteSlave   => axilWriteSlaves(LP_GBT_INDEX_C+i),
            -- DMA interface (axilClk domain)
            dmaIbMaster      => dmaIbMasters(i),
            dmaIbSlave       => dmaIbSlaves(i),
            dmaObMaster      => dmaObMasters(i),
            dmaObSlave       => dmaObSlaves(i),
            -- Streaming EMU Trig Interface (clk160MHz domain)
            emuTimingMasters => emuTimingMasters(6*i+5 downto 6*i),
            emuTimingSlaves  => emuTimingSlaves(6*i+5 downto 6*i),
            -- Clocks and Resets
            refClk320        => refClk320,
            clk160MHz        => clk160MHz,
            rst160MHz        => rst160MHz,
            -- Status
            downlinkUp       => downlinkUp(i+2),
            uplinkUp         => uplinkUp(i+2),
            -- SFP Interface
            sfpTxP           => sfpTxP(i+2),
            sfpTxN           => sfpTxN(i+2),
            sfpRxP           => sfpRxP(i+2),
            sfpRxN           => sfpRxN(i+2));

   end generate GEN_SFP;

   U_drp_clk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)
      port map (
         I   => axilClk,                -- 156.25 MHz
         CE  => '1',
         CLR => '0',
         O   => drpClk);                -- 39.0625 MHz

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

   ----------------------------------
   -- Emulation Timing/Trigger Module
   ----------------------------------
   U_EmuTiming : entity atlas_rd53_fw_lib.AtlasRd53EmuTiming
      generic map(
         TPD_G        => TPD_G,
         NUM_AXIS_G   => 12,
         ADDR_WIDTH_G => 10)
      port map(
         -- AXI-Lite Interface (axilClk domain)
         axilClk          => axilClk,
         axilRst          => axilRst,
         axilReadMasters  => axilReadMasters(EMU_TIMING_INDEX_C+1 downto EMU_TIMING_INDEX_C),
         axilReadSlaves   => axilReadSlaves(EMU_TIMING_INDEX_C+1 downto EMU_TIMING_INDEX_C),
         axilWriteMasters => axilWriteMasters(EMU_TIMING_INDEX_C+1 downto EMU_TIMING_INDEX_C),
         axilWriteSlaves  => axilWriteSlaves(EMU_TIMING_INDEX_C+1 downto EMU_TIMING_INDEX_C),
         -- Streaming RD53 Trig Interface (clk160MHz domain)
         clk160MHz        => clk160MHz,
         rst160MHz        => rst160MHz,
         emuTimingMasters => emuTimingMasters,
         emuTimingSlaves  => emuTimingSlaves);

   ----------------------------
   -- Broadcast Reference Clock
   ----------------------------
   U_SmaTxClkout : entity work.SmaTxClkout
      generic map (
         TPD_G => TPD_G)
      port map (
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(SMA_TX_CLK_INDEX_C),
         axilReadSlave   => axilReadSlaves(SMA_TX_CLK_INDEX_C),
         axilWriteMaster => axilWriteMasters(SMA_TX_CLK_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(SMA_TX_CLK_INDEX_C),
         -- Clocks and Resets
         gtRefClk        => pllClkOut,
         drpClk          => clk160MHz,
         drpRst          => rst160MHz,
         -- Broadcast External Timing Clock
         smaTxP          => smaTxP,
         smaTxN          => smaTxN,
         smaRxP          => smaRxP,
         smaRxN          => smaRxN);

end top_level;
