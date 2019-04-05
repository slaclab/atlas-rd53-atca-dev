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
      ref156Clk     : in  sl;
      ref156Rst     : in  sl;
      ref160ClkP    : in  sl;
      ref160ClkN    : in  sl;
      -- Timing Clock/Reset Interface
      iDelayCtrlRdy : out sl;
      clk640MHz     : out sl;
      clk160MHz     : out sl;
      rst160MHz     : out sl);
end AtlasRd53SelectioPll;

architecture mapping of AtlasRd53SelectioPll is

   signal ref160Clock : sl;
   signal ref160Clk   : sl;

   signal clk300MHz : sl := '0';
   signal rst300MHz : sl := '1';
   signal ref160Rst : sl := '1';
   signal locked    : sl := '0';
   signal pllClock  : sl := '0';
   signal reset     : sl := '1';
   signal clkFb     : sl := '0';
   signal clkout0   : sl := '0';
   signal clkout1   : sl := '0';

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "xapp_idelay";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   U_MMCM : entity work.ClockManagerUltraScale
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
         clkIn     => ref156Clk,
         rstIn     => ref156Rst,
         clkOut(0) => clk300MHz,
         rstOut(0) => rst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => clk300MHz,
         RST    => rst300MHz);

   U_IBUFDS_GTE4 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => ref160ClkP,
         IB    => ref160ClkN,
         CEB   => '0',
         ODIV2 => ref160Clock,
         O     => open);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => ref160Clock,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => ref160Clk);

   U_ref160Rst : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ref160Clk,
         rstIn  => ref156Rst,
         rstOut => ref160Rst);

   GEN_REAL : if (SIMULATION_G = false) generate
      U_PLL : PLLE3_ADV
         generic map (
            COMPENSATION       => "AUTO",
            STARTUP_WAIT       => "FALSE",
            CLKIN_PERIOD       => 6.256,  -- 160 MHz
            DIVCLK_DIVIDE      => 1,
            CLKFBOUT_MULT      => 8,      -- 1.28 GHz = 160 MHz x 8
            CLKOUT0_DIVIDE     => 2,      -- 640 MHz = 1.28 GHz/2
            CLKOUT1_DIVIDE     => 8,      -- 160 MHz = 1.28 GHz/8
            CLKOUT0_PHASE      => 0.0,
            CLKOUT1_PHASE      => 0.0,
            CLKOUT0_DUTY_CYCLE => 0.5,
            CLKOUT1_DUTY_CYCLE => 0.5)
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
            CLKOUTPHYEN => '0',
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
         O => clk640MHz);

   ------------------------------------------------------------------------------------------------------
   -- 160 MHz is the ISERDESE3/OSERDESE3's CLKDIV port
   -- Refer to "Figure 3-49: Sub-Optimal to Optimal Clocking Topologies for OSERDESE3" in UG949 (v2018.2)
   ------------------------------------------------------------------------------------------------------
   U_Bufg160 : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)            -- 160 MHz = 640 MHz/4
      port map (
         I   => clkout0,                -- 640 MHz
         CE  => '1',
         CLR => '0',
         O   => clkout1);               -- 160 MHz

   U_Rst160 : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => clkout1,
         asyncRst => locked,
         syncRst  => reset);

   U_Reset : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clkout1,
         rstIn  => reset,
         rstOut => rst160MHz);

   clk160MHz <= clkout1;

end mapping;
