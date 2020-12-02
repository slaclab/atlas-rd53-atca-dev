-------------------------------------------------------------------------------
-- File       : EmuLpGbtFpga10g24.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Emulation LpGBT 10.24 Wrapper
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 FMC DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 FMC DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;

use work.lpgbtfpga_package.all;

library unisim;
use unisim.vcomponents.all;

entity EmuLpGbtFpga10g24 is
   generic (
      SIMULATION_G      : boolean         := false;
      SELECT_GT_TYPE_G  : boolean         := false;
      CPLL_REFCLK_SEL_G : std_logic_vector(2 downto 0) := "001");
   port (
      -- Uplink mode
      fecMode             : in  std_logic;  -- 1=FEC12, 0=FEC5
      fecDisable          : in  std_logic                    := '0';
      interleaverBypass   : in  std_logic                    := '0';
      scramblerBypass     : in  std_logic                    := '0';
      txDummyFec12        : in  std_logic_vector(9 downto 0) := "1001110011";
      txDummyFec5         : in  std_logic_vector(5 downto 0) := "001100";
      -- Up link
      uplinkClk_o         : out std_logic;  --! Clock provided by the Rx serdes: in phase with data
      uplinkClkEn_o       : out std_logic;  --! Clock enable pulsed when new data is ready
      uplinkRst_i         : in  std_logic;  --! Reset the uplink path
      uplinkUserData_i    : in  std_logic_vector(229 downto 0);  --! Uplink data (user)
      uplinkEcData_i      : in  std_logic_vector(1 downto 0);  --! Uplink EC field
      uplinkIcData_i      : in  std_logic_vector(1 downto 0);  --! Uplink IC field
      uplinkReady_o       : out std_logic;  --! Uplink ready status
      -- Down link
      donwlinkClk_o       : out std_logic;  --! Downlink datapath clock (either 320 or 40MHz)
      downlinkClkEn_o     : out std_logic;  --! Clock enable (1 over 8 when encoding runs @ 320Mhz, '1' @ 40MHz)
      downlinkRst_i       : in  std_logic;  --! Reset the downlink path
      downlinkUserData_o  : out std_logic_vector(31 downto 0);  --! Downlink data (user)
      downlinkEcData_o    : out std_logic_vector(1 downto 0);  --! Downlink EC field
      downlinkIcData_o    : out std_logic_vector(1 downto 0);  --! Downlink IC field
      downlinkReady_o     : out std_logic;  --! Downlink ready status
      -- MGT
      txWordClk160_o      : out std_logic;
      rxWordClk80_o       : out std_logic;
      txWordClk40_i       : in  std_logic;
      rxWordClk40_i       : in  std_logic;
      qplllock            : in  std_logic_vector(1 downto 0);
      qplloutclk          : in  std_logic_vector(1 downto 0);
      qplloutrefclk       : in  std_logic_vector(1 downto 0);
      qpllRst             : out std_logic;
      rxRecClk            : out std_logic;
      clk_refclk_i        : in  std_logic;  --! CPLL using 160 MHz reference
      clk_mgtfreedrpclk_i : in  std_logic;
      mgt_rxn_i           : in  std_logic;
      mgt_rxp_i           : in  std_logic;
      mgt_txn_o           : out std_logic;
      mgt_txp_o           : out std_logic;
      mgt_txcaliben_i     : in  std_logic                    := '0';
      mgt_txcalib_i       : in  std_logic_vector(6 downto 0) := (others => '0');
      mgt_txaligned_o     : out std_logic                    := '0';
      mgt_txphase_o       : out std_logic_vector(6 downto 0) := (others => '0'));
end EmuLpGbtFpga10g24;

architecture mapping of EmuLpGbtFpga10g24 is

   signal uplink_mgtword_s   : std_logic_vector(255 downto 0) := (others => '0');
   signal downlink_mgtword_s : std_logic_vector(255 downto 0) := (others => '0');

   signal mgt_rxslide_s : std_logic := '0';
   signal mgt_txrdy_s   : std_logic := '0';
   signal mgt_rxrdy_s   : std_logic := '0';

   signal uplinkClk_s   : std_logic := '0';
   signal uplinkClkEn_s : std_logic := '1';

   signal downlinkClk_s   : std_logic := '0';
   signal downlinkClkEn_s : std_logic := '1';

   signal uplinkRst_s   : std_logic := '1';
   signal downlinkRst_s : std_logic := '1';

begin

   uplinkClk_o   <= uplinkClk_s;
   uplinkClkEn_o <= mgt_txrdy_s and uplinkClkEn_s;

   donwlinkClk_o   <= downlinkClk_s;
   downlinkClkEn_o <= mgt_rxrdy_s and downlinkClkEn_s;

   mgt_inst : entity work.xlx_ku_mgt_10g24_emu
      generic map (
         SELECT_GT_TYPE_G  => SELECT_GT_TYPE_G,
         CPLL_REFCLK_SEL_G => CPLL_REFCLK_SEL_G)
      port map (
         --=============--
         -- Clocks      --
         --=============--
         QPLL_LOCK_i      => qplllock,
         QPLL_CLK_i       => qplloutclk,
         QPLL_REFCLK_i    => qplloutrefclk,
         QPLL_RST_o       => qpllRst,
         MGT_RX_REC_CLK_o => rxRecClk,
         MGT_REFCLK_i     => clk_refclk_i,
         MGT_FREEDRPCLK_i => clk_mgtfreedrpclk_i,
         MGT_TXUSRCLK_o   => uplinkClk_s,
         MGT_RXUSRCLK_o   => downlinkClk_s,
         txWordClk160_o   => txWordClk160_o,
         rxWordClk80_o    => rxWordClk80_o,
         txWordClk40_i    => txWordClk40_i,
         rxWordClk40_i    => rxWordClk40_i,
         --=============--
         -- Resets      --
         --=============--
         MGT_TXRESET_i    => downlinkRst_i,
         MGT_RXRESET_i    => uplinkRst_i,
         --=============--
         -- Control     --
         --=============--
         MGT_RXSlide_i    => mgt_rxslide_s,
         --=============--
         -- Status      --
         --=============--
         MGT_TXREADY_o    => mgt_txrdy_s,
         MGT_RXREADY_o    => mgt_rxrdy_s,
         --==============--
         -- Data         --
         --==============--
         MGT_USRWORD_i    => uplink_mgtword_s,
         MGT_USRWORD_o    => downlink_mgtword_s,
         --===============--
         -- Serial intf.  --
         --===============--
         RXn_i            => mgt_rxn_i,
         RXp_i            => mgt_rxp_i,
         TXn_o            => mgt_txn_o,
         TXp_o            => mgt_txp_o);

   U_lpgbtemul : entity work.lpgbtemul_top
      generic map(
         rxslide_pulse_duration => 2,
         rxslide_pulse_delay    => 128,
         c_clockRatio           => 1,
         c_mgtWordWidth         => 256)
      port map(
         -- DownLink
         downlinkClkEn_o    => downlinkClkEn_s,
         downLinkDataGroup0 => downlinkUserData_o(15 downto 0),
         downLinkDataGroup1 => downlinkUserData_o(31 downto 16),
         downLinkDataEc     => downlinkEcData_o,
         downLinkDataIc     => downlinkIcData_o,
         downlinkRdy_o      => downlinkReady_o,
         -- uplink data
         uplinkClkEn_i      => uplinkClkEn_s,
         upLinkData0        => uplinkUserData_i(31 downto 0),
         upLinkData1        => uplinkUserData_i(63 downto 32),
         upLinkData2        => uplinkUserData_i(95 downto 64),
         upLinkData3        => uplinkUserData_i(127 downto 96),
         upLinkData4        => uplinkUserData_i(159 downto 128),
         upLinkData5        => uplinkUserData_i(191 downto 160),
         upLinkData6        => uplinkUserData_i(223 downto 192),
         upLinkDataIC       => uplinkIcData_i,
         upLinkDataEC       => uplinkEcData_i,
         uplinkRdy_o        => uplinkReady_o,
         -- MGT
         GT_RXUSRCLK_IN     => downlinkClk_s,
         GT_TXUSRCLK_IN     => uplinkClk_s,
         GT_RXSLIDE_OUT     => mgt_rxslide_s,
         GT_TXREADY_IN      => mgt_txrdy_s,
         GT_RXREADY_IN      => mgt_rxrdy_s,
         GT_TXDATA_OUT      => uplink_mgtword_s,
         GT_RXDATA_IN       => downlink_mgtword_s,
         -- Uplink mode
         fecMode            => fecMode,
         fecDisable         => fecDisable,
         interleaverBypass  => interleaverBypass,
         scramblerBypass    => scramblerBypass,
         txDummyFec12       => txDummyFec12,
         txDummyFec5        => txDummyFec5,
         txDataRate         => '1');    -- ‘1’ - 10.24 Gb/s

   U_uplinkRst : entity surf.RstSync
      port map(
         clk      => uplinkClk_s,
         asyncRst => uplinkRst_i,
         syncRst  => uplinkRst_s);

   U_downlinkRst : entity surf.RstSync
      port map(
         clk      => downlinkClk_s,
         asyncRst => downlinkRst_i,
         syncRst  => downlinkRst_s);

end mapping;
