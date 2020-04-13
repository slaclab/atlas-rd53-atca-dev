-------------------------------------------------------------------------------
-- File       : AuroraRxLaneWrapper.vhd
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

library atlas_rd53_fw_lib;

entity AuroraRxLaneWrapper is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      -- RD53 ASIC Serial Interface  (clk160MHz domain)
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      serDesData      : in  slv(7 downto 0);
      dlyLoad         : out sl;
      dlyCfg          : out slv(8 downto 0);
      rxLinkUp        : out sl;
      selectRate      : out slv(1 downto 0);
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end AuroraRxLaneWrapper;

architecture mapping of AuroraRxLaneWrapper is

   constant STATUS_SIZE_C  : positive := 3;
   constant STATUS_WIDTH_C : positive := 16;

   type RegType is record
      lockingCntCfg  : slv(23 downto 0);
      eyescanCfg     : slv(7 downto 0);
      usrDlyCfg      : slv(8 downto 0);
      selectRate     : slv(1 downto 0);
      enUsrDlyCfg    : sl;
      polarity       : sl;
      cntRst         : sl;
      rollOverEn     : slv(STATUS_SIZE_C-1 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      lockingCntCfg  => ite(SIMULATION_G, x"00_0064", x"00_FFFF"),
      eyescanCfg     => toSlv(80, 8),
      usrDlyCfg      => (others => '0'),
      selectRate     => (others => '0'),
      enUsrDlyCfg    => '0',
      polarity       => '1',
      cntRst         => '1',
      rollOverEn     => (others => '0'),
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal statusOut : slv(STATUS_SIZE_C-1 downto 0);
   signal statusCnt : SlVectorArray(STATUS_SIZE_C-1 downto 0, STATUS_WIDTH_C-1 downto 0);

   signal linkUp    : sl;
   signal hdrErrDet : sl;
   signal bitSlip   : sl;
   signal sync      : RegType := REG_INIT_C;

begin

   selectRate <= sync.selectRate;
   rxLinkUp   <= linkUp;

   U_Rx : entity atlas_rd53_fw_lib.AuroraRxLane
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G)
      port map (
         -- RD53 ASIC Serial Interface
         serDesData    => serDesData,
         dlyLoad       => dlyLoad,
         dlyCfg        => dlyCfg,
         enUsrDlyCfg   => sync.enUsrDlyCfg,
         usrDlyCfg     => sync.usrDlyCfg,
         eyescanCfg    => sync.eyescanCfg,
         lockingCntCfg => sync.lockingCntCfg,
         hdrErrDet     => hdrErrDet,
         bitSlip       => bitSlip,
         polarity      => sync.polarity,
         selectRate    => sync.selectRate,
         -- Timing Interface
         clk160MHz     => clk160MHz,
         rst160MHz     => rst160MHz,
         -- Output
         rxLinkUp      => linkUp);

   comb : process (axilReadMaster, axilRst, axilWriteMaster, r, statusCnt,
                   statusOut) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.cntRst := '0';

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      axiSlaveRegisterR(axilEp, x"00", 0, muxSlVectorArray(statusCnt, 0));
      axiSlaveRegisterR(axilEp, x"04", 0, muxSlVectorArray(statusCnt, 1));
      axiSlaveRegisterR(axilEp, x"08", 0, muxSlVectorArray(statusCnt, 2));
      axiSlaveRegisterR(axilEp, x"0C", 0, statusOut);

      axiSlaveRegister (axilEp, x"10", 0, v.lockingCntCfg);
      axiSlaveRegister (axilEp, x"14", 0, v.eyescanCfg);
      axiSlaveRegister (axilEp, x"18", 0, v.usrDlyCfg);
      axiSlaveRegister (axilEp, x"1C", 0, v.selectRate);

      axiSlaveRegister (axilEp, x"20", 0, v.enUsrDlyCfg);
      axiSlaveRegister (axilEp, x"24", 0, v.polarity);

      axiSlaveRegister (axilEp, x"F8", 0, v.rollOverEn);
      axiSlaveRegister (axilEp, x"FC", 0, v.cntRst);

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

   U_enUsrDlyCfg : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk160MHz,
         dataIn  => r.enUsrDlyCfg,
         dataOut => sync.enUsrDlyCfg);

   U_usrDlyCfg : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 9)
      port map (
         clk     => clk160MHz,
         dataIn  => r.usrDlyCfg,
         dataOut => sync.usrDlyCfg);

   U_eyescanCfg : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 8)
      port map (
         clk     => clk160MHz,
         dataIn  => r.eyescanCfg,
         dataOut => sync.eyescanCfg);

   U_lockingCntCfg : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 24)
      port map (
         clk     => clk160MHz,
         dataIn  => r.lockingCntCfg,
         dataOut => sync.lockingCntCfg);

   U_polarity : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk160MHz,
         dataIn  => r.polarity,
         dataOut => sync.polarity);

   U_selectRate : entity surf.SynchronizerVector
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         clk     => clk160MHz,
         dataIn  => r.selectRate,
         dataOut => sync.selectRate);

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
         statusIn(2)  => bitSlip,
         statusIn(1)  => hdrErrDet,
         statusIn(0)  => linkUp,
         -- Output Status bit Signals (rdClk domain)
         statusOut    => statusOut,
         -- Status Bit Counters Signals (rdClk domain)
         cntRstIn     => r.cntRst,
         rollOverEnIn => r.rollOverEn,
         cntOut       => statusCnt,
         -- Clocks and Reset Ports
         wrClk        => clk160MHz,
         rdClk        => axilClk);

end mapping;
