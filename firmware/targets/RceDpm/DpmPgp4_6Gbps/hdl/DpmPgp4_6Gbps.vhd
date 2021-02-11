-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: DPM PGPv4 6.25Gbps DPM: Top Level Firmware
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity DpmPgp4_6Gbps is
   generic (
      TPD_G        : time := 1 ns;
      BUILD_INFO_G : BuildInfoType);
   port (
      -- Debug
      led         : out   slv(1 downto 0);
      -- I2C
      i2cSda      : inout sl;
      i2cScl      : inout sl;
      -- Ethernet
      ethRxP      : in    slv(3 downto 0);
      ethRxM      : in    slv(3 downto 0);
      ethTxP      : out   slv(3 downto 0);
      ethTxM      : out   slv(3 downto 0);
      ethRefClkP  : in    sl;
      ethRefClkM  : in    sl;
      -- RTM High Speed
      dpmToRtmHsP : out   slv(11 downto 0);
      dpmToRtmHsM : out   slv(11 downto 0);
      rtmToDpmHsP : in    slv(11 downto 0);
      rtmToDpmHsM : in    slv(11 downto 0);
      -- Reference Clocks
      locRefClkP  : in    sl;
      locRefClkM  : in    sl;
      dtmRefClkP  : in    sl;
      dtmRefClkM  : in    sl;
      -- DTM Signals
      dtmClkP     : in    slv(1 downto 0);
      dtmClkM     : in    slv(1 downto 0);
      dtmFbP      : out   sl;
      dtmFbM      : out   sl;
      -- Clock Select
      clkSelA     : out   slv(1 downto 0);
      clkSelB     : out   slv(1 downto 0));
end DpmPgp4_6Gbps;

architecture TOP_LEVEL of DpmPgp4_6Gbps is

   constant NUM_AXIL_MASTERS_C : natural := 2;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"A000_0000", 28, 24);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaClks      : slv(2 downto 0);
   signal dmaRsts      : slv(2 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(2 downto 0);
   signal dmaObMasters : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(2 downto 0);

   signal pgpRefClkIn : sl;

begin

   led <= "00";

   --------------------------------------------------
   -- PS + DMA + ETH MAC
   --------------------------------------------------
   U_DpmCore : entity rce_gen3_fw_lib.DpmCore
      generic map (
         TPD_G          => TPD_G,
         RCE_DMA_MODE_G => RCE_DMA_AXISV2_C,  -- AXIS DMA Version2 (required for interleaving support)
         BUILD_INFO_G   => BUILD_INFO_G,
         ETH_TYPE_G     => "ZYNQ-GEM")
      port map (
         -- IPMI I2C Ports
         i2cSda             => i2cSda,
         i2cScl             => i2cScl,
         -- Clock Select
         clkSelA            => clkSelA,
         clkSelB            => clkSelB,
         -- Ethernet Ports
         ethRxP             => ethRxP,
         ethRxM             => ethRxM,
         ethTxP             => ethTxP,
         ethTxM             => ethTxM,
         ethRefClkP         => ethRefClkP,
         ethRefClkM         => ethRefClkM,
         -- Clocks and Resets
         sysClk200          => dmaClk,
         sysClk200Rst       => dmaRst,
         -- AXI-Lite Register Interface [0xA0000000:0xAFFFFFFF]
         axiClk             => axilClk,
         axiClkRst          => axilRst,
         extAxilReadMaster  => axilReadMaster,
         extAxilReadSlave   => axilReadSlave,
         extAxilWriteMaster => axilWriteMaster,
         extAxilWriteSlave  => axilWriteSlave,
         -- AXI Stream DMA Interfaces
         dmaClk             => dmaClks,
         dmaClkRst          => dmaRsts,
         dmaObMaster        => dmaObMasters,
         dmaObSlave         => dmaObSlaves,
         dmaIbMaster        => dmaIbMasters,
         dmaIbSlave         => dmaIbSlaves);

   dmaClks <= (others => dmaClk);
   dmaRsts <= (others => dmaRst);

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_XBAR_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   ------------
   -- PGPv4 GTX
   ------------
   GEN_LANE : for i in 1 downto 0 generate

      ----------------------------------------------
      -- Note: SFP RTM uses lane[0] and lane[6] Only
      ----------------------------------------------
      U_Pgp : entity work.PgpLaneWrapper
         generic map (
            TPD_G             => TPD_G,
            NUM_VC_G          => 16,
            DMA_AXIS_CONFIG_G => RCEG3_AXIS_DMA_CONFIG_C,
            RATE_G            => "6.25Gbps",
            AXIL_BASE_ADDR_G  => AXIL_XBAR_CONFIG_C(i).baseAddr,
            AXIL_CLK_FREQ_G   => 125.0E+6)
         port map (
            -- RTM High Speed
            pgpRefClkIn     => pgpRefClkIn,
            pgpGtTxP        => dpmToRtmHsP(6*i),
            pgpGtTxN        => dpmToRtmHsM(6*i),
            pgpGtRxP        => rtmToDpmHsP(6*i),
            pgpGtRxN        => rtmToDpmHsM(6*i),
            -- DMA Interface (dmaClk domain)
            dmaClk          => dmaClk,
            dmaRst          => dmaRst,
            dmaObMaster     => dmaObMasters(i),
            dmaObSlave      => dmaObSlaves(i),
            dmaIbMaster     => dmaIbMasters(i),
            dmaIbSlave      => dmaIbSlaves(i),
            -- AXI-Lite Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(i),
            axilReadSlave   => axilReadSlaves(i),
            axilWriteMaster => axilWriteMasters(i),
            axilWriteSlave  => axilWriteSlaves(i));

      U_TERM : entity surf.Gtxe2ChannelDummy
         generic map (
            TPD_G   => TPD_G,
            WIDTH_G => 5)
         port map (
            refClk => axilClk,
            gtRxP  => rtmToDpmHsP(6*i+5 downto 6*i+1),
            gtRxN  => rtmToDpmHsM(6*i+5 downto 6*i+1),
            gtTxP  => dpmToRtmHsP(6*i+5 downto 6*i+1),
            gtTxN  => dpmToRtmHsM(6*i+5 downto 6*i+1));

   end generate;

   -- Loopback DMA CH[2]
   dmaIbMasters(2) <= dmaObMasters(2);
   dmaObSlaves(2)  <= dmaIbSlaves(2);

   ------------
   -- DTM Clock
   ------------
   U_pgpRefClk : IBUFDS_GTE2
      port map (
         I     => locRefClkP,
         IB    => locRefClkM,
         CEB   => '0',
         ODIV2 => open,
         O     => pgpRefClkIn);

   ------------
   -- DTM Clock
   ------------
   U_DtmClkgen : for i in 1 downto 0 generate
      U_DtmClkIn : IBUFDS
         port map(
            I  => dtmClkP(i),
            IB => dtmClkM(i),
            O  => open);
   end generate;

   ---------------
   -- DTM Feedback
   ---------------
   U_DtmFbOut : OBUFDS
      port map(
         O  => dtmFbP,
         OB => dtmFbM,
         I  => '0');

end TOP_LEVEL;
