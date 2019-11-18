-------------------------------------------------------------------------------
-- File       : LpGbt2EmuLpGbt_LinkingWithGthTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the GTH Linking Up
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

use work.StdRtlPkg.all;

entity LpGbt2EmuLpGbt_LinkingWithGthTb is
end LpGbt2EmuLpGbt_LinkingWithGthTb;

architecture testbed of LpGbt2EmuLpGbt_LinkingWithGthTb is

   signal downlinkCnt : Slv36Array(1 downto 0)  := (others => (others => '0'));
   signal uplinkCnt   : Slv234Array(1 downto 0) := (others => (others => '0'));

   signal downlinkClk   : slv(1 downto 0) := (others => '0');
   signal downlinkClkEn : slv(1 downto 0) := (others => '0');
   signal downlinkReady : slv(1 downto 0) := (others => '0');

   signal uplinkClk   : slv(1 downto 0) := (others => '0');
   signal uplinkClkEn : slv(1 downto 0) := (others => '0');
   signal uplinkReady : slv(1 downto 0) := (others => '0');

   signal refClk320 : sl := '0';
   signal axilClk   : sl := '0';
   signal usrRst    : sl := '1';

   signal gtEmuToLpP : sl := '0';
   signal gtEmuToLpN : sl := '1';

   signal gtLpToEmuP : sl := '0';
   signal gtLpToEmuN : sl := '1';

   signal clkEnCnt : slv(2 downto 0) := (others => '0');
   signal clkEn    : sl              := '0';

begin

   process(refClk320)
   begin
      if rising_edge(refClk320) then
         if clkEnCnt = 0 then
            clkEn <= '1' after 1 ns;
            if (downlinkReady = "11") then
               downlinkCnt(0) <= downlinkCnt(0) + 1 after 1 ns;
            end if;
            if (uplinkReady = "11") then
               uplinkCnt(1) <= uplinkCnt(1) + 1 after 1 ns;
            end if;
         else
            clkEn <= '0' after 1 ns;
         end if;
         clkEnCnt <= clkEnCnt + 1 after 1 ns;
      end if;
   end process;

   ---------------------------
   -- Generate clock and reset
   ---------------------------
   U_refClk320 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 3.125 ns,  -- 320 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 100 us)
      port map (
         clkP => refClk320,
         rst  => usrRst);

   U_axilClk : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,   -- 156.25 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1 us)
      port map (
         clkP => axilClk);

   -------------
   -- LpGBT FPGA
   -------------
   U_LpGbtFpga10g24 : entity work.LpGbtFpga10g24
      port map (
         -- Down link
         donwlinkClk_o       => downlinkClk(0),
         downlinkClkEn_o     => downlinkClkEn(0),
         downlinkRst_i       => usrRst,
         downlinkUserData_i  => downlinkCnt(0)(31 downto 0),
         downlinkEcData_i    => downlinkCnt(0)(33 downto 32),
         downlinkIcData_i    => downlinkCnt(0)(35 downto 34),
         downlinkReady_o     => downlinkReady(0),
         -- Up link
         uplinkClk_o         => uplinkClk(0),
         uplinkClkEn_o       => uplinkClkEn(0),
         uplinkRst_i         => usrRst,
         uplinkUserData_o    => uplinkCnt(0)(229 downto 0),
         uplinkEcData_o      => uplinkCnt(0)(231 downto 230),
         uplinkIcData_o      => uplinkCnt(0)(233 downto 232),
         uplinkReady_o       => uplinkReady(0),
         -- MGT
         clk_refclk_i        => refClk320,
         clk_mgtrefclk_i     => refClk320,
         clk_mgtfreedrpclk_i => axilClk,
         mgt_rxn_i           => gtEmuToLpN,
         mgt_rxp_i           => gtEmuToLpP,
         mgt_txn_o           => gtLpToEmuN,
         mgt_txp_o           => gtLpToEmuP);

   -----------------------
   -- Emulation LpGBT FPGA
   -----------------------
   U_EmuLpGbtFpga10g24 : entity work.EmuLpGbtFpga10g24
      port map (
         -- Up link
         uplinkClk_o         => uplinkClk(1),
         uplinkClkEn_o       => uplinkClkEn(1),
         uplinkRst_i         => usrRst,
         uplinkUserData_i    => uplinkCnt(1)(229 downto 0),
         uplinkEcData_i      => uplinkCnt(1)(231 downto 230),
         uplinkIcData_i      => uplinkCnt(1)(233 downto 232),
         uplinkReady_o       => uplinkReady(1),
         -- Down link
         donwlinkClk_o       => downlinkClk(1),
         downlinkClkEn_o     => downlinkClkEn(1),
         downlinkRst_i       => usrRst,
         downlinkUserData_o  => downlinkCnt(1)(31 downto 0),
         downlinkEcData_o    => downlinkCnt(1)(33 downto 32),
         downlinkIcData_o    => downlinkCnt(1)(35 downto 34),
         downlinkReady_o     => downlinkReady(1),
         -- MGT
         clk_refclk_i        => refClk320,
         clk_mgtrefclk_i     => refClk320,
         clk_mgtfreedrpclk_i => axilClk,
         mgt_rxn_i           => gtLpToEmuN,
         mgt_rxp_i           => gtLpToEmuP,
         mgt_txn_o           => gtEmuToLpN,
         mgt_txp_o           => gtEmuToLpP);

end testbed;
