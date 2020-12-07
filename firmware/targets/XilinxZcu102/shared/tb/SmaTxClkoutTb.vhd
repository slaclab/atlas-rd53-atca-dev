-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the SmaTxClkout module
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
use surf.AxiLitePkg.all;

entity SmaTxClkoutTb is end SmaTxClkoutTb;

architecture testbed of SmaTxClkoutTb is

   constant CLK_PERIOD_G : time := 6.4 ns;  -- 6.4 = 1/156.25 MHz
   constant TPD_G        : time := CLK_PERIOD_G/4;

   signal axilReadMaster  : AxiLiteReadMasterType  := AXI_LITE_READ_MASTER_INIT_C;
   signal axilReadSlave   : AxiLiteReadSlaveType   := AXI_LITE_READ_SLAVE_INIT_C;
   signal axilWriteMaster : AxiLiteWriteMasterType := AXI_LITE_WRITE_MASTER_INIT_C;
   signal axilWriteSlave  : AxiLiteWriteSlaveType  := AXI_LITE_WRITE_SLAVE_INIT_C;

   signal axilClk : sl := '0';
   signal axilRst : sl := '1';

   signal clk160MHz : sl := '0';
   signal rst160MHz : sl := '1';

   signal smaTxP : sl := '0';
   signal smaTxN : sl := '1';

   signal smaRxP : sl := '0';
   signal smaRxN : sl := '1';

begin

   --------------------
   -- Clocks and Resets
   --------------------
   U_axilClk : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => CLK_PERIOD_G,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => axilClk,
         rst  => axilRst);

   U_clk160MHz : entity surf.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.25 ns,  -- 6.25 ns = 1/160 MHz
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => clk160MHz,
         rst  => rst160MHz);

   -----------------------
   -- Module to be tested
   -----------------------
   U_SmaTxClkout : entity work.SmaTxClkout
      generic map (
         TPD_G => TPD_G)
      port map (
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- Clocks and Resets
         gtRefClk        => clk160MHz,
         drpClk          => clk160MHz,
         drpRst          => rst160MHz,
         -- Broadcast External Timing Clock
         smaTxP          => smaTxP,
         smaTxN          => smaTxN,
         smaRxP          => smaRxP,
         smaRxN          => smaRxN);

end testbed;
