-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKcu105_EmuLpGbt.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
--    SFP[0] = 1GbE RUDP
--    SFP[1] = emulation LP-GBT
-------------------------------------------------------------------------------
-- Note: This design requires two FMC cards installed (HPC and LPC bays)
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

library atlas_rd53_fw_lib;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxKcu105_EmuLpGbt is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst       : in    sl;
      led          : out   slv(7 downto 0);
      smaUserGpioP : out   sl;  -- Copy of the TX's QPLL reference clock for debugging
      smaUserGpioN : out   sl;
      smaUserClkP  : out   sl;  -- Copy of the recovered RX clock for debugging
      smaUserClkN  : out   sl;
      -- 300Mhz System Clock
      sysClk300P   : in    sl;
      sysClk300N   : in    sl;
      -- FMC Interface
      gtRefClk160P : in    sl;
      gtRefClk160N : in    sl;
      gtRefClk320P : in    sl;
      gtRefClk320N : in    sl;
      fmcHpcLaP    : inout slv(33 downto 0);
      fmcHpcLaN    : inout slv(33 downto 0);
      fmcLpcLaP    : inout slv(33 downto 0);
      fmcLpcLaN    : inout slv(33 downto 0);
      -- SFP Interface
      sfpClk156P   : in    sl;
      sfpClk156N   : in    sl;
      sfpTxP       : out   slv(1 downto 0);
      sfpTxN       : out   slv(1 downto 0);
      sfpRxP       : in    slv(1 downto 0);
      sfpRxN       : in    slv(1 downto 0));
end AtlasRd53FmcXilinxKcu105_EmuLpGbt;

architecture top_level of AtlasRd53FmcXilinxKcu105_EmuLpGbt is

   constant XIL_DEVICE_C : string := "ULTRASCALE";

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

   constant NUM_AXIL_MASTERS_C : positive := 6;

   constant VERSION_INDEX_C : natural := 0;
   constant PLL_INDEX_C     : natural := 1;  -- [1:2]
   constant I2C_INDEX_C     : natural := 3;
   constant LP_GBT_INDEX_C  : natural := 4;
   constant RX_INDEX_C      : natural := 5;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"0000_0000", 24, 16);

   constant RX_CONFIG_C : AxiLiteCrossbarMasterConfigArray(15 downto 0) := genAxiLiteConfig(16, AXIL_CONFIG_C(RX_INDEX_C).baseAddr, 16, 8);

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

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

   signal refClk160     : sl;
   signal rxRecClk      : sl;
   signal drpClk        : sl;
   signal qplllock      : slv(1 downto 0);
   signal qplloutclk    : slv(1 downto 0);
   signal qplloutrefclk : slv(1 downto 0);
   signal qpllRst       : sl;

   signal pllCsL : sl;
   signal pllSck : sl;
   signal pllSdi : sl;
   signal pllSdo : sl;

   signal dPortCmdP : slv(3 downto 0);
   signal dPortCmdN : slv(3 downto 0);

   signal serDesData : Slv8Array(15 downto 0) := (others => (others => '0'));
   signal dlyLoad    : slv(15 downto 0)       := (others => '0');
   signal rxLinkUp   : slv(15 downto 0)       := (others => '0');
   signal dlyCfg     : Slv9Array(15 downto 0) := (others => (others => '0'));
   signal selectRate : Slv2Array(15 downto 0) := (others => (others => '0'));

   signal i2cScl : sl;
   signal i2cSda : sl;

   signal uplinkUp   : sl;
   signal downlinkUp : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   led(7) <= downlinkUp;
   led(6) <= downlinkUp;
   led(5) <= uplinkUp;
   led(4) <= uplinkUp;
   led(3) <= rxLinkUp(4*3+3);
   led(2) <= rxLinkUp(4*2+3);
   led(1) <= rxLinkUp(4*1+3);
   led(0) <= rxLinkUp(4*0+3);

   U_smaUserGpio : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => clk160MHz,
         clkOutP => smaUserGpioP,
         clkOutN => smaUserGpioN);

   U_smaUserClk : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => rxRecClk,  -- emulation LP-GBT recovered clock used as jitter cleaner reference
         clkOutP => smaUserClkP,
         clkOutN => smaUserClkN);

   --------------------------------
   -- 160 MHz External Reference Clock
   --------------------------------
   U_IBUFDS_refClk160 : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => gtRefClk160P,
         IB    => gtRefClk160N,
         CEB   => '0',
         ODIV2 => open,
         O     => refClk160);

   ------------------------
   -- LP-GBT QPLL Reference
   ------------------------
   U_EmuLpGbtQpll : entity work.xlx_ku_mgt_10g24_emu_qpll
      port map (
         -- MGT Clock Port (320 MHz)
         gtClkP        => gtRefClk320P,
         gtClkN        => gtRefClk320N,
         -- Quad PLL Interface
         qplllock      => qplllock,
         qplloutclk    => qplloutclk,
         qplloutrefclk => qplloutrefclk,
         qpllRst       => qpllRst);

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

   ----------------------
   -- RUDP Wrapper Module
   ----------------------
   U_RUDP : entity work.RudpServer
      generic map (
         TPD_G           => TPD_G,
         CLK_FREQUENCY_G => AXIL_CLK_FREQ_C,
         IP_ADDR_G       => x"0A02A8C0",  -- Set the default IP address before DHCP: 192.168.2.10 = x"0A02A8C0"
         DHCP_G          => true,       -- DHCP enabled
         JUMBO_G         => false)
      port map (
         extRst          => extRst,
         phyReady        => phyReady,
         -- AXI-Lite Interface
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- SFP Interface
         sfpClk156P      => sfpClk156P,
         sfpClk156N      => sfpClk156N,
         sfpTxP          => sfpTxP(0),
         sfpTxN          => sfpTxN(0),
         sfpRxP          => sfpRxP(0),
         sfpRxN          => sfpRxN(0));

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
   U_FmcMapping : entity atlas_rd53_fw_lib.AtlasRd53FmcMapping
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         -- Deserialization Interface
         serDesData    => serDesData,
         dlyLoad       => dlyLoad,
         dlyCfg        => dlyCfg,
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- Timing/Trigger Interface
         clk160MHz     => clk160MHz,
         rst160MHz     => rst160MHz,
         -- PLL Clocking Interface
         fpgaPllClkIn  => rxRecClk,  -- emulation LP-GBT recovered clock used as jitter cleaner reference
         -- PLL SPI Interface
         pllRst        => x"0",
         pllCsL        => pllCsL,
         pllSck        => pllSck,
         pllSdi        => pllSdi,
         pllSdo        => pllSdo,
         -- mDP CMD Interface
         dPortCmdP     => dPortCmdP,
         dPortCmdN     => dPortCmdN,
         -- I2C Interface
         i2cScl        => i2cScl,
         i2cSda        => i2cSda,
         -- FMC LPC Ports
         fmcLaP        => fmcHpcLaP,
         fmcLaN        => fmcHpcLaN);

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
         MEMORY_INIT_FILE_G => "AtlasRd53FmcXilinxKcu105_EmuLpGbt.mem",
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
         MEMORY_INIT_FILE_G => "AtlasRd53FmcXilinxKcu105_lpcRefClk.mem",
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
         coreSclk       => fmcLpcLaP(3),
         coreSDin       => fmcLpcLaN(4),
         coreSDout      => fmcLpcLaN(3),
         coreCsb        => fmcLpcLaP(4));

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

   -----------------------------------------
   -- LpGBT Link for Rd53 CMD/DATA transport
   -----------------------------------------
   U_EMU_LP_GBT : entity work.AtlasRd53EmuLpGbtLane
      generic map (
         TPD_G        => TPD_G,
         NUM_ELINK_G  => 4,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         -- AXI-Lite interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(LP_GBT_INDEX_C),
         axilReadSlave   => axilReadSlaves(LP_GBT_INDEX_C),
         axilWriteMaster => axilWriteMasters(LP_GBT_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(LP_GBT_INDEX_C),
         -- Timing Interface
         clk160MHz       => clk160MHz,
         rst160MHz       => rst160MHz,
         -- RD53 ASIC Ports (clk160MHz domain)
         cmdOutP         => dPortCmdP,
         cmdOutN         => dPortCmdN,
         -- Deserialization Interface (clk160MHz domain)
         serDesData(0)   => serDesData(4*0+3),
         serDesData(1)   => serDesData(4*1+3),
         serDesData(2)   => serDesData(4*2+3),
         serDesData(3)   => serDesData(4*3+3),
         rxLinkUp(0)     => rxLinkUp(4*0+3),
         rxLinkUp(1)     => rxLinkUp(4*1+3),
         rxLinkUp(2)     => rxLinkUp(4*2+3),
         rxLinkUp(3)     => rxLinkUp(4*3+3),
         -- SFP Interface
         refClk160       => refClk160,
         drpClk          => drpClk,
         rxRecClk        => rxRecClk,
         qplllock        => qplllock,
         qplloutclk      => qplloutclk,
         qplloutrefclk   => qplloutrefclk,
         qpllRst         => qpllRst,
         downlinkUp      => downlinkUp,
         uplinkUp        => uplinkUp,
         sfpTxP          => sfpTxP(1),
         sfpTxN          => sfpTxN(1),
         sfpRxP          => sfpRxP(1),
         sfpRxN          => sfpRxN(1));

   U_drp_clk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)
      port map (
         I   => axilClk,                -- 156.25 MHz
         CE  => '1',
         CLR => '0',
         O   => drpClk);                -- 39.0625 MHz

end top_level;
