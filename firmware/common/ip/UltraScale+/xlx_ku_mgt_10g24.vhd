-------------------------------------------------------------------------------
-- File       : xlx_ku_mgt_10g24.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper on GTH IP core
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
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity xlx_ku_mgt_10g24 is
   generic (
      USRCLK_DOMAIN_SEL : boolean);     -- true: rxoutclk, false: txoutclk
   port (
      --=============--
      -- Clocks      --
      --=============--
      MGT_REFCLK_i      : in  std_logic;
      MGT_FREEDRPCLK_i  : in  std_logic;
      MGT_USRCLK_o      : out std_logic;
      --=============--
      -- Resets      --
      --=============--
      MGT_TXRESET_i     : in  std_logic;
      MGT_RXRESET_i     : in  std_logic;
      --=============--
      -- Control     --
      --=============--
      MGT_RXSlide_i     : in  std_logic;
      MGT_ENTXCALIBIN_i : in  std_logic;
      MGT_TXCALIB_i     : in  std_logic_vector(6 downto 0);
      --=============--
      -- Status      --
      --=============--
      MGT_TXREADY_o     : out std_logic;
      MGT_RXREADY_o     : out std_logic;
      MGT_TX_ALIGNED_o  : out std_logic;
      MGT_TX_PIPHASE_o  : out std_logic_vector(6 downto 0);
      --==============--
      -- Data         --
      --==============--
      MGT_USRWORD_i     : in  std_logic_vector(31 downto 0);
      MGT_USRWORD_o     : out std_logic_vector(31 downto 0);
      --===============--
      -- Serial intf.  --
      --===============--
      RXn_i             : in  std_logic;
      RXp_i             : in  std_logic;
      TXn_o             : out std_logic;
      TXp_o             : out std_logic);
end xlx_ku_mgt_10g24;

architecture mapping of xlx_ku_mgt_10g24 is

   component xlx_ku_mgt_ip_10g24
      port (
         gtwiz_userclk_tx_reset_in          : in  std_logic_vector(0 downto 0);
         gtwiz_userclk_tx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_active_in         : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_rx_error_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_clk_freerun_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_all_in                 : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_tx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_pll_and_datapath_in : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_datapath_in         : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_userdata_tx_in               : in  std_logic_vector(31 downto 0);
         gtwiz_userdata_rx_out              : out std_logic_vector(31 downto 0);
         drpaddr_in                         : in  std_logic_vector(9 downto 0);
         drpclk_in                          : in  std_logic_vector(0 downto 0);
         drpdi_in                           : in  std_logic_vector(15 downto 0);
         drpen_in                           : in  std_logic_vector(0 downto 0);
         drpwe_in                           : in  std_logic_vector(0 downto 0);
         gthrxn_in                          : in  std_logic_vector(0 downto 0);
         gthrxp_in                          : in  std_logic_vector(0 downto 0);
         gtrefclk0_in                       : in  std_logic_vector(0 downto 0);
         rxcommadeten_in                    : in  std_logic_vector(0 downto 0);
         rxmcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxpcommaalignen_in                 : in  std_logic_vector(0 downto 0);
         rxslide_in                         : in  std_logic_vector(0 downto 0);
         rxusrclk_in                        : in  std_logic_vector(0 downto 0);
         rxusrclk2_in                       : in  std_logic_vector(0 downto 0);
         txpippmen_in                       : in  std_logic_vector(0 downto 0);
         txpippmovrden_in                   : in  std_logic_vector(0 downto 0);
         txpippmpd_in                       : in  std_logic_vector(0 downto 0);
         txpippmsel_in                      : in  std_logic_vector(0 downto 0);
         txpippmstepsize_in                 : in  std_logic_vector(4 downto 0);
         txusrclk_in                        : in  std_logic_vector(0 downto 0);
         txusrclk2_in                       : in  std_logic_vector(0 downto 0);
         drpdo_out                          : out std_logic_vector(15 downto 0);
         drprdy_out                         : out std_logic_vector(0 downto 0);
         gthtxn_out                         : out std_logic_vector(0 downto 0);
         gthtxp_out                         : out std_logic_vector(0 downto 0);
         gtpowergood_out                    : out std_logic_vector(0 downto 0);
         rxbyteisaligned_out                : out std_logic_vector(0 downto 0);
         rxbyterealign_out                  : out std_logic_vector(0 downto 0);
         rxcommadet_out                     : out std_logic_vector(0 downto 0);
         rxoutclk_out                       : out std_logic_vector(0 downto 0);
         rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
         txbufstatus_out                    : out std_logic_vector(1 downto 0);
         txoutclk_out                       : out std_logic_vector(0 downto 0);
         txoutclkpcs_out                    : out std_logic_vector(0 downto 0);
         txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
         );
   end component;

   -- Reset signals
   signal tx_reset_done    : std_logic;
   signal tx_rdy_done      : std_logic;
   signal txfsm_reset_done : std_logic;
   signal rx_reset_done    : std_logic;
   signal rxfsm_reset_done : std_logic;

   signal rxBuffBypassRst                : std_logic;
   signal gtwiz_userclk_rx_active_int    : std_logic;
   signal gtwiz_buffbypass_rx_reset_in_s : std_logic;
   signal gtwiz_userclk_tx_active_int    : std_logic;
   signal gtwiz_buffbypass_tx_reset_in_s : std_logic;

   signal gtwiz_userclk_tx_reset_int : std_logic;
   signal gtwiz_userclk_rx_reset_int : std_logic;
   signal txpmaresetdone             : std_logic;
   signal rxpmaresetdone             : std_logic;

   signal rx_reset_sig : std_logic;
   signal tx_reset_sig : std_logic;

   signal MGT_USRWORD_s : std_logic_vector(31 downto 0);

   -- Clock signals
   signal phyclkout_sig : std_logic_vector(1 downto 0);
   signal userclk_sig   : std_logic;
   signal rxoutclk_sig  : std_logic;
   signal txoutclk_sig  : std_logic;

   signal mgt_rst_phaligner_s : std_logic;
   signal MGT_TX_ALIGNED_s    : std_logic;

begin

   MGT_TX_ALIGNED_s <= tx_reset_done;
   MGT_TXREADY_o    <= tx_reset_done and MGT_TX_ALIGNED_s;  -- and txfsm_reset_done;
   MGT_TX_ALIGNED_o <= MGT_TX_ALIGNED_s;
   MGT_RXREADY_o    <= rx_reset_done and rxfsm_reset_done;

   tx_rdy_done <= not(tx_reset_done);

   gtwiz_userclk_tx_reset_int <= not(txpmaresetdone);
   gtwiz_userclk_rx_reset_int <= not(rxpmaresetdone);

   MGT_USRCLK_o <= userclk_sig;

   rx_reset_sig <= MGT_RXRESET_i or not(tx_reset_done and MGT_TX_ALIGNED_s);  -- and txfsm_reset_done);
   tx_reset_sig <= MGT_TXRESET_i;

   rxBuffBypassRst <= not(gtwiz_userclk_rx_active_int) or (not(tx_reset_done) and not(MGT_TX_ALIGNED_s));

   resetDoneSynch_rx : entity work.RstSync
      port map(
         clk      => userclk_sig,
         asyncRst => rxBuffBypassRst,
         syncRst  => gtwiz_buffbypass_rx_reset_in_s);

   userclk_rx : BUFG_GT
      port map (
         I       => rxoutclk_sig,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => phyclkout_sig(1));

   userclk_tx : BUFG_GT
      port map (
         I       => txoutclk_sig,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => phyclkout_sig(0));

   userclk_sig <= phyclkout_sig(1) when(USRCLK_DOMAIN_SEL) else phyclkout_sig(0);

   activetxUsrClk_proc : process(gtwiz_userclk_tx_reset_int, userclk_sig)
   begin
      if gtwiz_userclk_tx_reset_int = '1' then
         gtwiz_userclk_tx_active_int <= '0';
      elsif rising_edge(userclk_sig) then
         gtwiz_userclk_tx_active_int <= '1';
      end if;

   end process;

   activerxUsrClk_proc : process(gtwiz_userclk_rx_reset_int, userclk_sig)
   begin
      if gtwiz_userclk_rx_reset_int = '1' then
         gtwiz_userclk_rx_active_int <= '0';
      elsif rising_edge(userclk_sig) then
         gtwiz_userclk_rx_active_int <= '1';
      end if;

   end process;

   rxWordPipeline_proc : process(rx_reset_done, userclk_sig)
   begin
      if rx_reset_done = '0' then
         MGT_USRWORD_o <= (others => '0');
      elsif rising_edge(userclk_sig) then
         MGT_USRWORD_o <= MGT_USRWORD_s;
      end if;
   end process;

   xlx_ku_mgt_std_i : xlx_ku_mgt_ip_10g24
      port map (
         rxusrclk_in(0)                        => userclk_sig,
         rxusrclk2_in(0)                       => userclk_sig,
         rxoutclk_out(0)                       => rxoutclk_sig,
         txusrclk_in(0)                        => userclk_sig,
         txusrclk2_in(0)                       => userclk_sig,
         txoutclk_out(0)                       => open,
         txoutclkpcs_out(0)                    => txoutclk_sig,
         gtwiz_userclk_tx_reset_in(0)          => gtwiz_userclk_tx_reset_int,
         gtwiz_userclk_tx_active_in(0)         => gtwiz_userclk_tx_active_int,
         gtwiz_userclk_rx_active_in(0)         => gtwiz_userclk_rx_active_int,
         gtwiz_buffbypass_rx_reset_in(0)       => gtwiz_buffbypass_rx_reset_in_s,
         gtwiz_buffbypass_rx_start_user_in(0)  => '0',
         gtwiz_buffbypass_rx_done_out(0)       => rxfsm_reset_done,
         gtwiz_buffbypass_rx_error_out         => open,
         gtwiz_reset_clk_freerun_in(0)         => MGT_FREEDRPCLK_i,
         gtwiz_reset_all_in(0)                 => '0',
         gtwiz_reset_tx_pll_and_datapath_in(0) => tx_reset_sig,
         gtwiz_reset_tx_datapath_in(0)         => '0',
         gtwiz_reset_tx_done_out(0)            => tx_reset_done,
         gtwiz_reset_rx_pll_and_datapath_in(0) => '0',
         gtwiz_reset_rx_datapath_in(0)         => rx_reset_sig,
         gtwiz_reset_rx_cdr_stable_out         => open,
         gtwiz_reset_rx_done_out(0)            => rx_reset_done,
         gtwiz_userdata_tx_in                  => MGT_USRWORD_i,
         gtwiz_userdata_rx_out                 => MGT_USRWORD_s,
         drpclk_in(0)                          => MGT_FREEDRPCLK_i,
         gthrxn_in(0)                          => RXn_i,
         gthrxp_in(0)                          => RXp_i,
         gthtxn_out(0)                         => TXn_o,
         gthtxp_out(0)                         => TXp_o,
         gtrefclk0_in(0)                       => MGT_REFCLK_i,
         rxslide_in(0)                         => MGT_RXSlide_i,
         rxpmaresetdone_out(0)                 => rxpmaresetdone,
         txpmaresetdone_out(0)                 => txpmaresetdone,
         -- DRP bus (used by the tx phase aligner)
         drpaddr_in                            => (others => '0'),
         drpdi_in                              => (others => '0'),
         drpen_in(0)                           => '0',
         drpwe_in(0)                           => '0',
         drpdo_out                             => open,
         drprdy_out(0)                         => open,
         -- PI control / monitoring signals
         txpippmen_in(0)                       => '0',
         txpippmovrden_in(0)                   => '0',
         txpippmpd_in(0)                       => '0',
         txpippmsel_in(0)                      => '0',
         txpippmstepsize_in                    => (others => '0'),
         -- Tx buffer status
         txbufstatus_out                       => open,
         rxcommadeten_in                       => "1",
         rxmcommaalignen_in                    => "0",
         rxpcommaalignen_in                    => "0");

end mapping;
