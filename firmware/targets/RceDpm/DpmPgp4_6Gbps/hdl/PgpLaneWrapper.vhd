-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
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
use surf.AxiStreamPkg.all;
use surf.Pgp4Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity PgpLaneWrapper is
   generic (
      TPD_G             : time             := 1 ns;
      NUM_VC_G          : positive         := 4;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      RATE_G            : string           := "6.25Gbps";  -- or "6.25Gbps" or "3.125Gbps"
      TX_POLARITY_G     : sl               := '0';
      RX_POLARITY_G     : sl               := '0';
      AXIL_BASE_ADDR_G  : slv(31 downto 0) := (others => '0');
      AXIL_CLK_FREQ_G   : real             := 125.0E+6);
   port (
      -- RTM High Speed
      pgpRefClkIn     : in  sl;
      pgpGtTxP        : out sl;
      pgpGtTxN        : out sl;
      pgpGtRxP        : in  sl;
      pgpGtRxN        : in  sl;
      -- DMA Interface (dmaClk domain)
      dmaClk          : in  sl;
      dmaRst          : in  sl;
      dmaObMaster     : in  AxiStreamMasterType;
      dmaObSlave      : out AxiStreamSlaveType;
      dmaIbMaster     : out AxiStreamMasterType;
      dmaIbSlave      : in  AxiStreamSlaveType;
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end PgpLaneWrapper;

architecture mapping of PgpLaneWrapper is

   signal pgpClk : sl;
   signal pgpRst : sl;

   signal pgpRxIn  : Pgp4RxInType := PGP4_RX_IN_INIT_C;
   signal pgpRxOut : Pgp4RxOutType;

   signal pgpTxIn  : Pgp4TxInType := PGP4_TX_IN_INIT_C;
   signal pgpTxOut : Pgp4TxOutType;

   signal pgpTxMasters : AxiStreamMasterArray(NUM_VC_G-1 downto 0);
   signal pgpTxSlaves  : AxiStreamSlaveArray(NUM_VC_G-1 downto 0);

   signal pgpRxMasters : AxiStreamMasterArray(NUM_VC_G-1 downto 0);
   signal pgpRxCtrl    : AxiStreamCtrlArray(NUM_VC_G-1 downto 0);

begin

   U_PgpLane : entity surf.Pgp4Gtx7Wrapper
      generic map (
         TPD_G            => TPD_G,
         NUM_LANES_G      => 1,
         NUM_VC_G         => NUM_VC_G,
         RATE_G           => RATE_G,
         REFCLK_FREQ_G    => 250.0E+6,  -- Units of Hz
         REFCLK_G         => true,      --  true = pgpRefClkIn
         EN_PGP_MON_G     => true,
         TX_POLARITY_G    => (others => TX_POLARITY_G),
         RX_POLARITY_G    => (others => RX_POLARITY_G),
         AXIL_BASE_ADDR_G => AXIL_BASE_ADDR_G,
         AXIL_CLK_FREQ_G  => AXIL_CLK_FREQ_G)
      port map (
         -- Stable Clock and Reset
         stableClk       => axilClk,
         stableRst       => axilRst,
         -- Gt Serial IO
         pgpGtTxP(0)     => pgpGtTxP,
         pgpGtTxN(0)     => pgpGtTxN,
         pgpGtRxP(0)     => pgpGtRxP,
         pgpGtRxN(0)     => pgpGtRxN,
         -- GT Clocking
         pgpRefClkIn     => pgpRefClkIn,
         -- Clocking
         pgpClk(0)       => pgpClk,
         pgpClkRst(0)    => pgpRst,
         -- Non VC Rx Signals
         pgpRxIn(0)      => pgpRxIn,
         pgpRxOut(0)     => pgpRxOut,
         -- Non VC Tx Signals
         pgpTxIn(0)      => pgpTxIn,
         pgpTxOut(0)     => pgpTxOut,
         -- Frame Transmit Interface
         pgpTxMasters    => pgpTxMasters,
         pgpTxSlaves     => pgpTxSlaves,
         -- Frame Receive Interface
         pgpRxMasters    => pgpRxMasters,
         pgpRxCtrl       => pgpRxCtrl,
         -- AXI-Lite Register Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave);

   U_Tx : entity work.PgpLaneTx
      generic map (
         TPD_G             => TPD_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_G,
         NUM_VC_G          => NUM_VC_G)
      port map (
         -- DMA Interface (dmaClk domain)
         dmaClk       => dmaClk,
         dmaRst       => dmaRst,
         dmaObMaster  => dmaObMaster,
         dmaObSlave   => dmaObSlave,
         -- PGP Interface
         pgpClk       => pgpClk,
         pgpRst       => pgpRst,
         rxlinkReady  => pgpRxOut.linkReady,
         txlinkReady  => pgpTxOut.linkReady,
         pgpTxMasters => pgpTxMasters,
         pgpTxSlaves  => pgpTxSlaves);

   U_Rx : entity work.PgpLaneRx
      generic map (
         TPD_G             => TPD_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_G,
         NUM_VC_G          => NUM_VC_G)
      port map (
         -- DMA Interface (dmaClk domain)
         dmaClk       => dmaClk,
         dmaRst       => dmaRst,
         dmaIbMaster  => dmaIbMaster,
         dmaIbSlave   => dmaIbSlave,
         -- PGP RX Interface (pgpRxClk domain)
         pgpClk       => pgpClk,
         pgpRst       => pgpRst,
         rxlinkReady  => pgpRxOut.linkReady,
         pgpRxMasters => pgpRxMasters,
         pgpRxCtrl    => pgpRxCtrl);

end mapping;
