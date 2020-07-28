-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
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

library surf;
use surf.StdRtlPkg.all;

entity RxPhyMux is
   generic (
      TPD_G : time := 1 ns);
   port (
      clk            : in  sl;
      phyToAppRemap  : in  Slv7Array(127 downto 0);
      appToPhyRemap  : in  Slv7Array(127 downto 0);
      -- Application Interface
      serDesData_app : out Slv8Array(127 downto 0);
      dlyLoad_app    : in  slv(127 downto 0);
      dlyCfg_app     : in  Slv9Array(127 downto 0);
      -- PHY Interface
      serDesData_phy : in  Slv8Array(127 downto 0);
      dlyLoad_phy    : out slv(127 downto 0);
      dlyCfg_phy     : out Slv9Array(127 downto 0));
end RxPhyMux;

architecture rtl of RxPhyMux is

   signal serDesData_app_transpose : Slv128Array(7 downto 0);
   signal serDesData_phy_transpose : Slv128Array(7 downto 0);

   signal dlyCfg_app_transpose : Slv128Array(8 downto 0);
   signal dlyCfg_phy_transpose : Slv128Array(8 downto 0);

begin

   GEN_PHY_TO_APP :
   for i in 127 downto 0 generate

      GEN_DATA :
      for j in 7 downto 0 generate

         serDesData_phy_transpose(j)(i) <= serDesData_phy(i)(j);

         U_serDesData : entity surf.Mux
            generic map (
               TPD_G       => TPD_G,
               SEL_WIDTH_G => 7)
            port map (
               clk  => clk,
               sel  => phyToAppRemap(i),
               din  => serDesData_phy_transpose(j),
               dout => serDesData_app_transpose(j)(i));

         serDesData_app(i)(j) <= serDesData_app_transpose(j)(i);

      end generate GEN_DATA;

   end generate GEN_PHY_TO_APP;

   GEN_APP_TO_PHY :
   for i in 127 downto 0 generate

      U_dlyLoad : entity surf.Mux
         generic map (
            TPD_G       => TPD_G,
            SEL_WIDTH_G => 7)
         port map (
            clk  => clk,
            sel  => appToPhyRemap(i),
            din  => dlyLoad_app,
            dout => dlyLoad_phy(i));

      GEN_CONFIG :
      for j in 8 downto 0 generate

         dlyCfg_app_transpose(j)(i) <= dlyCfg_app(i)(j);

         U_dlyCfg : entity surf.Mux
            generic map (
               TPD_G       => TPD_G,
               SEL_WIDTH_G => 7)
            port map (
               clk  => clk,
               sel  => appToPhyRemap(i),
               din  => dlyCfg_app_transpose(j),
               dout => dlyCfg_phy_transpose(j)(i));

         dlyCfg_phy(i)(j) <= dlyCfg_phy_transpose(j)(i);

      end generate GEN_CONFIG;

   end generate GEN_APP_TO_PHY;

end rtl;
