-------------------------------------------------------------------------------
-- File       : ApplicationTb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the FPGA module
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.AtlasAtcaLinkAggPkg.all;

entity ApplicationTb is end ApplicationTb;

architecture testbed of ApplicationTb is

   constant TPD_G      : time     := 1 ns;
   constant CNT_SIZE_C : positive := 384*400;

   component Rd53aWrapper
      port (
         HIT_CLK         : out sl;
         HIT             : in  slv(CNT_SIZE_C-1 downto 0);
         ------------------------
         -- Power-on Resets (POR)
         ------------------------
         POR_EXT_CAP_PAD : in  sl;
         -------------------------------------------------------------
         -- Clock Data Recovery (CDR) input command/data stream [SLVS]
         -------------------------------------------------------------
         CMD_P_PAD       : in  sl;
         CMD_N_PAD       : in  sl;
         -----------------------------------------------------
         -- 4x general-purpose SLVS outputs, including Hit-ORs
         -----------------------------------------------------
         GPLVDS0_P_PAD   : out sl;
         GPLVDS0_N_PAD   : out sl;
         GPLVDS1_P_PAD   : out sl;
         GPLVDS1_N_PAD   : out sl;
         GPLVDS2_P_PAD   : out sl;
         GPLVDS2_N_PAD   : out sl;
         GPLVDS3_P_PAD   : out sl;
         GPLVDS3_N_PAD   : out sl;
         ------------------------------------------------
         -- 4x serial output data links @ 1.28 Gb/s [CML]
         ------------------------------------------------
         GTX0_P_PAD      : out sl;
         GTX0_N_PAD      : out sl;
         GTX1_P_PAD      : out sl;
         GTX1_N_PAD      : out sl;
         GTX2_P_PAD      : out sl;
         GTX2_N_PAD      : out sl;
         GTX3_P_PAD      : out sl;
         GTX3_N_PAD      : out sl);
   end component;

   signal hitClk  : sl                            := '0';
   signal cnt     : slv(3 downto 0)               := (others => '0');
   signal hit     : slv(CNT_SIZE_C-1 downto 0)    := (others => '0');
   signal hitPntr : natural range 0 to CNT_SIZE_C := 0;

   signal dPortRstL  : sl                     := '0';
   signal dPortDataP : Slv4Array(23 downto 0) := (others => x"0");
   signal dPortDataN : Slv4Array(23 downto 0) := (others => x"F");
   signal dPortHitP  : Slv4Array(23 downto 0) := (others => x"0");
   signal dPortHitN  : Slv4Array(23 downto 0) := (others => x"F");
   signal dPortCmdP  : slv(23 downto 0)       := (others => '0');
   signal dPortCmdN  : slv(23 downto 0)       := (others => '1');

   signal clk156P : sl := '0';
   signal clk156N : sl := '1';
   signal rst156  : sl := '1';

   signal clk160P : sl := '0';
   signal clk160N : sl := '1';

   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal dpmToRtmP : Slv23Array(3 downto 0) := (others => (others => 'Z'));
   signal dpmToRtmN : Slv23Array(3 downto 0) := (others => (others => 'Z'));
   signal rtmToDpmP : Slv24Array(3 downto 0) := (others => (others => 'Z'));
   signal rtmToDpmN : Slv24Array(3 downto 0) := (others => (others => 'Z'));

begin

   ---------------------------------------------------
   -- Only simulating 1 of the 24 DPORT pair interfaces
   ---------------------------------------------------
   GEN_VEC : for i in 0 downto 0 generate
      U_ASIC : Rd53aWrapper
         port map (
            HIT_CLK         => hitClk,
            HIT             => hit,
            ------------------------
            -- Power-on Resets (POR)
            ------------------------
            POR_EXT_CAP_PAD => dPortRstL,
            -------------------------------------------------------------
            -- Clock Data Recovery (CDR) input command/data stream [SLVS]
            -------------------------------------------------------------
            CMD_P_PAD       => dPortCmdP(i),
            CMD_N_PAD       => dPortCmdN(i),
            -----------------------------------------------------
            -- 4x general-purpose SLVS outputs, including Hit-ORs
            -----------------------------------------------------
            GPLVDS0_P_PAD   => dPortHitP(i)(0),
            GPLVDS0_N_PAD   => dPortHitN(i)(0),
            GPLVDS1_P_PAD   => dPortHitP(i)(1),
            GPLVDS1_N_PAD   => dPortHitN(i)(1),
            GPLVDS2_P_PAD   => dPortHitP(i)(2),
            GPLVDS2_N_PAD   => dPortHitN(i)(2),
            GPLVDS3_P_PAD   => dPortHitP(i)(3),
            GPLVDS3_N_PAD   => dPortHitN(i)(3),
            ------------------------------------------------
            -- 4x serial output data links @ 1.28 Gb/s [CML]
            ------------------------------------------------
            GTX0_P_PAD      => dPortDataP(i)(0),
            GTX0_N_PAD      => dPortDataN(i)(0),
            GTX1_P_PAD      => dPortDataP(i)(1),
            GTX1_N_PAD      => dPortDataN(i)(1),
            GTX2_P_PAD      => dPortDataP(i)(2),
            GTX2_N_PAD      => dPortDataN(i)(2),
            GTX3_P_PAD      => dPortDataP(i)(3),
            GTX3_N_PAD      => dPortDataN(i)(3));
   end generate GEN_VEC;


   U_Clk160 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => clk160P,
         clkN => clk160N,
         rstL => dPortRstL);

   U_Clk156 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.4 ns,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => clk156P,
         clkN => clk156N,
         rst  => rst156);

   U_RtmMapping : entity work.AtlasRd53RtmSimMapping
      generic map (
         TPD_G => TPD_G)
      port map (
         -- mDP DATA/CMD Interface
         dPortDataP => dPortDataP,
         dPortDataN => dPortDataN,
         dPortCmdP  => dPortCmdP,
         dPortCmdN  => dPortCmdN,
         -- RTM Ports (188 diff. pairs to RTM interface)
         dpmToRtmP  => dpmToRtmP,
         dpmToRtmN  => dpmToRtmN,
         rtmToDpmP  => rtmToDpmP,
         rtmToDpmN  => rtmToDpmN);

   U_TcpToAxiLite : entity work.RogueTcpMemoryWrap
      generic map (
         TPD_G      => TPD_G,
         PORT_NUM_G => 7000)
      port map (
         axilClk         => clk156P,
         axilRst         => rst156,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave);

   U_App : entity work.Application
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => true)
      port map (
         -----------------------------
         --  Interfaces to Application
         -----------------------------
         -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
         axilClk         => clk156P,
         axilRst         => rst156,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- Misc. Interface 
         ref156Clk       => clk156P,
         ref156Rst       => rst156,
         ipmiBsi         => BSI_BUS_INIT_C,
         --------------------- 
         --  Application Ports
         --------------------- 
         -- Jitter Cleaner PLL Ports
         fpgaToPllClkP   => open,
         fpgaToPllClkN   => open,
         pllToFpgaClkP   => clk160P,
         pllToFpgaClkN   => clk160N,
         -- Front Panel Clock/LED/TTL Ports
         smaClkP         => '0',
         smaClkN         => '1',
         ledRedL         => open,
         ledBlueL        => open,
         ledGreenL       => open,
         fpTrigInL       => '1',
         fpBusyOut       => open,
         fpSpareOut      => open,
         fpSpareInL      => '1',
         -- Backplane Clocks Ports
         bpClkIn         => (others => '0'),
         bpClkOut        => open,
         -- Front Panel QSFP+ Ports
         qsfpEthRefClkP  => clk156P,
         qsfpEthRefClkN  => clk156N,
         qsfpRef160ClkP  => clk160P,
         qsfpRef160ClkN  => clk160N,
         qsfpPllClkP     => clk160P,
         qsfpPllClkN     => clk160N,
         qsfpTxP         => open,
         qsfpTxN         => open,
         qsfpRxP         => (others => (others => '0')),
         qsfpRxN         => (others => (others => '1')),
         -- Front Panel SFP+ Ports
         sfpEthRefClkP   => clk156P,
         sfpEthRefClkN   => clk156N,
         sfpRef160ClkP   => clk160P,
         sfpRef160ClkN   => clk160N,
         sfpPllClkP      => clk160P,
         sfpPllClkN      => clk160N,
         sfpTxP          => open,
         sfpTxN          => open,
         sfpRxP          => (others => '0'),
         sfpRxN          => (others => '1'),
         -- RTM Ports (188 diff. pairs to RTM interface)
         dpmToRtmP       => dpmToRtmP,
         dpmToRtmN       => dpmToRtmN,
         rtmToDpmP       => rtmToDpmP,
         rtmToDpmN       => rtmToDpmN);

end testbed;
