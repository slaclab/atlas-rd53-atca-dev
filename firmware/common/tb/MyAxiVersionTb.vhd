-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the MyAxiVersionTb module
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;


library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

library ruckus;
use ruckus.BuildInfoPkg.all;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

entity MyAxiVersionTb is end MyAxiVersionTb;

architecture testbed of MyAxiVersionTb is

   constant GET_BUILD_INFO_C : BuildInfoRetType := toBuildInfo(BUILD_INFO_C);
   constant MOD_BUILD_INFO_C : BuildInfoRetType := (
      buildString => GET_BUILD_INFO_C.buildString,
      fwVersion   => GET_BUILD_INFO_C.fwVersion,
      gitHash     => x"1111_2222_3333_4444_5555_6666_7777_8888_9999_AAAA");  -- Force githash
   constant SIM_BUILD_INFO_C : slv(2239 downto 0) := toSlv(MOD_BUILD_INFO_C);

   constant CLK_PERIOD_G : time := 10 ns;
   constant TPD_G        : time := CLK_PERIOD_G/4;

   constant ETH_CONFIG_C : EthConfigArray := (
      -----------------------------------------------------------------------------------
      ETH_FAB1_IDX_C => ETH_PORT_DISABLED_C,  -- Disabling slot#2 communication
      ETH_FAB2_IDX_C => ETH_PORT_DISABLED_C,  -- Disabling slot#2 communication
      ETH_FAB3_IDX_C => ETH_PORT_DISABLED_C,  -- Disabling slot#3 communication
      ETH_FAB4_IDX_C => ETH_PORT_DISABLED_C,  -- Disabling slot#4 communication
      -----------------------------------------------------------------------------------
      ETH_FP0_IDX_C  => ETH_PORT_SRP_ONLY_C,  -- Using Front Panel SFP for SRPv3 configuration only
      ETH_FP1_IDX_C  => ETH_PORT_SRP_ONLY_C);  -- Using Front Panel SFP for SRPv3 configuration only   

   function genRouteTable
      return slv is
      variable retVar : slv(15 downto 0);
   begin
      retVar := x"0000";
      for i in NUM_ETH_C-1 downto 0 loop
         if (ETH_CONFIG_C(i).enable) and (ETH_CONFIG_C(i).enSrp) then
            retVar(i) := '1';
         end if;
      end loop;
      return retVar;
   end function;
   constant M_AXIL_CONNECT_C : slv(15 downto 0) := genRouteTable;

   constant NUM_AXIL_MASTERS_C : positive := 4;

   constant BASE_INDEX_C    : natural := 0;
   constant PLL_SPI_INDEX_C : natural := 1;
   constant ETH_INDEX_C     : natural := 2;
   constant APP_INDEX_C     : natural := 3;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      BASE_INDEX_C    => (
         baseAddr     => x"0000_0000",
         addrBits     => 16,
         connectivity => M_AXIL_CONNECT_C),
      PLL_SPI_INDEX_C => (
         baseAddr     => x"0001_0000",
         addrBits     => 16,
         connectivity => M_AXIL_CONNECT_C),
      ETH_INDEX_C     => (
         baseAddr     => x"0100_0000",
         addrBits     => 24,
         connectivity => M_AXIL_CONNECT_C),
      APP_INDEX_C     => (
         baseAddr     => APP_AXIL_BASE_ADDR_C,
         addrBits     => 31,
         connectivity => M_AXIL_CONNECT_C));

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_SLVERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_SLVERR_C);

   signal mAxilReadMasters  : AxiLiteReadMasterArray(NUM_ETH_C-1 downto 0)  := (others => AXI_LITE_READ_MASTER_INIT_C);
   signal mAxilReadSlaves   : AxiLiteReadSlaveArray(NUM_ETH_C-1 downto 0)   := (others => AXI_LITE_READ_SLAVE_INIT_C);
   signal mAxilWriteMasters : AxiLiteWriteMasterArray(NUM_ETH_C-1 downto 0) := (others => AXI_LITE_WRITE_MASTER_INIT_C);
   signal mAxilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_ETH_C-1 downto 0)  := (others => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal axilClk : sl := '0';
   signal axilRst : sl := '0';

begin

   --------------------
   -- Clocks and Resets
   --------------------
   U_axilClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_G,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => axilClk,
         rst  => axilRst);

   --------------------------
   -- AXI-Lite: Crossbar Core
   --------------------------  
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => NUM_ETH_C,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk           => axilClk,
         axiClkRst        => axilRst,
         sAxiWriteMasters => mAxilWriteMasters,
         sAxiWriteSlaves  => mAxilWriteSlaves,
         sAxiReadMasters  => mAxilReadMasters,
         sAxiReadSlaves   => mAxilReadSlaves,
         mAxiWriteMasters => axilWriteMasters,
         mAxiWriteSlaves  => axilWriteSlaves,
         mAxiReadMasters  => axilReadMasters,
         mAxiReadSlaves   => axilReadSlaves);

   -----------------------
   -- Module to be tested
   -----------------------
   U_Version : entity surf.AxiVersion
      generic map (
         TPD_G        => TPD_G,
         BUILD_INFO_G => SIM_BUILD_INFO_C)
      port map (
         -- AXI-Lite Interface
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(APP_INDEX_C),
         axiReadSlave   => axilReadSlaves(APP_INDEX_C),
         axiWriteMaster => axilWriteMasters(APP_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(APP_INDEX_C));

   ---------------------------------
   -- AXI-Lite Register Transactions
   ---------------------------------
   test : process is
      variable debugData : slv(31 downto 0) := (others => '0');
   begin
      debugData := x"1111_1111";
      ------------------------------------------
      -- Wait for the AXI-Lite reset to complete
      ------------------------------------------
      wait until axilRst = '1';
      wait until axilRst = '0';

      axiLiteBusSimRead (axilClk, mAxilReadMasters(NUM_ETH_C-1), mAxilReadSlaves(NUM_ETH_C-1), x"8000_0600", debugData, true);
      axiLiteBusSimRead (axilClk, mAxilReadMasters(NUM_ETH_C-1), mAxilReadSlaves(NUM_ETH_C-1), x"8000_0604", debugData, true);
      axiLiteBusSimRead (axilClk, mAxilReadMasters(NUM_ETH_C-1), mAxilReadSlaves(NUM_ETH_C-1), x"8000_0608", debugData, true);
      axiLiteBusSimRead (axilClk, mAxilReadMasters(NUM_ETH_C-1), mAxilReadSlaves(NUM_ETH_C-1), x"8000_060C", debugData, true);
      axiLiteBusSimRead (axilClk, mAxilReadMasters(NUM_ETH_C-1), mAxilReadSlaves(NUM_ETH_C-1), x"8000_0610", debugData, true);


      axiLiteBusSimWrite (axilClk, mAxilWriteMasters(NUM_ETH_C-1), mAxilWriteSlaves(NUM_ETH_C-1), x"8000_0004", x"1234_5678", true);
      axiLiteBusSimWrite (axilClk, mAxilWriteMasters(NUM_ETH_C-1), mAxilWriteSlaves(NUM_ETH_C-1), x"8000_0000", x"1234_5678", true);

   end process test;

end testbed;
