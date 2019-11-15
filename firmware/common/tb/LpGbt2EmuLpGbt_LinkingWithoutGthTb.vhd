-------------------------------------------------------------------------------
-- File       : LpGbt2EmuLpGbt_LinkingWithoutGthTb.vhd
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
use work.lpgbtfpga_package.all;

entity LpGbt2EmuLpGbt_LinkingWithoutGthTb is
end LpGbt2EmuLpGbt_LinkingWithoutGthTb;

architecture testbed of LpGbt2EmuLpGbt_LinkingWithoutGthTb is

   signal downlinkCnt : Slv36Array(1 downto 0)  := (others => (others => '0'));
   signal uplinkCnt   : Slv234Array(1 downto 0) := (others => (others => '0'));

   signal downlinkClk   : slv(1 downto 0) := (others => '0');
   signal downlinkClkEn : slv(1 downto 0) := (others => '0');
   signal downlinkReady : slv(1 downto 0) := (others => '0');

   signal uplinkClk   : slv(1 downto 0) := (others => '0');
   signal uplinkClkEn : slv(1 downto 0) := (others => '0');
   signal uplinkReady : slv(1 downto 0) := (others => '0');

   signal emuTx : slv(31 downto 0) := (others => '0');
   signal emuRx : slv(31 downto 0) := (others => '0');

   signal lpTx : slv(31 downto 0) := (others => '0');
   signal lpRx : slv(31 downto 0) := (others => '0');

   signal clkEnCnt : slv(2 downto 0) := (others => '0');
   signal clkEn    : sl              := '0';

   signal lpSlip  : sl := '0';
   signal emuSlip : sl := '0';

   signal clk320  : sl := '0';
   signal rst320  : sl := '1';
   signal rst320L : sl := '0';
   signal axilClk : sl := '0';

begin

   process(clk320)
   begin
      if rising_edge(clk320) then
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
         CLK_PERIOD_G      => 6.25 ns,  -- 160 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1 us)
      port map (
         clkP => clk320,
         rst  => rst320,
         rstL => rst320L);

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
   downlink_inst : entity work.lpgbtfpga_Downlink
      generic map(
         -- Expert parameters
         c_multicyleDelay => 3,
         c_clockRatio     => 8,
         c_outputWidth    => 32)
      port map(
         -- Clocks
         clk_i               => clk320,
         clkEn_i             => downlinkClkEn(0),
         rst_n_i             => rst320L,
         -- Down link
         userData_i          => downlinkCnt(0)(31 downto 0),
         ECData_i            => downlinkCnt(0)(33 downto 32),
         ICData_i            => downlinkCnt(0)(35 downto 34),
         -- Output
         mgt_word_o          => lpTx,
         -- Configuration
         interleaverBypass_i => '0',
         encoderBypass_i     => '0',
         scramblerBypass_i   => '0',
         -- Status
         rdy_o               => downlinkReady(0));

   uplink_inst : entity work.lpgbtfpga_Uplink
      generic map(
         -- General configuration
         DATARATE                  => DATARATE_10G24,
         FEC                       => FEC12,
         -- Expert parameters
         c_multicyleDelay          => 3,
         c_clockRatio              => 8,
         c_mgtWordWidth            => 32,
         c_allowedFalseHeader      => 5,
         c_allowedFalseHeaderOverN => 64,
         c_requiredTrueHeader      => 30,
         c_bitslip_mindly          => 1,
         c_bitslip_waitdly         => 40)
      port map(
         -- Clock and reset
         clk_freeRunningClk_i => axilClk,
         uplinkClk_i          => clk320,
         uplinkClkOutEn_o     => uplinkClkEn(0),
         uplinkRst_n_i        => rst320L,
         -- Input
         mgt_word_o           => lpRx,
         -- Data
         userData_o           => uplinkCnt(0)(229 downto 0),
         EcData_o             => uplinkCnt(0)(231 downto 230),
         IcData_o             => uplinkCnt(0)(233 downto 232),
         -- Control
         bypassInterleaver_i  => '0',
         bypassFECEncoder_i   => '0',
         bypassScrambler_i    => '0',
         -- Transceiver control
         mgt_bitslipCtrl_o    => lpSlip,
         -- Status
         dataCorrected_o      => open,
         IcCorrected_o        => open,
         EcCorrected_o        => open,
         rdy_o                => uplinkReady(0));

   downlinkClkEn(0) <= clkEn;
   U_lpSlip : entity work.BarrelShifter
      port map (
         clk  => clk320,
         slip => lpSlip,
         din  => emuTx,
         dout => lpRx);

   -----------------------
   -- Emulation LpGBT FPGA
   -----------------------
   U_lpgbtemul : entity work.lpgbtemul_top
      port map(
         -- DownLink
         downlinkClkEn_o             => downlinkClkEn(1),
         rst_downlink_i              => rst320,
         downLinkDataGroup0          => downlinkCnt(1)(15 downto 0),
         downLinkDataGroup1          => downlinkCnt(1)(31 downto 16),
         downLinkDataEc              => downlinkCnt(1)(33 downto 32),
         downLinkDataIc              => downlinkCnt(1)(35 downto 34),
         downLinkBypassDeinterleaver => '0',
         downLinkBypassFECDecoder    => '0',
         downLinkBypassDescsrambler  => '0',
         enableFECErrCounter         => '1',
         fecCorrectionCount          => open,
         downlinkRdy_o               => downlinkReady(1),
         -- uplink data        
         uplinkClkEn_i               => uplinkClkEn(1),
         rst_uplink_i                => rst320,
         upLinkData0                 => uplinkCnt(1)(31 downto 0),
         upLinkData1                 => uplinkCnt(1)(63 downto 32),
         upLinkData2                 => uplinkCnt(1)(95 downto 64),
         upLinkData3                 => uplinkCnt(1)(127 downto 96),
         upLinkData4                 => uplinkCnt(1)(159 downto 128),
         upLinkData5                 => uplinkCnt(1)(191 downto 160),
         upLinkData6                 => uplinkCnt(1)(223 downto 192),
         upLinkDataEC                => uplinkCnt(1)(231 downto 230),
         upLinkDataIC                => uplinkCnt(1)(233 downto 232),
         upLinkScramblerBypass       => '0',
         upLinkScramblerReset        => rst320,
         upLinkFecBypass             => '0',
         upLinkInterleaverBypass     => '0',
         uplinkRdy_o                 => uplinkReady(1),
         -- MGT
         GT_RXUSRCLK_IN              => clk320,
         GT_TXUSRCLK_IN              => clk320,
         GT_RXSLIDE_OUT              => emuSlip,
         GT_TXREADY_IN               => rst320L,
         GT_RXREADY_IN               => rst320L,
         GT_TXDATA_OUT               => emuTx,
         GT_RXDATA_IN                => emuRx,
         -- General Configuration
         fecMode                     => '1',   -- ‘1’ = FEC 12
         txDataRate                  => '1');  -- ‘1’ = 10.24 Gb/s   

   uplinkClkEn(1) <= clkEn;
   U_emuSlip : entity work.BarrelShifter
      port map (
         clk  => clk320,
         slip => emuSlip,
         din  => lpTx,
         dout => emuRx);

end testbed;
