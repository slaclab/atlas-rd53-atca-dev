-------------------------------------------------------------------------------
-- File       : BarrelShifter.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simple barrel shifter
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

entity BarrelShifter is
   generic (
      TPD_G          : time     := 1 ns;
      RST_POLARITY_G : sl       := '1';  -- '1' for active HIGH reset, '0' for active LOW reset
      WIDTH_G        : positive := 32);
   port (
      clk  : in  sl;
      rst  : in  sl := not RST_POLARITY_G;  -- Optional reset
      slip : in  sl;
      din  : in  slv(WIDTH_G-1 downto 0);
      dout : out slv(WIDTH_G-1 downto 0));
end entity BarrelShifter;

architecture rtl of BarrelShifter is

   constant CACHE_C : positive := 8;

   type RegType is record
      slip : sl;
      idx  : natural range 0 to CACHE_C*WIDTH_G-1;
      data : slv(CACHE_C*WIDTH_G-1 downto 0);
   end record RegType;
   constant REG_INIT_C : RegType := (
      slip => '0',
      idx  => 0,
      data => (others => '0'));

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (din, r, rst, slip) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Delay copy
      v.slip := slip;

      -- Check for delay event
      if (slip = '1') and (r.slip = '0') then
         v.idx := r.idx + 1;
         -- Check for max count
         if (v.idx = (CACHE_C-1)*WIDTH_G) then
            v.idx := 0;
         end if;
      end if;

      -- Add new data
      v.data := din & r.data(CACHE_C*WIDTH_G-1 downto WIDTH_G);

      -- Reset
      if (rst = RST_POLARITY_G) then
         v := REG_INIT_C;
      end if;

      -- Outputs
      dout <= r.data(r.idx+WIDTH_G-1 downto r.idx);

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
