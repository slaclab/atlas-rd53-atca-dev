-------------------------------------------------------------------------------
-- File       : SmaTxClkout.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: GTH Wrapper
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

library surf;
use surf.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity SmaTxClkout is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Clocks and Resets
      gtRefClk : in  sl;
      drpClk   : in  sl;
      drpRst   : in  sl;
      -- Broadcast External Timing Clock
      smaTxP   : out sl;
      smaTxN   : out sl;
      smaRxP   : in  sl;                -- RX unused
      smaRxN   : in  sl);               -- RX unused
end SmaTxClkout;

architecture mapping of SmaTxClkout is

COMPONENT sma_tx_clkout
  PORT (
    gtwiz_userclk_tx_reset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_tx_srcclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_tx_usrclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_tx_usrclk2_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_tx_active_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_reset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_srcclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_usrclk_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_usrclk2_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userclk_rx_active_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_reset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_start_user_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_tx_error_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_rx_reset_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_rx_start_user_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_rx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_buffbypass_rx_error_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_clk_freerun_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_all_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_pll_and_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_datapath_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_cdr_stable_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_tx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_reset_rx_done_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtwiz_userdata_tx_in : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
    gtwiz_userdata_rx_out : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
    cpllrefclksel_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    drpclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtgrefclk_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthrxn_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthrxp_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtrefclk0_in : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    txdiffctrl_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    gthtxn_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gthtxp_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    gtpowergood_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    rxpmaresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    txpmaresetdone_out : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;

begin

   U_GTH : sma_tx_clkout
      port map (
         gtwiz_userclk_tx_reset_in          => (others => '0'),
         gtwiz_userclk_tx_srcclk_out        => open,
         gtwiz_userclk_tx_usrclk_out        => open,
         gtwiz_userclk_tx_usrclk2_out       => open,
         gtwiz_userclk_tx_active_out        => open,
         gtwiz_userclk_rx_reset_in          => (others => '0'),
         gtwiz_userclk_rx_srcclk_out        => open,
         gtwiz_userclk_rx_usrclk_out        => open,
         gtwiz_userclk_rx_usrclk2_out       => open,
         gtwiz_userclk_rx_active_out        => open,
         gtwiz_buffbypass_tx_reset_in       => (others => '0'),
         gtwiz_buffbypass_tx_start_user_in  => (others => '0'),
         gtwiz_buffbypass_tx_done_out       => open,
         gtwiz_buffbypass_tx_error_out      => open,
         gtwiz_buffbypass_rx_reset_in       => (others => '0'),
         gtwiz_buffbypass_rx_start_user_in  => (others => '0'),
         gtwiz_buffbypass_rx_done_out       => open,
         gtwiz_buffbypass_rx_error_out      => open,
         gtwiz_reset_clk_freerun_in(0)      => drpClk,
         gtwiz_reset_all_in(0)              => drpRst,
         gtwiz_reset_tx_pll_and_datapath_in => (others => '0'),
         gtwiz_reset_tx_datapath_in         => (others => '0'),
         gtwiz_reset_rx_pll_and_datapath_in => (others => '0'),
         gtwiz_reset_rx_datapath_in         => (others => '0'),
         gtwiz_reset_rx_cdr_stable_out      => open,
         gtwiz_reset_tx_done_out            => open,
         gtwiz_reset_rx_done_out            => open,
         gtwiz_userdata_tx_in               => "10101010101010101010",  -- 1.28 GHz clock pattern @ 2.56Gb/s
         gtwiz_userdata_rx_out              => open,
         cpllrefclksel_in                   => "111",
         drpclk_in(0)                       => drpClk,
         gtgrefclk_in(0)                    => gtRefClk,
         gthrxn_in(0)                       => smaRxN,
         gthrxp_in(0)                       => smaRxP,
         gtrefclk0_in(0)                    => '0',
         txdiffctrl_in                      => "11111",
         gthtxn_out(0)                      => smaTxN,
         gthtxp_out(0)                      => smaTxP,
         gtpowergood_out                    => open,
         rxpmaresetdone_out                 => open,
         txpmaresetdone_out                 => open);

end mapping;
