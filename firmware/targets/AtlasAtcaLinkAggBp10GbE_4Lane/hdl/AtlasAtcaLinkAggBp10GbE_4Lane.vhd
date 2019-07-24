-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggBp10GbE_4Lane.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simple Firmware Example (backplane 10GBASE-KX4 (XAUI) only)
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggBp10GbE_4Lane is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      BUILD_INFO_G : BuildInfoType);
   port (
      --------------------- 
      --  Application Ports
      --------------------- 
      -- Jitter Cleaner PLL Ports
      fpgaToPllClkP    : out   sl;
      fpgaToPllClkN    : out   sl;
      pllToFpgaClkP    : in    sl;
      pllToFpgaClkN    : in    sl;
      -- Front Panel Clock/LED/TTL Ports
      smaClkP          : in    sl;
      smaClkN          : in    sl;
      ledRedL          : out   slv(1 downto 0) := "11";
      ledBlueL         : out   slv(1 downto 0) := "11";
      ledGreenL        : out   slv(1 downto 0) := "11";
      fpTrigInL        : in    sl;
      fpBusyOut        : out   sl              := '0';
      fpSpareOut       : out   sl              := '0';
      fpSpareInL       : in    sl;
      -- Backplane Clocks Ports
      bpClkIn          : in    slv(5 downto 0);
      bpClkOut         : out   slv(5 downto 0) := (others => '0');
      -- Front Panel QSFP+ Ports
      qsfpSpareRefClkP : in    sl;
      qsfpSpareRefClkN : in    sl;
      qsfpEthRefClkP   : in    sl;
      qsfpEthRefClkN   : in    sl;
      qsfpRef160ClkP   : in    sl;
      qsfpRef160ClkN   : in    sl;
      qsfpPllClkP      : in    sl;
      qsfpPllClkN      : in    sl;
      qsfpTxP          : out   Slv4Array(1 downto 0);
      qsfpTxN          : out   Slv4Array(1 downto 0);
      qsfpRxP          : in    Slv4Array(1 downto 0);
      qsfpRxN          : in    Slv4Array(1 downto 0);
      -- Front Panel SFP+ Ports
      sfpEthRefClkP    : in    sl;
      sfpEthRefClkN    : in    sl;
      sfpRef160ClkP    : in    sl;
      sfpRef160ClkN    : in    sl;
      sfpPllClkP       : in    sl;
      sfpPllClkN       : in    sl;
      sfpTxP           : out   slv(3 downto 0);
      sfpTxN           : out   slv(3 downto 0);
      sfpRxP           : in    slv(3 downto 0);
      sfpRxN           : in    slv(3 downto 0);
      -- RTM Ports
      rtmIo            : inout Slv8Array(3 downto 0);
      dpmToRtmP        : inout Slv16Array(3 downto 0);
      dpmToRtmN        : inout Slv16Array(3 downto 0);
      rtmToDpmP        : inout Slv16Array(3 downto 0);
      rtmToDpmN        : inout Slv16Array(3 downto 0);
      -------------------   
      --  Top Level Ports
      -------------------   
      -- Jitter Cleaner PLL Ports
      pllSpiCsL        : out   sl;
      pllSpiSclk       : out   sl;
      pllSpiSdi        : out   sl;
      pllSpiSdo        : in    sl;
      pllSpiRstL       : out   sl;
      pllSpiOeL        : out   sl;
      pllIntrL         : in    sl;
      pllLolL          : in    sl;
      pllClkScl        : inout sl;
      pllClkSda        : inout sl;
      -- Front Panel I2C Ports
      fpScl            : inout sl;
      fpSda            : inout sl;
      sfpScl           : inout slv(3 downto 0);
      sfpSda           : inout slv(3 downto 0);
      qsfpScl          : inout slv(1 downto 0);
      qsfpSda          : inout slv(1 downto 0);
      -- Front Panel: ETH[1:0] SGMII Ports
      sgmiiClkP        : in    sl;
      sgmiiClkN        : in    sl;
      sgmiiRxP         : in    slv(1 downto 0);
      sgmiiRxN         : in    slv(1 downto 0);
      sgmiiTxP         : out   slv(1 downto 0);
      sgmiiTxN         : out   slv(1 downto 0);
      -- ATCA Backplane: FABRIC ETH[1:4]
      fabEthRefClkP    : in    sl;
      fabEthRefClkN    : in    sl;
      fabEthTxP        : out   Slv4Array(4 downto 1);
      fabEthTxN        : out   Slv4Array(4 downto 1);
      fabEthRxP        : in    Slv4Array(4 downto 1);
      fabEthRxN        : in    Slv4Array(4 downto 1);
      -- IMPC Ports
      ipmcScl          : inout sl;
      ipmcSda          : inout sl;
      -- SYSMON Ports
      vPIn             : in    sl;
      vNIn             : in    sl);
end AtlasAtcaLinkAggBp10GbE_4Lane;

architecture top_level of AtlasAtcaLinkAggBp10GbE_4Lane is

   constant MY_ETH_CONFIG_INIT_C : EthConfigType := (
      enable      => true,
      enDhcp      => true,
      enXvc       => true,              -- Using remote XVC module
      enSrp       => true,
      fabConfig   => ETH_10G_4LANE,
      -- Streaming Data Server Configurations
      numSrvData  => 0,
      enSrvDataTx => false,
      enSrvDataRx => false,
      -- Streaming Data Client Configurations
      numCltData  => 0,
      enCltDataTx => false,
      enCltDataRx => false);

   constant ETH_CONFIG_C : EthConfigArray := (
      ETH_FAB1_IDX_C => MY_ETH_CONFIG_INIT_C,
      ETH_FAB2_IDX_C => ETH_PORT_DISABLED_C,
      ETH_FAB3_IDX_C => ETH_PORT_DISABLED_C,
      ETH_FAB4_IDX_C => ETH_PORT_DISABLED_C,
      ETH_FP0_IDX_C  => ETH_PORT_DISABLED_C,
      ETH_FP1_IDX_C  => ETH_PORT_DISABLED_C);

   component ibert_ultrascale_gty_10Gbps
      port (
         txn_o             : out std_logic_vector(3 downto 0);
         txp_o             : out std_logic_vector(3 downto 0);
         rxn_i             : in  std_logic_vector(3 downto 0);
         rxp_i             : in  std_logic_vector(3 downto 0);
         gtrefclk0_i       : in  std_logic_vector(0 downto 0);
         gtrefclk1_i       : in  std_logic_vector(0 downto 0);
         gtnorthrefclk0_i  : in  std_logic_vector(0 downto 0);
         gtnorthrefclk1_i  : in  std_logic_vector(0 downto 0);
         gtsouthrefclk0_i  : in  std_logic_vector(0 downto 0);
         gtsouthrefclk1_i  : in  std_logic_vector(0 downto 0);
         gtrefclk00_i      : in  std_logic_vector(0 downto 0);
         gtrefclk10_i      : in  std_logic_vector(0 downto 0);
         gtrefclk01_i      : in  std_logic_vector(0 downto 0);
         gtrefclk11_i      : in  std_logic_vector(0 downto 0);
         gtnorthrefclk00_i : in  std_logic_vector(0 downto 0);
         gtnorthrefclk10_i : in  std_logic_vector(0 downto 0);
         gtnorthrefclk01_i : in  std_logic_vector(0 downto 0);
         gtnorthrefclk11_i : in  std_logic_vector(0 downto 0);
         gtsouthrefclk00_i : in  std_logic_vector(0 downto 0);
         gtsouthrefclk10_i : in  std_logic_vector(0 downto 0);
         gtsouthrefclk01_i : in  std_logic_vector(0 downto 0);
         gtsouthrefclk11_i : in  std_logic_vector(0 downto 0);
         clk               : in  std_logic
         );
   end component;

   signal gtRefClock0 : slv(0 downto 0);
   signal gtRefClock1 : slv(0 downto 0);

   signal ref156Clk : sl;
   signal ref156Rst : sl;

   signal sysclk     : sl;
   signal sysclkBufg : sl;

   signal srvMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal srvSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);
   signal cltMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal cltSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);

begin

   fpBusyOut  <= not(fpTrigInL);
   fpSpareOut <= not(fpSpareInL);

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

   -----------------------
   -- GT REFCLK
   -----------------------         
   U_GT_REF_CLK0 : IBUFDS_GTE4
      port map (
         I     => qsfpEthRefClkP,
         IB    => qsfpEthRefClkN,
         CEB   => '0',
         ODIV2 => sysclk,
         O     => gtRefClock0(0));

   U_GT_REF_CLK1 : IBUFDS_GTE4
      port map (
         I     => qsfpSpareRefClkP,
         IB    => qsfpSpareRefClkN,
         CEB   => '0',
         ODIV2 => open,
         O     => gtRefClock1(0));

   U_sysclk : BUFG_GT
      port map (
         I       => sysclk,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => sysclkBufg);

   -----------------------
   -- IBERT IP Core
   ----------------------- 
   U_IBERT : ibert_ultrascale_gty_10Gbps
      port map (
         TXN_O             => qsfpTxN(1),
         TXP_O             => qsfpTxP(1),
         RXN_I             => qsfpRxN(1),
         RXP_I             => qsfpRxP(1),
         clk               => sysclkBufg,
         GTREFCLK0_I       => gtRefClock0,
         GTREFCLK1_I       => gtRefClock1,
         gtnorthrefclk0_i  => (others => '0'),
         gtnorthrefclk1_i  => (others => '0'),
         gtsouthrefclk0_i  => (others => '0'),
         gtsouthrefclk1_i  => (others => '0'),
         gtrefclk00_i      => gtRefClock0,
         gtrefclk10_i      => gtRefClock1,
         gtrefclk01_i      => (others => '0'),
         gtrefclk11_i      => (others => '0'),
         gtnorthrefclk00_i => (others => '0'),
         gtnorthrefclk10_i => (others => '0'),
         gtnorthrefclk01_i => (others => '0'),
         gtnorthrefclk11_i => (others => '0'),
         gtsouthrefclk00_i => (others => '0'),
         gtsouthrefclk10_i => (others => '0'),
         gtsouthrefclk01_i => (others => '0'),
         gtsouthrefclk11_i => (others => '0'));

   GEN_QSFP :
   for i in 0 downto 0 generate
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

   U_Core : entity work.AtlasAtcaLinkAggCore
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         BUILD_INFO_G => BUILD_INFO_G,
         ETH_CONFIG_G => ETH_CONFIG_C)
      port map (
         -----------------------------
         --  Interfaces to Application
         -----------------------------
         -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
         axilClk         => open,
         axilRst         => open,
         axilReadMaster  => open,
         axilReadSlave   => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C,
         axilWriteMaster => open,
         axilWriteSlave  => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C,
         -- Server Streaming Interface (axilClk domain)
         srvIbMasters    => srvMasters,  -- Loopback
         srvIbSlaves     => srvSlaves,   -- Loopback
         srvObMasters    => srvMasters,  -- Loopback
         srvObSlaves     => srvSlaves,   -- Loopback
         -- Client Streaming Interface (axilClk domain)
         cltIbMasters    => cltMasters,  -- Loopback
         cltIbSlaves     => cltSlaves,   -- Loopback
         cltObMasters    => cltMasters,  -- Loopback
         cltObSlaves     => cltSlaves,   -- Loopback
         -- Misc. Interface 
         ref156Clk       => ref156Clk,
         ref156Rst       => ref156Rst,
         ipmiBsi         => open,
         ledRedL         => ledRedL,
         ledBlueL        => ledBlueL,
         ledGreenL       => ledGreenL,
         -------------------   
         --  Top Level Ports
         -------------------   
         -- Jitter Cleaner PLL Ports
         pllSpiCsL       => pllSpiCsL,
         pllSpiSclk      => pllSpiSclk,
         pllSpiSdi       => pllSpiSdi,
         pllSpiSdo       => pllSpiSdo,
         pllSpiRstL      => pllSpiRstL,
         pllSpiOeL       => pllSpiOeL,
         pllIntrL        => pllIntrL,
         pllLolL         => pllLolL,
         pllClkScl       => pllClkScl,
         pllClkSda       => pllClkSda,
         -- Front Panel I2C Ports
         fpScl           => fpScl,
         fpSda           => fpSda,
         sfpScl          => sfpScl,
         sfpSda          => sfpSda,
         qsfpScl         => qsfpScl,
         qsfpSda         => qsfpSda,
         -- Front Panel: ETH[1:0] SGMII Ports
         sgmiiClkP       => sgmiiClkP,
         sgmiiClkN       => sgmiiClkN,
         sgmiiTxP        => sgmiiTxP,
         sgmiiTxN        => sgmiiTxN,
         sgmiiRxP        => sgmiiRxP,
         sgmiiRxN        => sgmiiRxN,
         -- ATCA Backplane: FABRIC ETH[1:4]
         fabEthRefClkP   => fabEthRefClkP,
         fabEthRefClkN   => fabEthRefClkN,
         fabEthTxP       => fabEthTxP,
         fabEthTxN       => fabEthTxN,
         fabEthRxP       => fabEthRxP,
         fabEthRxN       => fabEthRxN,
         -- IMPC Ports
         ipmcScl         => ipmcScl,
         ipmcSda         => ipmcSda,
         -- SYSMON Ports
         vPIn            => vPIn,
         vNIn            => vNIn);

end top_level;
