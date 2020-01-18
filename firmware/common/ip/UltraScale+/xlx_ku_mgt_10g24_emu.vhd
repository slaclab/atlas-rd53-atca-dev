-------------------------------------------------------------------------------
-- File       : xlx_ku_mgt_10g24_emu.vhd
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

library surf;
use surf.StdRtlPkg.all;

library unisim;
use unisim.vcomponents.all;

entity xlx_ku_mgt_10g24_emu is
   port (
      --=============--
      -- Clocks      --
      --=============--

      QPLL_LOCK_i      : in  std_logic_vector(1 downto 0);
      QPLL_CLK_i       : in  std_logic_vector(1 downto 0);
      QPLL_REFCLK_i    : in  std_logic_vector(1 downto 0);
      QPLL_RST_o       : out std_logic;
      MGT_RX_REC_CLK_o : out std_logic;

      MGT_REFCLK_i     : in std_logic;
      MGT_FREEDRPCLK_i : in std_logic;

      MGT_RXUSRCLK_o : out std_logic;
      MGT_TXUSRCLK_o : out std_logic;

      --=============--
      -- Resets      --
      --=============--
      MGT_TXRESET_i : in std_logic;
      MGT_RXRESET_i : in std_logic;

      --=============--
      -- Control     --
      --=============--
      MGT_RXSlide_i : in std_logic;

      MGT_ENTXCALIBIN_i : in std_logic;
      MGT_TXCALIB_i     : in std_logic_vector(6 downto 0);

      --=============--
      -- Status      --
      --=============--
      MGT_TXREADY_o : out std_logic;
      MGT_RXREADY_o : out std_logic;

      MGT_TX_ALIGNED_o : out std_logic;
      MGT_TX_PIPHASE_o : out std_logic_vector(6 downto 0);
      --==============--
      -- Data         --
      --==============--
      MGT_USRWORD_i    : in  std_logic_vector(255 downto 0);
      MGT_USRWORD_o    : out std_logic_vector(255 downto 0);

      --===============--
      -- Serial intf.  --
      --===============--
      RXn_i : in std_logic;
      RXp_i : in std_logic;

      TXn_o : out std_logic;
      TXp_o : out std_logic
      );
end xlx_ku_mgt_10g24_emu;

--! @brief MGT - Transceiver
--! @details The MGT module implements all the logic required to send the GBT frame on high speed
--! links: resets modules for the transceiver, Tx PLL and alignement logic to align the received word with the 
--! GBT frame header.
architecture structural of xlx_ku_mgt_10g24_emu is
   --================================ Signal Declarations ================================--

   component xlx_ku_mgt_ip_10g24_emu
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
         gtwiz_reset_qpll0lock_in           : in  std_logic_vector(0 downto 0);
         gtwiz_reset_rx_cdr_stable_out      : out std_logic_vector(0 downto 0);
         gtwiz_reset_tx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_reset_rx_done_out            : out std_logic_vector(0 downto 0);
         gtwiz_reset_qpll0reset_out         : out std_logic_vector(0 downto 0);
         gtwiz_userdata_tx_in               : in  std_logic_vector(63 downto 0);
         gtwiz_userdata_rx_out              : out std_logic_vector(63 downto 0);
         drpaddr_in                         : in  std_logic_vector(9 downto 0);
         drpclk_in                          : in  std_logic_vector(0 downto 0);
         drpdi_in                           : in  std_logic_vector(15 downto 0);
         drpen_in                           : in  std_logic_vector(0 downto 0);
         drpwe_in                           : in  std_logic_vector(0 downto 0);
         gthrxn_in                          : in  std_logic_vector(0 downto 0);
         gthrxp_in                          : in  std_logic_vector(0 downto 0);
         gtrefclk0_in                       : in  std_logic_vector(0 downto 0);
         qpll0clk_in                        : in  std_logic_vector(0 downto 0);
         qpll0refclk_in                     : in  std_logic_vector(0 downto 0);
         qpll1clk_in                        : in  std_logic_vector(0 downto 0);
         qpll1refclk_in                     : in  std_logic_vector(0 downto 0);
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
         rxoutclk_out                       : out std_logic_vector(0 downto 0);
         rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
         txbufstatus_out                    : out std_logic_vector(1 downto 0);
         txoutclk_out                       : out std_logic_vector(0 downto 0);
         txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
         );
   end component;

   component xlx_ku_mgt_ip_10g24_emu_example_gtwiz_userclk_tx is
      generic (
         P_CONTENTS                     : natural := 0;
         P_FREQ_RATIO_SOURCE_TO_USRCLK  : natural := 1;
         P_FREQ_RATIO_USRCLK_TO_USRCLK2 : natural := 2);
      port (
         gtwiz_userclk_tx_srcclk_in   : in  std_logic;
         gtwiz_userclk_tx_reset_in    : in  std_logic;
         gtwiz_userclk_tx_usrclk_out  : out std_logic;
         gtwiz_userclk_tx_usrclk2_out : out std_logic;
         gtwiz_userclk_tx_active_out  : out std_logic);
   end component;

   component xlx_ku_mgt_ip_10g24_emu_example_gtwiz_userclk_rx is
      generic (
         P_CONTENTS                     : natural := 0;
         P_FREQ_RATIO_SOURCE_TO_USRCLK  : natural := 1;
         P_FREQ_RATIO_USRCLK_TO_USRCLK2 : natural := 2);
      port (
         gtwiz_userclk_rx_srcclk_in   : in  std_logic;
         gtwiz_userclk_rx_reset_in    : in  std_logic;
         gtwiz_userclk_rx_usrclk_out  : out std_logic;
         gtwiz_userclk_rx_usrclk2_out : out std_logic;
         gtwiz_userclk_rx_active_out  : out std_logic);
   end component;

   -- Reset signals
   signal tx_reset_done    : std_logic := '0';
   signal rx_reset_done    : std_logic := '0';
   signal rxfsm_reset_done : std_logic := '0';

   signal rxBuffBypassRst                : std_logic := '0';
   signal gtwiz_userclk_tx_active_int    : std_logic := '0';
   signal gtwiz_userclk_rx_active_int    : std_logic := '0';
   signal gtwiz_buffbypass_rx_reset_in_s : std_logic := '0';

   signal txpmaresetdone : std_logic := '0';
   signal rxpmaresetdone : std_logic := '0';

   signal rx_reset_sig : std_logic := '0';
   signal tx_reset_sig : std_logic := '0';

   signal MGT_USRWORD_RX_s : std_logic_vector(63 downto 0) := (others => '0');
   signal MGT_USRWORD_TX_s : std_logic_vector(63 downto 0) := (others => '0');

   -- Clock signals
   signal rx_wordclk_sig : std_logic := '0';
   signal tx_wordclk_sig : std_logic := '0';

   signal rx_wordclk40_sig : std_logic := '0';
   signal tx_wordclk40_sig : std_logic := '0';

   signal rx_wordclk_int_sig : std_logic := '0';
   signal tx_wordclk_int_sig : std_logic := '0';

   signal rxoutclk_sig : std_logic := '0';
   signal txoutclk_sig : std_logic := '0';

   -- Tx phase aligner signals
   signal MGT_TX_ALIGNED_s : std_logic := '0';

   signal MGT_FREEDRPCLK_sig : std_logic := '0';

--=================================================================================================--
begin  --========####   Architecture Body   ####========-- 
--=================================================================================================--

   --==================================== User Logic =====================================--

   --=============--
   -- Assignments --
   --=============--              
   MGT_TXREADY_o    <= tx_reset_done and MGT_TX_ALIGNED_s;
   MGT_TX_ALIGNED_o <= MGT_TX_ALIGNED_s;

   MGT_RXREADY_o <= rx_reset_done and rxfsm_reset_done;

   MGT_RXUSRCLK_o <= rx_wordclk40_sig;
   MGT_TXUSRCLK_o <= tx_wordclk40_sig;

   rx_reset_sig <= MGT_RXRESET_i or not(tx_reset_done and MGT_TX_ALIGNED_s);
   tx_reset_sig <= MGT_TXRESET_i;

   rxBuffBypassRst <= not(gtwiz_userclk_rx_active_int) or (not(tx_reset_done) and not(MGT_TX_ALIGNED_s));

   resetDoneSynch_rx : entity surf.RstSync
      port map(
         clk      => rx_wordClk_sig,
         asyncRst => rxBuffBypassRst,
         syncRst  => gtwiz_buffbypass_rx_reset_in_s);

   -- rxWordPipeline_proc : process(rx_reset_done, rx_wordclk_sig)
   -- begin
   -- if rx_reset_done = '0' then
   -- MGT_USRWORD_o <= (others => '0');
   -- elsif rising_edge(rx_wordclk_sig) then
   -- MGT_USRWORD_o <= MGT_USRWORD_s;
   -- end if;
   -- end process;

   gtwiz_userclk_tx_inst : xlx_ku_mgt_ip_10g24_emu_example_gtwiz_userclk_tx
      port map(
         gtwiz_userclk_tx_srcclk_in   => txoutclk_sig,
         gtwiz_userclk_tx_reset_in    => tx_reset_sig,
         gtwiz_userclk_tx_usrclk_out  => tx_wordclk_int_sig,
         gtwiz_userclk_tx_usrclk2_out => tx_wordclk_sig,
         gtwiz_userclk_tx_active_out  => gtwiz_userclk_tx_active_int);

   U_tx_wordclk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)
      port map (
         I   => tx_wordclk_sig,
         CE  => '1',
         CLR => '0',
         O   => tx_wordclk40_sig);

   gtwiz_userclk_rx_inst : xlx_ku_mgt_ip_10g24_emu_example_gtwiz_userclk_rx
      port map(
         gtwiz_userclk_rx_srcclk_in   => rxoutclk_sig,
         gtwiz_userclk_rx_reset_in    => rx_reset_sig,
         gtwiz_userclk_rx_usrclk_out  => rx_wordclk_int_sig,
         gtwiz_userclk_rx_usrclk2_out => rx_wordclk_sig,
         gtwiz_userclk_rx_active_out  => gtwiz_userclk_rx_active_int);

   -- U_rx_wordclk : BUFGCE_DIV
   -- generic map (
   -- BUFGCE_DIVIDE => 4)
   -- port map (
   -- I   => rx_wordclk_sig,
   -- CE  => '1',
   -- CLR => '0',
   -- O   => rx_wordclk40_sig);

   rx_wordclk40_sig <= rx_wordclk_sig;
   MGT_RX_REC_CLK_o <= rx_wordclk_sig;

   U_Gearbox_TX : entity surf.AsyncGearbox
      generic map (
         SLAVE_WIDTH_G        => 256,
         MASTER_WIDTH_G       => 64,
         -- Pipelining generics
         INPUT_PIPE_STAGES_G  => 0,
         OUTPUT_PIPE_STAGES_G => 0,
         -- Async FIFO generics
         FIFO_MEMORY_TYPE_G   => "distributed",
         FIFO_ADDR_WIDTH_G    => 5)
      port map (
         -- Slave Interface
         slaveClk   => tx_wordclk40_sig,
         slaveRst   => '0',
         slaveData  => MGT_USRWORD_i,
         -- Master Interface
         masterClk  => tx_wordclk_sig,
         masterRst  => '0',
         masterData => MGT_USRWORD_TX_s);

   -- U_Gearbox_RX : entity surf.AsyncGearbox
   -- generic map (
   -- SLAVE_WIDTH_G        => 64,
   -- MASTER_WIDTH_G       => 256,
   -- -- Pipelining generics
   -- INPUT_PIPE_STAGES_G  => 0,
   -- OUTPUT_PIPE_STAGES_G => 0,
   -- -- Async FIFO generics
   -- FIFO_MEMORY_TYPE_G   => "distributed",
   -- FIFO_ADDR_WIDTH_G    => 5)
   -- port map (
   -- slip       => MGT_RXSlide_i,
   -- -- Slave Interface
   -- slaveClk   => rx_wordclk_sig,
   -- slaveRst   => '0',
   -- slaveData  => MGT_USRWORD_RX_s,
   -- -- Master Interface
   -- masterClk  => rx_wordclk40_sig,
   -- masterRst  => '0',
   -- masterData => MGT_USRWORD_o);

   EMULATE_OVERSAMPLING :
   for i in 63 downto 0 generate
      MGT_USRWORD_o((4*i)+3 downto (4*i)) <= (others => MGT_USRWORD_RX_s(i));
   end generate EMULATE_OVERSAMPLING;

   xlx_ku_mgt_std_i : xlx_ku_mgt_ip_10g24_emu
      port map (

         gtwiz_reset_qpll0reset_out(0) => QPLL_RST_o,
         gtwiz_reset_qpll0lock_in(0)   => QPLL_LOCK_i(0),
         qpll0clk_in(0)                => QPLL_CLK_i(0),
         qpll0refclk_in(0)             => QPLL_REFCLK_i(0),
         qpll1clk_in(0)                => QPLL_CLK_i(1),
         qpll1refclk_in(0)             => QPLL_REFCLK_i(1),

         rxusrclk_in(0)  => rx_wordclk_int_sig,
         rxusrclk2_in(0) => rx_wordclk_sig,
         rxoutclk_out(0) => rxoutclk_sig,
         txusrclk_in(0)  => tx_wordclk_int_sig,
         txusrclk2_in(0) => tx_wordclk_sig,
         txoutclk_out(0) => txoutclk_sig,

         gtwiz_userclk_tx_active_in(0) => gtwiz_userclk_tx_active_int,
         gtwiz_userclk_rx_active_in(0) => gtwiz_userclk_rx_active_int,
         gtwiz_userclk_tx_reset_in(0)  => tx_reset_sig,

         gtwiz_buffbypass_rx_reset_in(0)      => gtwiz_buffbypass_rx_reset_in_s,
         gtwiz_buffbypass_rx_start_user_in(0) => '0',
         gtwiz_buffbypass_rx_done_out(0)      => rxfsm_reset_done,
         gtwiz_buffbypass_rx_error_out        => open,

         gtwiz_reset_clk_freerun_in(0) => MGT_FREEDRPCLK_sig,

         gtwiz_reset_all_in(0)                 => '0',
         gtwiz_reset_tx_pll_and_datapath_in(0) => tx_reset_sig,
         gtwiz_reset_tx_datapath_in(0)         => '0',
         gtwiz_reset_tx_done_out(0)            => tx_reset_done,

         gtwiz_reset_rx_pll_and_datapath_in(0) => '0',
         gtwiz_reset_rx_datapath_in(0)         => rx_reset_sig,
         gtwiz_reset_rx_cdr_stable_out         => open,
         gtwiz_reset_rx_done_out(0)            => rx_reset_done,

         gtwiz_userdata_tx_in  => MGT_USRWORD_TX_s,
         gtwiz_userdata_rx_out => MGT_USRWORD_RX_s,

         drpclk_in(0) => MGT_FREEDRPCLK_sig,

         gthrxn_in(0)  => RXn_i,
         gthrxp_in(0)  => RXp_i,
         gthtxn_out(0) => TXn_o,
         gthtxp_out(0) => TXp_o,

         gtrefclk0_in(0) => MGT_REFCLK_i,

         rxslide_in(0) => MGT_RXSlide_i,
         -- rxslide_in(0) => '0',

         rxpmaresetdone_out(0) => rxpmaresetdone,
         txpmaresetdone_out(0) => txpmaresetdone,

         -- DRP bus (used by the tx phase aligner)
         drpaddr_in  => (others => '0'),
         drpdi_in    => (others => '0'),
         drpen_in(0) => '0',
         drpwe_in(0) => '0',
         drpdo_out   => open,
         drprdy_out  => open,

         -- PI control / monitoring signals
         txpippmen_in(0)     => '0',
         txpippmovrden_in(0) => '0',
         txpippmpd_in(0)     => '0',
         txpippmsel_in(0)    => '0',
         txpippmstepsize_in  => (others => '0'),

         -- Tx buffer status
         txbufstatus_out => open);

   MGT_TX_ALIGNED_s <= tx_reset_done;

   U_drp_clk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)
      port map (
         I   => MGT_FREEDRPCLK_i,       -- 156.25 MHz 
         CE  => '1',
         CLR => '0',
         O   => MGT_FREEDRPCLK_sig);    -- 39.0625 MHz

end structural;
--=================================================================================================--
--#################################################################################################--
--=================================================================================================--
