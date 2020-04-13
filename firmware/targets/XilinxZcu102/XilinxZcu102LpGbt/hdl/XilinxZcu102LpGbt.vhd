-------------------------------------------------------------------------------
-- File       : XilinxZcu102LpGbt.vhd
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
use surf.AxiPkg.all;
use surf.AxiStreamPkg.all;
use surf.I2cPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library atlas_rd53_fw_lib;

library unisim;
use unisim.vcomponents.all;

entity XilinxZcu102LpGbt is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      led          : out   slv(7 downto 0);
      -- Broadcast External Timing Clock
      smaTxP       : out   sl;          -- Copy of 160 MHz clock for debugging
      smaTxN       : out   sl;          -- Copy of 160 MHz clock for debugging
      smaRxP       : in    sl;          -- RX unused
      smaRxN       : in    sl;          -- RX unused
      -- Clocks
      gtRefClk320P : in    sl;          -- FMC_HPC0_GBTCLK0_M2C_C_P
      gtRefClk320N : in    sl;          -- FMC_HPC0_GBTCLK0_M2C_C_N
      -- FMC Interface
      fmcHpc0LaP   : inout slv(33 downto 0);
      fmcHpc0LaN   : inout slv(33 downto 0);
      fmcHpc1LaP   : inout slv(29 downto 0);
      fmcHpc1LaN   : inout slv(29 downto 0);
      -- SFP Interface
      sfpEnTx      : out   slv(3 downto 0) := x"F";
      sfpTxP       : out   slv(3 downto 0);
      sfpTxN       : out   slv(3 downto 0);
      sfpRxP       : in    slv(3 downto 0);
      sfpRxN       : in    slv(3 downto 0));
end XilinxZcu102LpGbt;

architecture TOP_LEVEL of XilinxZcu102LpGbt is

   constant NUM_LP_GBT_LANES_C : positive range 1 to 4 := 4;

   constant PLL_GPIO_I2C_CONFIG_C : I2cAxiLiteDevArray(0 to 1) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100000",      -- PCA9505DGG
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'),           -- Repeat Start
      1              => MakeI2cAxiLiteDevType(
         i2cAddress  => "1011000",      -- LMK61E2
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'));          -- Repeat Start

   constant NUM_AXIL_MASTERS_C : natural := 7;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"B400_0000", 26, 20);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

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

   signal dmaClk       : slv(3 downto 0)                  := (others => '0');
   signal dmaRst       : slv(3 downto 0)                  := (others => '0');
   signal dmaIbMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaIbSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal dmaObMasters : AxiStreamMasterArray(3 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal dmaObSlaves  : AxiStreamSlaveArray(3 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal emuTimingMasters : AxiStreamMasterArray(23 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal emuTimingSlaves  : AxiStreamSlaveArray(23 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal refClk320     : sl := '0';
   signal refClk320Div2 : sl := '0';
   signal refClk320Bufg : sl := '0';

   signal clk160MHz : sl := '0';
   signal rst160MHz : sl := '0';
   signal pllClkOut : sl := '0';

   signal pllCsL : sl := '0';
   signal pllSck : sl := '0';
   signal pllSdi : sl := '0';
   signal pllSdo : sl := '0';

   signal pllbooting : sl              := '0';
   signal pllRst     : slv(3 downto 0) := (others => '0');

   signal i2cScl : sl := 'Z';
   signal i2cSda : sl := 'Z';

   signal dPortCmdP : slv(3 downto 0) := (others => '0');
   signal dPortCmdN : slv(3 downto 0) := (others => '1');

   signal downlinkUp : slv(3 downto 0) := (others => '0');
   signal uplinkUp   : slv(3 downto 0) := (others => '0');

-- attribute dont_touch                   : string;
-- attribute dont_touch of axilRst        : signal is "TRUE";
-- attribute dont_touch of coreRst        : signal is "TRUE";
-- attribute dont_touch of rst160MHz      : signal is "TRUE";
-- attribute dont_touch of downlinkUp     : signal is "TRUE";
-- attribute dont_touch of uplinkUp       : signal is "TRUE";

begin

   led(7 downto 4) <= downlinkUp;
   led(3 downto 0) <= uplinkUp;

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

   --------------------------------
   -- 156.25 MHz DMA/AXI-Lite Clock
   --------------------------------
   U_PLL : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G            => TPD_G,
         TYPE_G           => "PLL",
         INPUT_BUFG_G     => false,
         FB_BUFG_G        => true,
         NUM_CLOCKS_G     => 1,
         CLKIN_PERIOD_G   => 8.0,       -- 125 MHz
         CLKFBOUT_MULT_G  => 10,        -- 1250 MHz
         CLKOUT0_DIVIDE_G => 8)         -- 156.25 MHz
      port map(
         clkIn     => coreClk,
         rstIn     => coreRst,
         clkOut(0) => axilClk,
         rstOut(0) => axilRst);

   -------------------
   -- FMC Port Mapping
   -------------------
   U_FmcMapping : entity atlas_rd53_fw_lib.AtlasRd53FmcMapping
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => "ULTRASCALE_PLUS")
      port map (
         -- Deserialization Interface
         serDesData    => open,
         dlyLoad       => (others => '0'),
         dlyCfg        => (others => (others => '0')),
         iDelayCtrlRdy => '0',
         -- Timing/Trigger Interface
         clk160MHz     => clk160MHz,
         rst160MHz     => rst160MHz,
         pllClkOut     => pllClkOut,
         -- PLL Clocking Interface
         fpgaPllClkIn  => '0',
         -- PLL SPI Interface
         pllRst        => pllRst,  -- FPGA PLL reset (not external Jitter cleaner)
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
         fmcLaP        => fmcHpc0LaP,
         fmcLaN        => fmcHpc0LaN);

   ----------------------------
   -- Broadcast Reference Clock
   ----------------------------
   U_SmaTxClkout : entity work.SmaTxClkout
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Clocks and Resets
         gtRefClk => pllClkOut,
         drpClk   => clk160MHz,
         drpRst   => rst160MHz,
         -- Broadcast External Timing Clock
         smaTxP   => smaTxP,
         smaTxN   => smaTxN,
         smaRxP   => smaRxP,
         smaRxN   => smaRxN);

   --------------------------------
   -- 320 MHz LpGBT Reference Clock
   --------------------------------
   U_IBUFDS_refClk320 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => gtRefClk320P,
         IB    => gtRefClk320N,
         CEB   => '0',
         ODIV2 => refClk320Div2,
         O     => refClk320);

   U_BUFG_refClk320 : BUFG_GT
      port map (
         I       => refClk320Div2,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => refClk320Bufg);

   ------------------
   -- SFP LpGBT Lanes
   ------------------
   GEN_SFP :
   for i in NUM_LP_GBT_LANES_C-1 downto 0 generate
      U_LpGbtLane : entity work.AtlasRd53LpGbtLane
         generic map (
            TPD_G            => TPD_G,
            AXIS_CONFIG_G    => ite((i = 2), RCEG3_AXIS_DMA_ACP_CONFIG_C, RCEG3_AXIS_DMA_CONFIG_C),
            AXIL_BASE_ADDR_G => AXIL_XBAR_CONFIG_C(i).baseAddr)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk          => axilClk,
            axilRst          => axilRst,
            axilReadMaster   => axilReadMasters(i),
            axilReadSlave    => axilReadSlaves(i),
            axilWriteMaster  => axilWriteMasters(i),
            axilWriteSlave   => axilWriteSlaves(i),
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
            downlinkUp       => downlinkUp(i),
            uplinkUp         => uplinkUp(i),
            -- SFP Interface
            sfpTxP           => sfpTxP(i),
            sfpTxN           => sfpTxN(i),
            sfpRxP           => sfpRxP(i),
            sfpRxN           => sfpRxN(i));
   end generate GEN_SFP;

   GEN_GTH_TERM : if (NUM_LP_GBT_LANES_C /= 4) generate
      U_GTH_TERM : entity surf.Gthe4ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 4-NUM_LP_GBT_LANES_C)
         port map (
            refClk => axilRst,
            gtTxP  => sfpTxP(3 downto NUM_LP_GBT_LANES_C),
            gtTxN  => sfpTxN(3 downto NUM_LP_GBT_LANES_C),
            gtRxP  => sfpRxP(3 downto NUM_LP_GBT_LANES_C),
            gtRxN  => sfpRxN(3 downto NUM_LP_GBT_LANES_C));
   end generate;

   --------------------
   -- AXI-Lite: PLL SPI
   --------------------
   U_Si5345 : entity surf.Si5345
      generic map (
         TPD_G              => TPD_G,
         MEMORY_INIT_FILE_G => "Si5345-RevD-Registers-160MHz.mem",  -- Use FMC on-board 160 MHz reference
         CLK_PERIOD_G       => (1/156.25E+6),
         SPI_SCLK_PERIOD_G  => (1/10.0E+6))  -- 1/(10 MHz SCLK)
      port map (
         -- AXI-Lite Register Interface
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(4),
         axiReadSlave   => axilReadSlaves(4),
         axiWriteMaster => axilWriteMasters(4),
         axiWriteSlave  => axilWriteSlaves(4),
         -- Status Interface
         booting        => pllbooting,
         -- SPI Ports
         coreSclk       => pllSck,
         coreSDin       => pllSdo,
         coreSDout      => pllSdi,
         coreCsb        => pllCsL);

   pllRst <= (others => pllbooting);

   ----------------------------------
   -- Emulation Timing/Trigger Module
   ----------------------------------
   U_EmuTiming : entity atlas_rd53_fw_lib.AtlasRd53EmuTiming
      generic map(
         TPD_G        => TPD_G,
         NUM_AXIS_G   => 24,
         ADDR_WIDTH_G => 10)
      port map(
         -- AXI-Lite Interface (axilClk domain)
         axilClk          => axilClk,
         axilRst          => axilRst,
         axilReadMasters  => axilReadMasters(6 downto 5),
         axilReadSlaves   => axilReadSlaves(6 downto 5),
         axilWriteMasters => axilWriteMasters(6 downto 5),
         axilWriteSlaves  => axilWriteSlaves(6 downto 5),
         -- Streaming RD53 Trig Interface (clk160MHz domain)
         clk160MHz        => clk160MHz,
         rst160MHz        => rst160MHz,
         emuTimingMasters => emuTimingMasters,
         emuTimingSlaves  => emuTimingSlaves);

   ----------------------------
   -- Drive the unused CMD line
   ----------------------------
   GEN_CMD :
   for i in 3 downto 0 generate
      U_OBUFDS : OBUFDS
         port map (
            I  => '0',
            O  => dPortCmdP(i),
            OB => dPortCmdN(i));
   end generate GEN_CMD;

end TOP_LEVEL;
