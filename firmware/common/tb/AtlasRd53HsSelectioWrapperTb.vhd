-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the AtlasRd53HsSelectioWrapper module
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

entity AtlasRd53HsSelectioWrapperTb is end AtlasRd53HsSelectioWrapperTb;

architecture testbed of AtlasRd53HsSelectioWrapperTb is

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

   constant XIL_DEVICE_C : string := "ULTRASCALE";

   constant CLK_PERIOD_G : time := 10 ns;
   constant TPD_G        : time := CLK_PERIOD_G/4;

   signal clk : sl := '0';
   signal rst : sl := '1';

begin

   U_ClkRst : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_G,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => clk,
         rst  => rst);

   U_Selectio : entity work.AtlasRd53HsSelectioWrapper
      generic map(
         TPD_G                => TPD_G,
         SIMULATION_G         => true,
         NUM_CHIP_G           => 4,
         XIL_DEVICE_G         => XIL_DEVICE_C,
         RX_PHY_TO_APP_INIT_G => RX_PHY_TO_APP_INIT_C)
      port map (
         ref160Clk       => clk,
         ref160Rst       => rst,
         -- Deserialization Interface
         serDesData      => open,
         dlyLoad         => (others => '0'),
         dlyCfg          => (others => (others => '0')),
         iDelayCtrlRdy   => '1',
         -- mDP DATA Interface
         dPortDataP      => (others => (others => '0')),
         dPortDataN      => (others => (others => '1')),
         -- Timing Clock/Reset Interface
         clk160MHz       => open,
         rst160MHz       => open,
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => clk,
         axilRst         => rst,
         axilReadMaster  => AXI_LITE_READ_MASTER_INIT_C,
         axilReadSlave   => open,
         axilWriteMaster => AXI_LITE_WRITE_MASTER_INIT_C,
         axilWriteSlave  => open);

end testbed;
