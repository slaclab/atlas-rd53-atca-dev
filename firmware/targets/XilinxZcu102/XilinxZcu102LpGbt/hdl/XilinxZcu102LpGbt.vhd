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
use work.RceG3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity XilinxZcu102LpGbt is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- FMC Interface
      gtRefClk320P : in  sl;            -- FMC_HPC0_GBTCLK0_M2C_C_P
      gtRefClk320N : in  sl;            -- FMC_HPC0_GBTCLK0_M2C_C_N
      userClk156P  : in  sl;            -- USER_MGT_SI570_CLOCK1_C_P
      userClk156N  : in  sl;            -- USER_MGT_SI570_CLOCK1_C_N
      -- SFP Interface
      sfpEnTx      : out slv(3 downto 0) := x"F";
      sfpTxP       : out slv(3 downto 0);
      sfpTxN       : out slv(3 downto 0);
      sfpRxP       : in  slv(3 downto 0);
      sfpRxN       : in  slv(3 downto 0));
end XilinxZcu102LpGbt;

architecture TOP_LEVEL of XilinxZcu102LpGbt is

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
   signal userClk156     : sl;
   signal userClk156Bufg : sl;

begin

   --------------------------------
   -- 320 MHz LpGBT Reference Clock
   --------------------------------
   U_gtRefClk320 : IBUFDS_GTE4
      port map (
         I     => gtRefClk320P,
         IB    => gtRefClk320N,
         CEB   => '0',
         ODIV2 => open,
         O     => gtRefClk320);

   --------------------------------
   -- 156.25 MHz DMA/AXI-Lite Clock
   --------------------------------
   U_userClk156 : IBUFDS_GTE4
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

   U_BUFG_GT : BUFG_GT
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

   ------------------
   -- SFP LpGBT Lanes
   ------------------
   GEN_SFP :
   for i in 3 downto 0 generate
      U_LpGbtLane : entity work.XilinxZcu102LpGbtLane
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
            gtRefClk320     => gtRefClk320,
            sfpTxP          => sfpTxP(i),
            sfpTxN          => sfpTxN(i),
            sfpRxP          => sfpRxP(i),
            sfpRxN          => sfpRxN(i));
   end generate GEN_SFP;

end TOP_LEVEL;
