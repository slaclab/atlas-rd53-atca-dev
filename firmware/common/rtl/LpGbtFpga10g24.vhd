-------------------------------------------------------------------------------
-- File       : LpGbtFpga10g24.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: LpGBT 10.24 Wrapper
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

entity LpGbtFpga10g24 is
   port (
      -- Down link
      donwlinkClk_o               : out std_logic;  --! Downlink datapath clock (either 320 or 40MHz)
      downlinkClkEn_o             : out std_logic;  --! Clock enable (1 over 8 when encoding runs @ 320Mhz, '1' @ 40MHz)
      downlinkRst_i               : in  std_logic;  --! Reset the downlink path
      downlinkUserData_i          : in  std_logic_vector(31 downto 0);  --! Downlink data (user)
      downlinkEcData_i            : in  std_logic_vector(1 downto 0);  --! Downlink EC field
      downlinkIcData_i            : in  std_logic_vector(1 downto 0);  --! Downlink IC field
      downLinkBypassInterleaver_i : in  std_logic                    := '0';  --! Bypass downlink interleaver (test purpose only)
      downLinkBypassFECEncoder_i  : in  std_logic                    := '0';  --! Bypass downlink FEC (test purpose only)
      downLinkBypassScrambler_i   : in  std_logic                    := '0';  --! Bypass downlink scrambler (test purpose only)
      downlinkReady_o             : out std_logic;  --! Downlink ready status
      -- Up link
      uplinkClk_o                 : out std_logic;  --! Clock provided by the Rx serdes: in phase with data
      uplinkClkEn_o               : out std_logic;  --! Clock enable pulsed when new data is ready
      uplinkRst_i                 : in  std_logic;  --! Reset the uplink path
      uplinkUserData_o            : out std_logic_vector(229 downto 0);  --! Uplink data (user)
      uplinkEcData_o              : out std_logic_vector(1 downto 0);  --! Uplink EC field
      uplinkIcData_o              : out std_logic_vector(1 downto 0);  --! Uplink IC field
      uplinkBypassInterleaver_i   : in  std_logic                    := '0';  --! Bypass uplink interleaver (test purpose only)
      uplinkBypassFECEncoder_i    : in  std_logic                    := '0';  --! Bypass uplink FEC (test purpose only)
      uplinkBypassScrambler_i     : in  std_logic                    := '0';  --! Bypass uplink scrambler (test purpose only)
      uplinkReady_o               : out std_logic;  --! Uplink ready status
      -- MGT
      clk_refclk_i                : in  std_logic;  --! Transceiver serial clock
      clk_mgtfreedrpclk_i         : in  std_logic;
      mgt_rxn_i                   : in  std_logic;
      mgt_rxp_i                   : in  std_logic;
      mgt_txn_o                   : out std_logic;
      mgt_txp_o                   : out std_logic;
      mgt_txcaliben_i             : in  std_logic                    := '0';
      mgt_txcalib_i               : in  std_logic_vector(6 downto 0) := (others => '0');
      mgt_txaligned_o             : out std_logic;
      mgt_txphase_o               : out std_logic_vector(6 downto 0));
end LpGbtFpga10g24;

architecture mapping of LpGbtFpga10g24 is

   signal downlink_mgtword_s : std_logic_vector(255 downto 0) := (others => '0');
   signal uplink_mgtword_s   : std_logic_vector(255 downto 0) := (others => '0');

   signal mgt_rxslide_s : std_logic := '0';
   signal mgt_txrdy_s   : std_logic := '0';
   signal mgt_rxrdy_s   : std_logic := '0';

   signal downlinkClk_s   : std_logic := '0';
   signal downlinkClkEn_s : std_logic := '1';

   signal uplinkClk_s   : std_logic := '0';
   signal uplinkClkEn_s : std_logic := '1';

begin

   donwlinkClk_o   <= downlinkClk_s;
   downlinkClkEn_o <= downlinkClkEn_s;
   U_downlinkClkEn : entity surf.Synchronizer
      port map (
         clk     => downlinkClk_s,
         dataIn  => mgt_txrdy_s,
         dataOut => downlinkClkEn_s);   

   downlink_inst : entity work.lpgbtfpga_Downlink
      generic map(
         -- Expert parameters
         c_multicyleDelay => 0,
         c_clockRatio     => 1,
         c_outputWidth    => 256)
      port map(
         -- Clocks
         clk_i               => downlinkClk_s,
         clkEn_i             => downlinkClkEn_s,
         rst_n_i             => mgt_txrdy_s,
         -- Down link
         userData_i          => downlinkUserData_i,
         ECData_i            => downlinkEcData_i,
         ICData_i            => downlinkIcData_i,
         -- Output
         mgt_word_o          => downlink_mgtword_s,
         -- Configuration
         interleaverBypass_i => downLinkBypassInterleaver_i,
         encoderBypass_i     => downLinkBypassFECEncoder_i,
         scramblerBypass_i   => downLinkBypassScrambler_i,
         -- Status
         rdy_o               => downlinkReady_o);

   mgt_inst : entity work.xlx_ku_mgt_10g24
      port map(
         --=============--
         -- Clocks      --
         --=============--
         MGT_REFCLK_i      => clk_refclk_i,
         MGT_FREEDRPCLK_i  => clk_mgtfreedrpclk_i,
         MGT_TXUSRCLK_o    => downlinkClk_s,
         MGT_RXUSRCLK_o    => uplinkClk_s,
         --=============--
         -- Resets      --
         --=============--
         MGT_TXRESET_i     => downlinkRst_i,
         MGT_RXRESET_i     => uplinkRst_i,
         --=============--
         -- Control     --
         --=============--
         MGT_RXSlide_i     => mgt_rxslide_s,
         MGT_ENTXCALIBIN_i => '0',
         MGT_TXCALIB_i     => (others => '0'),
         --=============--
         -- Status      --
         --=============--
         MGT_TXREADY_o     => mgt_txrdy_s,
         MGT_RXREADY_o     => mgt_rxrdy_s,
         --==============--
         -- Data         --
         --==============--
         MGT_USRWORD_i     => downlink_mgtword_s,
         MGT_USRWORD_o     => uplink_mgtword_s,
         --===============--
         -- Serial intf.  --
         --===============--
         RXn_i             => mgt_rxn_i,
         RXp_i             => mgt_rxp_i,
         TXn_o             => mgt_txn_o,
         TXp_o             => mgt_txp_o);

   uplinkClk_o   <= uplinkClk_s;
   uplinkClkEn_o <= uplinkClkEn_s;

   uplink_inst : entity work.lpgbtfpga_Uplink
      generic map(
         -- General configuration
         DATARATE                  => DATARATE_10G24,
         FEC                       => FEC12,
         -- Expert parameters
         c_multicyleDelay          => 0,
         c_clockRatio              => 1,
         c_mgtWordWidth            => 256,
         c_allowedFalseHeader      => 5,
         c_allowedFalseHeaderOverN => 64,
         c_requiredTrueHeader      => 30,
         c_bitslip_mindly          => 1,
         c_bitslip_waitdly         => 40)
      port map(
         -- Clock and reset
         clk_freeRunningClk_i => clk_mgtfreedrpclk_i,
         uplinkClk_i          => uplinkClk_s,
         uplinkClkOutEn_o     => uplinkClkEn_s,
         uplinkRst_n_i        => mgt_rxrdy_s,
         -- Input
         mgt_word_o           => uplink_mgtword_s,
         -- Data
         userData_o           => uplinkUserData_o,
         EcData_o             => uplinkEcData_o,
         IcData_o             => uplinkIcData_o,
         -- Control
         bypassInterleaver_i  => uplinkBypassInterleaver_i,
         bypassFECEncoder_i   => uplinkBypassFECEncoder_i,
         bypassScrambler_i    => uplinkBypassScrambler_i,
         -- Transceiver control
         mgt_bitslipCtrl_o    => mgt_rxslide_s,
         -- Status
         dataCorrected_o      => open,
         IcCorrected_o        => open,
         EcCorrected_o        => open,
         rdy_o                => uplinkReady_o);

end mapping;
