-------------------------------------------------------------------------------
-- File       : AtlasRd53EmuLpGbtLaneReg.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

entity AtlasRd53EmuLpGbtLaneReg is
   generic (
      TPD_G       : time                  := 1 ns;
      NUM_ELINK_G : positive range 1 to 7 := 4);
   port (
      -- Config/status Interface (clk160MHz domain)
      clk160MHz         : in  sl;
      rst160MHz         : in  sl;
      downlinkUp        : in  sl;
      uplinkUp          : in  sl;
      rxLinkUp          : in  slv(NUM_ELINK_G-1 downto 0);
      invCmd            : out slv(NUM_ELINK_G-1 downto 0);
      dlyCmd            : out slv(NUM_ELINK_G-1 downto 0);
      downlinkRst       : out sl;
      uplinkRst         : out sl;
      invData           : out sl;
      linkDownPattern   : out slv(7 downto 0);
      -- Config/status Interface (uplinkClk domain)
      uplinkClk         : in  sl;
      fecMode           : out sl;       -- 1=FEC12, 0=FEC5
      fecDisable        : out sl;
      interleaverBypass : out sl;
      scramblerBypass   : out sl;
      txDummyFec12      : out Slv10Array(1 downto 0);
      txDummyFec5       : out Slv6Array(1 downto 0);
      bitOrderData32b   : out sl;
      debugMode         : out slv(6 downto 0);
      debugPatternA     : out Slv32Array(6 downto 0);
      debugPatternB     : out Slv32Array(6 downto 0);
      uplinkEcData      : out slv(1 downto 0);
      uplinkIcData      : out slv(1 downto 0);
      -- Config/status Interface (donwlinkClk domain)
      donwlinkClk       : in  sl;
      bitOrderCmd4b     : out sl;
      -- AXI-Lite Interface (axilClk domain)
      axilClk           : in  sl;
      axilRst           : in  sl;
      axilReadMaster    : in  AxiLiteReadMasterType;
      axilReadSlave     : out AxiLiteReadSlaveType;
      axilWriteMaster   : in  AxiLiteWriteMasterType;
      axilWriteSlave    : out AxiLiteWriteSlaveType);
end AtlasRd53EmuLpGbtLaneReg;

architecture mapping of AtlasRd53EmuLpGbtLaneReg is

   constant STATUS_SIZE_C  : positive := NUM_ELINK_G+2;
   constant STATUS_WIDTH_C : positive := 16;

   type RegType is record
      uplinkEcData      : slv(1 downto 0);
      uplinkIcData      : slv(1 downto 0);
      debugMode         : slv(6 downto 0);
      debugPatternA     : Slv32Array(6 downto 0);
      debugPatternB     : Slv32Array(6 downto 0);
      linkDownPattern   : slv(7 downto 0);
      invData           : sl;
      bitOrderData32b   : sl;
      bitOrderCmd4b     : sl;
      fecMode           : sl;
      fecDisable        : sl;
      interleaverBypass : sl;
      scramblerBypass   : sl;
      txDummyFec12      : Slv10Array(1 downto 0);
      txDummyFec5       : Slv6Array(1 downto 0);
      invCmd            : slv(NUM_ELINK_G-1 downto 0);
      dlyCmd            : slv(NUM_ELINK_G-1 downto 0);
      wdtRstEn          : slv(1 downto 0);
      downlinkRst       : sl;
      uplinkRst         : sl;
      cntRst            : sl;
      rollOverEn        : slv(STATUS_SIZE_C-1 downto 0);
      axilReadSlave     : AxiLiteReadSlaveType;
      axilWriteSlave    : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      uplinkEcData      => (others => '0'),
      uplinkIcData      => (others => '0'),
      debugMode         => (others => '0'),
      debugPatternA     => (others => x"AA_AA_AA_AA"),
      debugPatternB     => (others => x"55_55_55_55"),
      linkDownPattern   => x"00",
      invData           => '1',  -- Default to invert the polarity swap on mDP
      bitOrderData32b   => '1',  -- In section 7.1 eLink Group: “The bit shift in/out order for the eLink data inputs and outputs is MSB first.”
      bitOrderCmd4b     => '1',  -- In section 7.1 eLink Group: “The bit shift in/out order for the eLink data inputs and outputs is MSB first.”
      fecMode           => '1',         -- 1=FEC12(default), 0=FEC5
      fecDisable        => '0',
      interleaverBypass => '0',
      scramblerBypass   => '0',
      txDummyFec12      => (0 => "1001110011", 1 => "0110001100"),
      txDummyFec5       => (0 => "001100", 1 => "110011"),
      invCmd            => (others => '0'),
      dlyCmd            => (others => '0'),
      wdtRstEn          => "11",
      downlinkRst       => '0',
      uplinkRst         => '0',
      cntRst            => '1',
      rollOverEn        => (others => '0'),
      axilReadSlave     => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave    => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal statusOut : slv(STATUS_SIZE_C-1 downto 0);
   signal statusCnt : SlVectorArray(STATUS_SIZE_C-1 downto 0, STATUS_WIDTH_C-1 downto 0);

   signal wdtRst   : slv(1 downto 0);
   signal wdtReset : slv(1 downto 0);

begin

   ------------------------------
   -- Uplink WDT Reset Monitoring
   ------------------------------
   U_uplinkRst : entity surf.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(156.25E+6, 1.0))  -- 1s reset
      port map (
         arst   => wdtReset(0),
         clk    => axilClk,                           -- Stable clock reference
         rstOut => uplinkRst);

   U_WTD0 : entity surf.WatchDogRst
      generic map(
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(156.25E+6, 0.25))  -- 4 s timeout
      port map (
         clk    => axilClk,
         monIn  => uplinkUp,
         rstOut => wdtRst(0));

   wdtReset(0) <= (wdtRst(0) and r.wdtRstEn(0)) or r.uplinkRst;

   --------------------------------
   -- Downlink WDT Reset Monitoring
   --------------------------------
   U_downlinkRst : entity surf.PwrUpRst
      generic map (
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(156.25E+6, 1.0))  -- 1s reset
      port map (
         arst   => wdtReset(1),
         clk    => axilClk,                           -- Stable clock reference
         rstOut => downlinkRst);

   U_WTD1 : entity surf.WatchDogRst
      generic map(
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(156.25E+6, 0.1))  -- 10 s timeout
      port map (
         clk    => axilClk,
         monIn  => downlinkUp,
         rstOut => wdtRst(1));

   wdtReset(1) <= (wdtRst(1) and r.wdtRstEn(1)) or r.downlinkRst;

   comb : process (axilReadMaster, axilRst, axilWriteMaster, r, statusCnt,
                   statusOut) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.cntRst      := '0';
      v.downlinkRst := '0';
      v.uplinkRst   := '0';

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      for i in STATUS_SIZE_C-1 downto 0 loop
         axiSlaveRegisterR(axilEp, toSlv((4*i), 12), 0, muxSlVectorArray(statusCnt, i));
      end loop;
      axiSlaveRegisterR(axilEp, x"400", 0, statusOut);

      axiSlaveRegister (axilEp, x"800", 0, v.invCmd);
      axiSlaveRegister (axilEp, x"804", 0, v.dlyCmd);
      axiSlaveRegister (axilEp, x"808", 0, v.wdtRstEn);
      axiSlaveRegister (axilEp, x"80C", 0, v.fecMode);

      axiSlaveRegister (axilEp, x"810", 0, v.bitOrderCmd4b);
      axiSlaveRegister (axilEp, x"818", 0, v.bitOrderData32b);
      axiSlaveRegister (axilEp, x"81C", 0, v.invData);

      axiSlaveRegister (axilEp, x"820", 0, v.fecDisable);
      axiSlaveRegister (axilEp, x"824", 0, v.interleaverBypass);
      axiSlaveRegister (axilEp, x"828", 0, v.scramblerBypass);
      axiSlaveRegister (axilEp, x"82C", 0, v.linkDownPattern);

      axiSlaveRegister (axilEp, x"830", 0, v.txDummyFec12(0));
      axiSlaveRegister (axilEp, x"834", 0, v.txDummyFec12(1));
      axiSlaveRegister (axilEp, x"838", 0, v.txDummyFec5(0));
      axiSlaveRegister (axilEp, x"83C", 0, v.txDummyFec5(1));

      axiSlaveRegister (axilEp, x"840", 0, v.debugMode);

      axiSlaveRegister (axilEp, x"850", 0, v.uplinkEcData);
      axiSlaveRegister (axilEp, x"854", 0, v.uplinkIcData);

      for i in 6 downto 0 loop
         axiSlaveRegister (axilEp, toSlv(2304+4*i, 12), 0, v.debugPatternA(i));  -- Address Space = [0x900:0x91B]
         axiSlaveRegister (axilEp, toSlv(2336+4*i, 12), 0, v.debugPatternB(i));  -- Address Space = [0x920:0x92B]
      end loop;

      axiSlaveRegister (axilEp, x"FF0", 0, v.downlinkRst);
      axiSlaveRegister (axilEp, x"FF4", 0, v.uplinkRst);

      axiSlaveRegister (axilEp, x"FF8", 0, v.rollOverEn);
      axiSlaveRegister (axilEp, x"FFC", 0, v.cntRst);

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

   U_linkDownPattern : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 8)
      port map (
         clk     => clk160MHz,
         dataIn  => r.linkDownPattern,
         dataOut => linkDownPattern);

   U_invCmd : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => NUM_ELINK_G)
      port map (
         clk     => clk160MHz,
         dataIn  => r.invCmd,
         dataOut => invCmd);

   U_dlyCmd : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => NUM_ELINK_G)
      port map (
         clk     => clk160MHz,
         dataIn  => r.dlyCmd,
         dataOut => dlyCmd);

   U_uplinkClkSync : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 4)
      port map (
         clk        => uplinkClk,
         -- Input
         dataIn(0)  => r.fecMode,
         dataIn(1)  => r.fecDisable,
         dataIn(2)  => r.interleaverBypass,
         dataIn(3)  => r.scramblerBypass,
         -- Output
         dataOut(0) => fecMode,
         dataOut(1) => fecDisable,
         dataOut(2) => interleaverBypass,
         dataOut(3) => scramblerBypass);

   GEN_TX_DUMMY :
   for i in 1 downto 0 generate

      U_txDummyFec12 : entity surf.SynchronizerVector
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 10)
         port map (
            clk     => uplinkClk,
            dataIn  => r.txDummyFec12(i),
            dataOut => txDummyFec12(i));

      U_txDummyFec5 : entity surf.SynchronizerVector
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 6)
         port map (
            clk     => uplinkClk,
            dataIn  => r.txDummyFec5(i),
            dataOut => txDummyFec5(i));

   end generate GEN_TX_DUMMY;

   U_debugMode : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 7)
      port map (
         clk     => uplinkClk,
         dataIn  => r.debugMode,
         dataOut => debugMode);

   GEN_VEC :
   for i in 6 downto 0 generate

      U_debugPatternA : entity surf.SynchronizerVector
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 32)
         port map (
            clk     => uplinkClk,
            dataIn  => r.debugPatternA(i),
            dataOut => debugPatternA(i));

      U_debugPatternB : entity surf.SynchronizerVector
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 32)
         port map (
            clk     => uplinkClk,
            dataIn  => r.debugPatternB(i),
            dataOut => debugPatternB(i));

   end generate GEN_VEC;

   U_uplinkEcData : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         clk     => uplinkClk,
         dataIn  => r.uplinkEcData,
         dataOut => uplinkEcData);

   U_uplinkIcData : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         clk     => uplinkClk,
         dataIn  => r.uplinkIcData,
         dataOut => uplinkIcData);

   U_bitOrderCmd4b : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => donwlinkClk,
         dataIn  => r.bitOrderCmd4b,
         dataOut => bitOrderCmd4b);

   U_bitOrderData32b : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => uplinkClk,
         dataIn  => r.bitOrderData32b,
         dataOut => bitOrderData32b);

   U_invData : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk160MHz,
         dataIn  => r.invData,
         dataOut => invData);

   U_SyncStatusVector : entity surf.SyncStatusVector
      generic map (
         TPD_G          => TPD_G,
         COMMON_CLK_G   => false,
         OUT_POLARITY_G => '1',
         CNT_RST_EDGE_G => false,
         CNT_WIDTH_G    => STATUS_WIDTH_C,
         WIDTH_G        => STATUS_SIZE_C)
      port map (
         -- Input Status bit Signals (wrClk domain)
         statusIn(NUM_ELINK_G+1)          => uplinkUp,
         statusIn(NUM_ELINK_G+0)          => downlinkUp,
         statusIn(NUM_ELINK_G-1 downto 0) => rxLinkUp,
         -- Output Status bit Signals (rdClk domain)
         statusOut                        => statusOut,
         -- Status Bit Counters Signals (rdClk domain)
         cntRstIn                         => r.cntRst,
         rollOverEnIn                     => r.rollOverEn,
         cntOut                           => statusCnt,
         -- Clocks and Reset Ports
         wrClk                            => clk160MHz,
         rdClk                            => axilClk);

end mapping;
