-------------------------------------------------------------------------------
-- File       : AtlasRd53SelectioPll.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: SelectIO PLL
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS RD53 DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53SelectioPll is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      ref160Clk : in  sl;
      ref160Rst : in  sl;
      -- Timing Clock/Reset Interface
      clk640MHz : out slv(5 downto 0);
      clk160MHz : out slv(5 downto 0);
      rst160MHz : out slv(5 downto 0));
end AtlasRd53SelectioPll;

architecture mapping of AtlasRd53SelectioPll is

   signal locked  : sl := '0';
   signal clkFb   : sl := '0';
   signal clkout0 : sl := '0';

   signal clock640MHz : sl := '0';
   signal clock160MHz : sl := '0';
   signal reset       : sl := '1';
   signal reset160MHz : sl := '1';

begin

   clk640MHz <= (others => clock640MHz);
   clk160MHz <= (others => clock160MHz);
   rst160MHz <= (others => reset160MHz);

   GEN_REAL : if (SIMULATION_G = false) generate
      U_PLL : PLLE3_ADV
         generic map (
            CLKOUTPHY_MODE => "VCO",
            COMPENSATION   => "INTERNAL",
            STARTUP_WAIT   => "FALSE",
            CLKIN_PERIOD   => 6.256,    -- 160 MHz
            DIVCLK_DIVIDE  => 2,
            CLKFBOUT_MULT  => 16,       -- 1.28 GHz = 160 MHz x 16 / 2 
            CLKOUT0_DIVIDE => 2,        -- 640 MHz = 1.28 GHz/2
            CLKOUT1_DIVIDE => 8)        -- 160 MHz = 1.28 GHz/8
         port map (
            DCLK        => '0',
            DRDY        => open,
            DEN         => '0',
            DWE         => '0',
            DADDR       => (others => '0'),
            DI          => (others => '0'),
            DO          => open,
            PWRDWN      => '0',
            RST         => ref160Rst,
            CLKIN       => ref160Clk,
            CLKOUTPHYEN => '1',
            CLKFBOUT    => clkFb,
            CLKFBIN     => clkFb,
            LOCKED      => locked,
            CLKOUT0     => clkout0,
            CLKOUT1     => open);
   end generate GEN_REAL;

   GEN_SIM : if (SIMULATION_G = true) generate
      U_ClkRst : entity work.ClkRst
         generic map (
            CLK_PERIOD_G      => 1.5625 ns,  -- 640 MHz
            RST_START_DELAY_G => 0 ns,
            RST_HOLD_TIME_G   => 1000 ns)
         port map (
            clkP => clkout0,
            rstL => locked);
   end generate GEN_SIM;

   U_Bufg640 : BUFG
      port map (
         I => clkout0,
         O => clock640MHz);

   ------------------------------------------------------------------------------------------------------
   -- 160 MHz is the ISERDESE3/OSERDESE3's CLKDIV port
   -- Refer to "Figure 3-49: Sub-Optimal to Optimal Clocking Topologies for OSERDESE3" in UG949 (v2018.2)
   -- https://www.xilinx.com/support/answers/67885.html   
   ------------------------------------------------------------------------------------------------------
   U_Bufg160 : BUFGCE_DIV
      generic map (
         IS_CE_INVERTED  => '0',
         IS_CLR_INVERTED => '1',
         BUFGCE_DIVIDE   => 4)          -- 160 MHz = 640 MHz/4
      port map (
         I   => clkout0,                -- 640 MHz
         CE  => locked,
         CLR => locked,
         O   => clock160MHz);           -- 160 MHz

   U_Rst160 : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => clock160MHz,
         asyncRst => locked,
         syncRst  => reset);

   U_Reset : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clock160MHz,
         rstIn  => reset,
         rstOut => reset160MHz);

end mapping;
