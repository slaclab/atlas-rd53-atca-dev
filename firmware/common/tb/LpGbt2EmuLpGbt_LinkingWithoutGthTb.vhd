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

library surf;
use surf.StdRtlPkg.all;

use work.lpgbtfpga_package.all;

entity LpGbt2EmuLpGbt_LinkingWithoutGthTb is
end LpGbt2EmuLpGbt_LinkingWithoutGthTb;

architecture testbed of LpGbt2EmuLpGbt_LinkingWithoutGthTb is

   constant WIDTH_C   : positive range 32 to 256 := 256;  -- 32, 64, or 256 (128 not supported yet)
   constant RATIO_C   : positive                 := 256/WIDTH_C;
   constant MAX_CNT_C : natural                  := (RATIO_C-1);
   constant MULTI_CYCLE_C : natural              := ite(RATIO_C>2,(RATIO_C/2)-1,0);

   signal valid : slv(1 downto 0) := (others => '0');
   signal ready : slv(1 downto 0) := (others => '1');

   signal downlinkRaw : slv(35 downto 0)  := (others => '0');
   signal uplinkRaw   : slv(233 downto 0) := (others => '0');

   signal downlinkCnt : Slv36Array(1 downto 0)  := (others => (others => '0'));
   signal uplinkCnt   : Slv234Array(1 downto 0) := (others => (others => '0'));

   signal downlinkClk   : slv(1 downto 0) := (others => '0');
   signal downlinkClkEn : slv(1 downto 0) := (others => '0');
   signal downlinkReady : slv(1 downto 0) := (others => '0');

   signal uplinkClk   : slv(1 downto 0) := (others => '0');
   signal uplinkClkEn : slv(1 downto 0) := (others => '0');
   signal uplinkReady : slv(1 downto 0) := (others => '0');

   signal emuRx     : slv(WIDTH_C-1 downto 0) := (others => '0');
   signal emuTx     : slv(WIDTH_C-1 downto 0) := (others => '0');
   signal emuTx256b : slv(255 downto 0)       := (others => '0');

   signal lpRx     : slv(WIDTH_C-1 downto 0) := (others => '0');
   signal lpTx     : slv(WIDTH_C-1 downto 0) := (others => '0');
   signal lpTx256b : slv(255 downto 0)       := (others => '0');

   signal clkEn    : sl                           := '0';
   signal clkEnCnt : natural range 0 to MAX_CNT_C := 0;
   signal index    : natural range 0 to MAX_CNT_C := 0;

   signal lpSlip  : sl := '0';
   signal emuSlip : sl := '0';

   signal clk     : sl := '0';
   signal rst     : sl := '1';
   signal rstL    : sl := '0';
   signal axilClk : sl := '0';

begin

   process(clk)
   begin
      if rising_edge(clk) then
         if downlinkClkEn(1) = '1' then
            downlinkCnt(1) <= downlinkRaw after 1 ns;
         end if;
         if uplinkClkEn(0) = '1' then
            uplinkCnt(0) <= uplinkRaw after 1 ns;
         end if;
         if clkEnCnt = MAX_CNT_C then
            if (downlinkReady = "11") then
               downlinkCnt(0) <= downlinkCnt(0) + 1 after 1 ns;
            end if;
            if (uplinkReady = "11") then
               uplinkCnt(1) <= uplinkCnt(1) + 1 after 1 ns;
            end if;
            clkEn    <= '1' after 1 ns;
            clkEnCnt <= 0   after 1 ns;
         else
            clkEn    <= '0';
            clkEnCnt <= clkEnCnt + 1 after 1 ns;
         end if;
      end if;
   end process;

   index <= clkEnCnt;

   ---------------------------
   -- Generate clock and reset
   ---------------------------
   U_refClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => (25 ns/real(RATIO_C)),
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1 us)
      port map (
         clkP => clk,
         rst  => rst,
         rstL => rstL);

   U_axilClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G => 6.4 ns)        -- 156.25 MHz
      port map (
         clkP => axilClk);

   -------------
   -- LpGBT FPGA
   -------------
   downlink_inst : entity work.lpgbtfpga_Downlink
      generic map(
         -- Expert parameters
         c_multicyleDelay => MULTI_CYCLE_C,
         c_clockRatio     => RATIO_C,
         c_outputWidth    => WIDTH_C)
      port map(
         -- Clocks
         clk_i               => clk,
         clkEn_i             => downlinkClkEn(0),
         rst_n_i             => rstL,
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
         c_multicyleDelay          => MULTI_CYCLE_C,
         c_clockRatio              => RATIO_C,
         c_mgtWordWidth            => WIDTH_C,
         c_allowedFalseHeader      => 5,
         c_allowedFalseHeaderOverN => 64,
         c_requiredTrueHeader      => 30,
         c_bitslip_mindly          => 1,
         c_bitslip_waitdly         => 40)
      port map(
         -- Clock and reset
         clk_freeRunningClk_i => axilClk,
         uplinkClk_i          => clk,
         uplinkClkOutEn_o     => uplinkClkEn(0),
         uplinkRst_n_i        => rstL,
         -- Input
         mgt_word_o           => lpRx,
         -- Data
         userData_o           => uplinkRaw(229 downto 0),
         EcData_o             => uplinkRaw(231 downto 230),
         IcData_o             => uplinkRaw(233 downto 232),
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
      generic map (
         WIDTH_G => WIDTH_C)
      port map (
         clk  => clk,
         slip => lpSlip,
         din  => emuTx,
         dout => lpRx);   
   
   -- U_lpSlip : entity surf.Gearbox
      -- generic map (
         -- SLAVE_WIDTH_G  => WIDTH_C,
         -- MASTER_WIDTH_G => 256)
      -- port map (
         -- clk         => clk,
         -- rst         => rst,
         -- slip        => lpSlip,
         -- slaveData   => emuTx,
         -- masterData  => emuTx256b,
         -- masterValid => valid(0),
         -- masterReady => ready(0));
   -- lpRx <= emuTx256b(index*WIDTH_C+WIDTH_C-1 downto index*WIDTH_C);
   
         
   -- U_lpResize : entity surf.Gearbox
      -- generic map (
         -- SLAVE_WIDTH_G  => 256,
         -- MASTER_WIDTH_G => WIDTH_C)
      -- port map (
         -- clk        => clk,
         -- rst        => rst,
         -- slip       => '0',
         -- slaveData  => emuTx256b,
         -- slaveValid => valid(0),
         -- slaveReady => ready(0),
         -- masterData => lpRx);

   -----------------------
   -- Emulation LpGBT FPGA
   -----------------------
   U_lpgbtemul : entity work.lpgbtemul_top
      generic map(
         rxslide_pulse_duration => 2,
         rxslide_pulse_delay    => 256,
         c_clockRatio           => RATIO_C,
         c_mgtWordWidth         => WIDTH_C)
      port map(
         -- DownLink
         downlinkClkEn_o             => downlinkClkEn(1),
         rst_downlink_i              => rst,
         downLinkDataGroup0          => downlinkRaw(15 downto 0),
         downLinkDataGroup1          => downlinkRaw(31 downto 16),
         downLinkDataEc              => downlinkRaw(33 downto 32),
         downLinkDataIc              => downlinkRaw(35 downto 34),
         downLinkBypassDeinterleaver => '0',
         downLinkBypassFECDecoder    => '0',
         downLinkBypassDescsrambler  => '0',
         enableFECErrCounter         => '1',
         fecCorrectionCount          => open,
         downlinkRdy_o               => downlinkReady(1),
         -- uplink data        
         uplinkClkEn_i               => uplinkClkEn(1),
         rst_uplink_i                => rst,
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
         upLinkScramblerReset        => rst,
         upLinkFecBypass             => '0',
         upLinkInterleaverBypass     => '0',
         uplinkRdy_o                 => uplinkReady(1),
         -- MGT
         GT_RXUSRCLK_IN              => clk,
         GT_TXUSRCLK_IN              => clk,
         GT_RXSLIDE_OUT              => emuSlip,
         GT_TXREADY_IN               => rstL,
         GT_RXREADY_IN               => rstL,
         GT_TXDATA_OUT               => emuTx,
         GT_RXDATA_IN                => emuRx,
         -- General Configuration
         fecMode                     => '1',   -- ‘1’ = FEC 12
         txDataRate                  => '1');  -- ‘1’ = 10.24 Gb/s   

   uplinkClkEn(1) <= clkEn;
   U_emuSlip : entity work.BarrelShifter
      generic map (
         WIDTH_G => WIDTH_C)
      port map (
         clk  => clk,
         slip => emuSlip,
         din  => lpTx,
         dout => emuRx);   
   
   -- U_emuSlip : entity surf.Gearbox
      -- generic map (
         -- SLAVE_WIDTH_G  => WIDTH_C,
         -- MASTER_WIDTH_G => 256)
      -- port map (
         -- clk         => clk,
         -- rst         => rst,
         -- slip        => emuSlip,
         -- slaveData   => lpTx,
         -- masterData  => lpTx256b,
         -- masterValid => valid(1),
         -- masterReady => ready(1));
         
   -- emuRx <= lpTx256b(index*WIDTH_C+WIDTH_C-1 downto index*WIDTH_C);      
         
   -- U_emuResize : entity surf.Gearbox
      -- generic map (
         -- SLAVE_WIDTH_G  => 256,
         -- MASTER_WIDTH_G => WIDTH_C)
      -- port map (
         -- clk        => clk,
         -- rst        => rst,
         -- slip       => '0',
         -- slaveData  => lpTx256b,
         -- slaveValid => valid(1),
         -- slaveReady => ready(1),
         -- masterData => emuRx);

end testbed;
