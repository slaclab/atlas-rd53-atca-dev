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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiPkg.all;
use work.AxiStreamPkg.all;
use work.I2cPkg.all;
use work.RceG3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxZcu102LpGbt is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      extRst       : in    sl;
      led          : out   slv(7 downto 0);
      -- Broadcast External Timing Clock
      smaTxP       : out   sl;
      smaTxN       : out   sl;
      smaRxP       : in    sl;          -- RX unused
      smaRxN       : in    sl;          -- RX unused      
      -- Clocks
      gtRefClk320P : in    sl;          -- FMC_HPC0_GBTCLK0_M2C_C_P
      gtRefClk320N : in    sl;          -- FMC_HPC0_GBTCLK0_M2C_C_N
      userClk156P  : in    sl;          -- USER_MGT_SI570_CLOCK1_C_P
      userClk156N  : in    sl;          -- USER_MGT_SI570_CLOCK1_C_N
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

   constant NUM_AXIL_MASTERS_C : natural := 5;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"B400_0000", 26, 20);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal coreClk         : sl;
   signal coreRst         : sl;
   signal coreReadMaster  : AxiLiteReadMasterType;
   signal coreReadSlave   : AxiLiteReadSlaveType;
   signal coreWriteMaster : AxiLiteWriteMasterType;
   signal coreWriteSlave  : AxiLiteWriteSlaveType;

   signal dmaClk       : slv(3 downto 0);
   signal dmaRst       : slv(3 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(3 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(3 downto 0);
   signal dmaObMasters : AxiStreamMasterArray(3 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal gtRefClk320    : sl;
   signal gtRefClk320div : sl;
   signal refClk320      : sl;
   signal userClk156     : sl;
   signal userClk156Bufg : sl;

   signal clk160MHz : sl;
   signal rst160MHz : sl;
   signal pllClkOut : sl;

   signal pllCsL : sl;
   signal pllSck : sl;
   signal pllSdi : sl;
   signal pllSdo : sl;

   signal i2cScl : sl;
   signal i2cSda : sl;

   signal dPortCmdP : slv(3 downto 0);
   signal dPortCmdN : slv(3 downto 0);

   signal downlinkUp : slv(3 downto 0);
   signal uplinkUp   : slv(3 downto 0);

   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   led(7 downto 4) <= downlinkUp;
   led(3 downto 0) <= uplinkUp;

   -----------
   -- RCE Core
   -----------
   U_Core : entity work.XilinxZcu102Core
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
   U_AxiLiteAsync : entity work.AxiLiteAsync
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
   U_XBAR : entity work.AxiLiteCrossbar
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
   U_IBUFDS_userClk156 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => userClk156P,
         IB    => userClk156N,
         CEB   => '0',
         ODIV2 => userClk156,
         O     => open);

   U_BUFG_userClk156 : BUFG_GT
      port map (
         I       => userClk156,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => userClk156Bufg);

   U_PLL : entity work.ClockManagerUltraScale
      generic map(
         TPD_G            => TPD_G,
         TYPE_G           => "PLL",
         INPUT_BUFG_G     => false,
         FB_BUFG_G        => true,
         NUM_CLOCKS_G     => 1,
         CLKIN_PERIOD_G   => 6.4,
         CLKFBOUT_MULT_G  => 8,
         CLKOUT0_DIVIDE_G => 8)
      port map(
         clkIn     => userClk156Bufg,
         rstIn     => coreRst,
         clkOut(0) => axilClk,
         rstOut(0) => axilRst);

   --------------------------
   -- Reference 300 MHz clock 
   --------------------------
   U_MMCM : entity work.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
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
         clkIn     => userClk156Bufg,
         rstIn     => coreRst,
         clkOut(0) => refClk300MHz,
         rstOut(0) => refRst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   -------------------
   -- FMC Port Mapping
   -------------------
   U_FmcMapping : entity work.AtlasRd53FmcMapping
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => "ULTRASCALE_PLUS")
      port map (
         -- Deserialization Interface
         serDesData    => open,
         dlyLoad       => (others => '0'),
         dlyCfg        => (others => (others => '0')),
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- Timing/Trigger Interface
         clk160MHz     => clk160MHz,
         rst160MHz     => rst160MHz,
         pllClkOut     => pllClkOut,
         -- PLL Clocking Interface
         fpgaPllClkIn  => '0',
         -- PLL SPI Interface
         pllRst        => (others => '0'),
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
         ODIV2 => gtRefClk320div,
         O     => gtRefClk320);

   U_BUFG_refClk320 : BUFG_GT
      port map (
         I       => gtRefClk320div,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => refClk320);

   ------------------
   -- SFP LpGBT Lanes
   ------------------
   GEN_SFP :
   for i in 3 downto 0 generate
      U_LpGbtLane : entity work.AtlasRd53LpGbtLane
         generic map (
            TPD_G            => TPD_G,
            AXIS_CONFIG_G    => ite((i = 2), RCEG3_AXIS_DMA_ACP_CONFIG_C, RCEG3_AXIS_DMA_CONFIG_C),
            AXIL_BASE_ADDR_G => AXIL_XBAR_CONFIG_C(i).baseAddr)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i),
            -- DMA interface (axilClk domain)
            dmaIbMaster     => dmaIbMasters(i),
            dmaIbSlave      => dmaIbSlaves(i),
            dmaObMaster     => dmaObMasters(i),
            dmaObSlave      => dmaObSlaves(i),
            -- SFP Interface
            refClk320       => refClk320,
            gtRefClk320     => gtRefClk320,
            downlinkUp      => downlinkUp(i),
            uplinkUp        => uplinkUp(i),
            sfpTxP          => sfpTxP(i),
            sfpTxN          => sfpTxN(i),
            sfpRxP          => sfpRxP(i),
            sfpRxN          => sfpRxN(i));
   end generate GEN_SFP;

   --------------------
   -- AXI-Lite: PLL SPI
   --------------------
   U_Si5345 : entity work.Si5345
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
         -- SPI Ports
         coreSclk       => pllSck,
         coreSDin       => pllSdo,
         coreSDout      => pllSdi,
         coreCsb        => pllCsL);

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
