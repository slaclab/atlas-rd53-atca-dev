-------------------------------------------------------------------------------
-- File       : AtlasRd53RtmSimMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RTM mapping
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
use work.AxiStreamPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53RtmSimMapping is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- mDP DATA/CMD Interface
      dPortDataP : in    Slv4Array(23 downto 0) := (others => x"0");
      dPortDataN : in    Slv4Array(23 downto 0) := (others => x"F");
      dPortCmdP  : out   slv(23 downto 0)       := (others => '0');
      dPortCmdN  : out   slv(23 downto 0)       := (others => '1');
      -- RTM Ports (188 diff. pairs to RTM interface)
      rtmIo      : inout Slv8Array(3 downto 0)  := (others => x"00");
      dpmToRtmP  : inout Slv16Array(3 downto 0) := (others => x"0000");
      dpmToRtmN  : inout Slv16Array(3 downto 0) := (others => x"FFFF");
      rtmToDpmP  : inout Slv16Array(3 downto 0) := (others => x"0000");
      rtmToDpmN  : inout Slv16Array(3 downto 0) := (others => x"FFFF"));
end AtlasRd53RtmSimMapping;

architecture mapping of AtlasRd53RtmSimMapping is

begin

   GEN_DPM :
   for dpm in 3 downto 0 generate

      GEN_VEC :
      for i in 2 downto 0 generate

         dPortCmdP(6*dpm+0+i) <= dpmToRtmP(dpm)(i+12);
         dPortCmdN(6*dpm+0+i) <= dpmToRtmN(dpm)(i+12);

         dpmToRtmP(dpm)(i*4+0) <= dPortDataN(6*dpm+0+i)(0);  -- Inverted in layout
         dpmToRtmN(dpm)(i*4+0) <= dPortDataP(6*dpm+0+i)(0);  -- Inverted in layout

         dpmToRtmP(dpm)(i*4+1) <= dPortDataN(6*dpm+0+i)(1);  -- Inverted in layout
         dpmToRtmN(dpm)(i*4+1) <= dPortDataP(6*dpm+0+i)(1);  -- Inverted in layout

         dpmToRtmP(dpm)(i*4+2) <= dPortDataN(6*dpm+0+i)(2);  -- Inverted in layout
         dpmToRtmN(dpm)(i*4+2) <= dPortDataP(6*dpm+0+i)(2);  -- Inverted in layout

         dpmToRtmP(dpm)(i*4+3) <= dPortDataN(6*dpm+0+i)(3);  -- Inverted in layout
         dpmToRtmN(dpm)(i*4+3) <= dPortDataP(6*dpm+0+i)(3);  -- Inverted in layout

         dPortCmdP(6*dpm+3+i) <= rtmToDpmP(dpm)(i+12);
         dPortCmdN(6*dpm+3+i) <= rtmToDpmN(dpm)(i+12);

         rtmToDpmP(dpm)(i*4+0) <= dPortDataN(6*dpm+3+i)(0);  -- Inverted in layout
         rtmToDpmN(dpm)(i*4+0) <= dPortDataP(6*dpm+3+i)(0);  -- Inverted in layout

         rtmToDpmP(dpm)(i*4+1) <= dPortDataN(6*dpm+3+i)(1);  -- Inverted in layout
         rtmToDpmN(dpm)(i*4+1) <= dPortDataP(6*dpm+3+i)(1);  -- Inverted in layout

         rtmToDpmP(dpm)(i*4+2) <= dPortDataN(6*dpm+3+i)(2);  -- Inverted in layout
         rtmToDpmN(dpm)(i*4+2) <= dPortDataP(6*dpm+3+i)(2);  -- Inverted in layout

         rtmToDpmP(dpm)(i*4+3) <= dPortDataN(6*dpm+3+i)(3);  -- Inverted in layout
         rtmToDpmN(dpm)(i*4+3) <= dPortDataP(6*dpm+3+i)(3);  -- Inverted in layout

      end generate GEN_VEC;

   end generate GEN_DPM;

end mapping;
