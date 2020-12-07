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
use surf.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity SmaTxClkout is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Clocks and Resets
      gtRefClk        : in  sl;
      drpClk          : in  sl;
      drpRst          : in  sl;
      -- Broadcast External Timing Clock
      smaTxP          : out sl;
      smaTxN          : out sl;
      smaRxP          : in  sl;         -- RX unused
      smaRxN          : in  sl);        -- RX unused
end SmaTxClkout;

architecture mapping of SmaTxClkout is

   component sma_tx_clkout
      port (
         gtwiz_userclk_tx_reset_in          : in  std_logic_vector(0 downto 0);
         gtwiz_userclk_tx_srcclk_out        : out std_logic_vector(0 downto 0);
         gtwiz_userclk_tx_usrclk_out        : out std_logic_vector(0 downto 0);
         gtwiz_userclk_tx_usrclk2_out       : out std_logic_vector(0 downto 0);
         gtwiz_userclk_tx_active_out        : out std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_reset_in          : in  std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_srcclk_out        : out std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_usrclk_out        : out std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_usrclk2_out       : out std_logic_vector(0 downto 0);
         gtwiz_userclk_rx_active_out        : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_reset_in       : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_start_user_in  : in  std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_done_out       : out std_logic_vector(0 downto 0);
         gtwiz_buffbypass_tx_error_out      : out std_logic_vector(0 downto 0);
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
         gtwiz_userdata_tx_in               : in  std_logic_vector(15 downto 0);
         gtwiz_userdata_rx_out              : out std_logic_vector(15 downto 0);
         cpllrefclksel_in                   : in  std_logic_vector(2 downto 0);
         drpclk_in                          : in  std_logic_vector(0 downto 0);
         gtgrefclk_in                       : in  std_logic_vector(0 downto 0);
         gthrxn_in                          : in  std_logic_vector(0 downto 0);
         gthrxp_in                          : in  std_logic_vector(0 downto 0);
         gtrefclk0_in                       : in  std_logic_vector(0 downto 0);
         txdiffctrl_in                      : in  std_logic_vector(4 downto 0);
         gthtxn_out                         : out std_logic_vector(0 downto 0);
         gthtxp_out                         : out std_logic_vector(0 downto 0);
         gtpowergood_out                    : out std_logic_vector(0 downto 0);
         rxpmaresetdone_out                 : out std_logic_vector(0 downto 0);
         txpmaresetdone_out                 : out std_logic_vector(0 downto 0)
         );
   end component;

   type RegType is record
      txPattern      : slv(15 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      txPattern      => b"1010_1010_1010_1010",  -- 1.28 GHz clock pattern @ 2.56Gb/s
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

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
         gtwiz_userdata_tx_in               => r.txPattern,
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



   comb : process (axilReadMaster, axilRst, axilWriteMaster, r) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegister (axilEp, x"0", 0, v.txPattern);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -- Outputs
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;

      -- Synchronous Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
