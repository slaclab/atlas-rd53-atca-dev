-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for PGPv4 communication
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS ALTIROC DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS ALTIROC DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.Pgp4Pkg.all;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

entity Pgp4PhyGthQuad is
   generic (
      TPD_G            : time     := 1 ns;
      SIMULATION_G     : boolean  := false;
      NUM_VC_G         : positive := 16;
      AXIL_BASE_ADDR_G : slv(31 downto 0));
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Streaming Interface (axilClk domain)
      rxConfigMasters : out AxiStreamMasterArray(2*NUM_VC_G-1 downto 0);
      rxConfigSlaves  : in  AxiStreamSlaveArray(2*NUM_VC_G-1 downto 0);
      txConfigMasters : in  AxiStreamMasterArray(2*NUM_VC_G-1 downto 0);
      txConfigSlaves  : out AxiStreamSlaveArray(2*NUM_VC_G-1 downto 0);
      txDataMasters   : in  AxiStreamMasterArray(2*NUM_VC_G-1 downto 0);
      txDataSlaves    : out AxiStreamSlaveArray(2*NUM_VC_G-1 downto 0);
      -- PGP Ports
      pgpClkP         : in  sl;
      pgpClkN         : in  sl;
      pgpRxP          : in  slv(3 downto 0);
      pgpRxN          : in  slv(3 downto 0);
      pgpTxP          : out slv(3 downto 0);
      pgpTxN          : out slv(3 downto 0));
end Pgp4PhyGthQuad;

architecture mapping of Pgp4PhyGthQuad is

   signal pgpRxIn  : Pgp4RxInArray(3 downto 0)  := (others => PGP4_RX_IN_INIT_C);
   signal pgpRxOut : Pgp4RxOutArray(3 downto 0) := (others => PGP4_RX_OUT_INIT_C);

   signal pgpTxIn  : Pgp4TxInArray(3 downto 0)  := (others => PGP4_TX_IN_INIT_C);
   signal pgpTxOut : Pgp4TxOutArray(3 downto 0) := (others => PGP4_TX_OUT_INIT_C);

   signal pgpTxMasters : AxiStreamMasterArray(4*NUM_VC_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal pgpTxSlaves  : AxiStreamSlaveArray(4*NUM_VC_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal pgpRxMasters : AxiStreamMasterArray(4*NUM_VC_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal pgpRxSlaves  : AxiStreamSlaveArray(4*NUM_VC_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal pgpRxCtrl    : AxiStreamCtrlArray(4*NUM_VC_G-1 downto 0)   := (others => AXI_STREAM_CTRL_UNUSED_C);

   signal pgpClk : slv(3 downto 0);
   signal pgpRst : slv(3 downto 0);

begin

   U_PGPv4 : entity surf.Pgp4GthUsWrapper
      generic map(
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => SIMULATION_G,
         ROGUE_SIM_PORT_NUM_G => 8000,
         NUM_LANES_G          => 4,
         NUM_VC_G             => NUM_VC_G,
         RATE_G               => "6.25Gbps",
         EN_PGP_MON_G         => true,
         EN_GTH_DRP_G         => false,
         EN_QPLL_DRP_G        => false,
         AXIL_BASE_ADDR_G     => AXIL_BASE_ADDR_G,
         AXIL_CLK_FREQ_G      => AXIL_CLK_FREQ_C)
      port map (
         -- Stable Clock and Reset
         stableClk       => axilClk,
         stableRst       => axilRst,
         -- Gt Serial IO
         pgpGtTxP        => pgpTxP,
         pgpGtTxN        => pgpTxN,
         pgpGtRxP        => pgpRxP,
         pgpGtRxN        => pgpRxN,
         -- GT Clocking
         pgpRefClkP      => pgpClkP,
         pgpRefClkN      => pgpClkN,
         -- Clocking
         pgpClk          => pgpClk,
         pgpClkRst       => pgpRst,
         -- Non VC Rx Signals
         pgpRxIn         => pgpRxIn,
         pgpRxOut        => pgpRxOut,
         -- Non VC Tx Signals
         pgpTxIn         => pgpTxIn,
         pgpTxOut        => pgpTxOut,
         -- Frame Transmit Interface
         pgpTxMasters    => pgpTxMasters,
         pgpTxSlaves     => pgpTxSlaves,
         -- Frame Receive Interface
         pgpRxMasters    => pgpRxMasters,
         pgpRxCtrl       => pgpRxCtrl,
         pgpRxSlaves     => pgpRxSlaves,
         -- AXI-Lite Register Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave);

   GEN_LANE :
   for i in 3 downto 0 generate

      GEN_VC :
      for j in (NUM_VC_G/2)-1 downto 0 generate

         U_rxConfig : entity surf.PgpRxVcFifo
            generic map (
               TPD_G               => TPD_G,
               ROGUE_SIM_EN_G      => SIMULATION_G,
               GEN_SYNC_FIFO_G     => false,
               FIFO_ADDR_WIDTH_G   => 9,
               FIFO_PAUSE_THRESH_G => 128,
               PHY_AXI_CONFIG_G    => PGP4_AXIS_CONFIG_C,
               APP_AXI_CONFIG_G    => PGP4_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               pgpClk      => pgpClk(i),
               pgpRst      => pgpRst(i),
               rxlinkReady => pgpRxOut(i).linkReady,
               pgpRxMaster => pgpRxMasters(NUM_VC_G*i+j),
               pgpRxSlave  => pgpRxSlaves(NUM_VC_G*i+j),
               pgpRxCtrl   => pgpRxCtrl(NUM_VC_G*i+j),
               -- Master Port
               axisClk     => axilClk,
               axisRst     => axilRst,
               axisMaster  => rxConfigMasters((NUM_VC_G/2)*i+j),
               axisSlave   => rxConfigSlaves((NUM_VC_G/2)*i+j));

         U_txConfig : entity surf.PgpTxVcFifo
            generic map (
               -- General Configurations
               TPD_G              => TPD_G,
               VALID_THOLD_G      => 256,
               VALID_BURST_MODE_G => true,
               -- FIFO configurations
               GEN_SYNC_FIFO_G    => false,
               FIFO_ADDR_WIDTH_G  => 9,
               -- AXI Stream Port Configurations
               APP_AXI_CONFIG_G   => PGP4_AXIS_CONFIG_C,
               PHY_AXI_CONFIG_G   => PGP4_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               axisClk     => axilClk,
               axisRst     => axilRst,
               axisMaster  => txConfigMasters((NUM_VC_G/2)*i+j),
               axisSlave   => txConfigSlaves((NUM_VC_G/2)*i+j),
               -- Master Port
               pgpClk      => pgpClk(i),
               pgpRst      => pgpRst(i),
               rxlinkReady => pgpRxOut(i).linkReady,
               txlinkReady => pgpTxOut(i).linkReady,
               pgpTxMaster => pgpTxMasters(NUM_VC_G*i+j),
               pgpTxSlave  => pgpTxSlaves(NUM_VC_G*i+j));

         U_txData : entity surf.PgpTxVcFifo
            generic map (
               -- General Configurations
               TPD_G              => TPD_G,
               VALID_THOLD_G      => 256,
               VALID_BURST_MODE_G => true,
               -- FIFO configurations
               GEN_SYNC_FIFO_G    => false,
               FIFO_ADDR_WIDTH_G  => 9,
               -- AXI Stream Port Configurations
               APP_AXI_CONFIG_G   => PGP4_AXIS_CONFIG_C,
               PHY_AXI_CONFIG_G   => PGP4_AXIS_CONFIG_C)
            port map (
               -- Slave Port
               axisClk     => axilClk,
               axisRst     => axilRst,
               axisMaster  => txDataMasters((NUM_VC_G/2)*i+j),
               axisSlave   => txDataSlaves((NUM_VC_G/2)*i+j),
               -- Master Port
               pgpClk      => pgpClk(i),
               pgpRst      => pgpRst(i),
               rxlinkReady => pgpRxOut(i).linkReady,
               txlinkReady => pgpTxOut(i).linkReady,
               pgpTxMaster => pgpTxMasters(NUM_VC_G*i+j+(NUM_VC_G/2)),
               pgpTxSlave  => pgpTxSlaves(NUM_VC_G*i+j+(NUM_VC_G/2)));

      end generate GEN_VC;

   end generate GEN_LANE;

end mapping;
