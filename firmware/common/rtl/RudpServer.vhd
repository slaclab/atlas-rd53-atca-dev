-------------------------------------------------------------------------------
-- File       : RudpServer.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RUDP Server Module
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'Example Project Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.AxiLitePkg.all;
use surf.EthMacPkg.all;

library unisim;
use unisim.vcomponents.all;

entity RudpServer is
   generic (
      TPD_G           : time             := 1 ns;
      CLK_FREQUENCY_G : real             := 156.25E+6;
      IP_ADDR_G       : slv(31 downto 0) := x"0A02A8C0";  -- Set the default IP address before DHCP: 192.168.2.10 = x"0A02A8C0"
      DHCP_G          : boolean          := true;
      JUMBO_G         : boolean          := false);
   port (
      extRst          : in  sl;
      phyReady        : out sl;
      -- AXI-Lite Interface
      axilClk         : out sl;
      axilRst         : out sl;
      axilReadMaster  : out AxiLiteReadMasterType;
      axilReadSlave   : in  AxiLiteReadSlaveType;
      axilWriteMaster : out AxiLiteWriteMasterType;
      axilWriteSlave  : in  AxiLiteWriteSlaveType;
      -- SFP Interface
      sfpClk156P      : in  sl;
      sfpClk156N      : in  sl;
      sfpTxP          : out sl;
      sfpTxN          : out sl;
      sfpRxP          : in  sl;
      sfpRxN          : in  sl);
end RudpServer;

architecture mapping of RudpServer is

   constant AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,               -- 64-bit data interface
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 2,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   constant TIMEOUT_C          : real     := 1.0E-3;  -- In units of seconds
   constant WINDOW_ADDR_SIZE_C : positive := ite(JUMBO_G, 3, 5);
   constant MAX_SEG_SIZE_C     : positive := ite(JUMBO_G, 8192, 1024);  -- Jumbo frame chucking

   constant APP_AXIS_CONFIG_C : AxiStreamConfigArray(0 downto 0) := (others => AXIS_CONFIG_C);

   constant NUM_SERVERS_C  : positive                                := 1;
   constant SERVER_PORTS_C : PositiveArray(NUM_SERVERS_C-1 downto 0) := (0 => 8192);

   signal efuse    : slv(31 downto 0);
   signal localMac : slv(47 downto 0);

   signal ibMacMaster : AxiStreamMasterType;
   signal ibMacSlave  : AxiStreamSlaveType;
   signal obMacMaster : AxiStreamMasterType;
   signal obMacSlave  : AxiStreamSlaveType;

   signal ibServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);
   signal obServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);

   signal appIbMaster : AxiStreamMasterType;
   signal appIbSlave  : AxiStreamSlaveType;
   signal appObMaster : AxiStreamMasterType;
   signal appObSlave  : AxiStreamSlaveType;

   signal dmaClk : sl;
   signal dmaRst : sl;

begin

   axilClk <= dmaClk;
   axilRst <= dmaRst;

   --------------
   -- ETH PHY/MAC
   --------------
   U_1GigE : entity surf.GigEthGthUltraScaleWrapper
      generic map (
         TPD_G              => TPD_G,
         -- DMA/MAC Configurations
         NUM_LANE_G         => 1,
         -- QUAD PLL Configurations
         USE_GTREFCLK_G     => false,
         CLKIN_PERIOD_G     => 6.4,     -- 156.25 MHz
         DIVCLK_DIVIDE_G    => 5,       -- 31.25 MHz = (156.25 MHz/5)
         CLKFBOUT_MULT_F_G  => 32.0,    -- 1 GHz = (32 x 31.25 MHz)
         CLKOUT0_DIVIDE_F_G => 8.0,     -- 125 MHz = (1.0 GHz/8)
         -- AXI Streaming Configurations
         AXIS_CONFIG_G      => (others => EMAC_AXIS_CONFIG_C))
      port map (
         -- Local Configurations
         localMac(0)     => localMac,
         -- Streaming DMA Interface
         dmaClk(0)       => dmaClk,
         dmaRst(0)       => dmaRst,
         dmaIbMasters(0) => obMacMaster,
         dmaIbSlaves(0)  => obMacSlave,
         dmaObMasters(0) => ibMacMaster,
         dmaObSlaves(0)  => ibMacSlave,
         -- Misc. Signals
         extRst          => extRst,
         phyReady(0)     => phyReady,
         -- MGT Clock Port
         gtClkP          => sfpClk156P,
         gtClkN          => sfpClk156N,
         -- Copy of internal MMCM reference clock and Reset
         refClkOut       => dmaClk,
         refRstOut       => dmaRst,
         -- MGT Ports
         gtTxP(0)        => sfpTxP,
         gtTxN(0)        => sfpTxN,
         gtRxP(0)        => sfpRxP,
         gtRxN(0)        => sfpRxN);

   U_EFuse : EFUSE_USR
      port map (
         EFUSEUSR => efuse);

   localMac(23 downto 0)  <= x"56_00_08";  -- 08:00:56:XX:XX:XX (big endian SLV)
   localMac(47 downto 24) <= efuse(31 downto 8);

   ----------------------
   -- IPv4/ARP/UDP Engine
   ----------------------
   U_UDP : entity surf.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => NUM_SERVERS_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Client Generics
         CLIENT_EN_G    => false,
         -- General IPv4/ARP/DHCP Generics
         DHCP_G         => DHCP_G,
         CLK_FREQ_G     => CLK_FREQUENCY_G,
         COMM_TIMEOUT_G => 30)
      port map (
         -- Local Configurations
         localMac        => localMac,
         localIp         => IP_ADDR_G,
         -- Interface to Ethernet Media Access Controller (MAC)
         obMacMaster     => obMacMaster,
         obMacSlave      => obMacSlave,
         ibMacMaster     => ibMacMaster,
         ibMacSlave      => ibMacSlave,
         -- Interface to UDP Server engine(s)
         obServerMasters => obServerMasters,
         obServerSlaves  => obServerSlaves,
         ibServerMasters => ibServerMasters,
         ibServerSlaves  => ibServerSlaves,
         -- Clock and Reset
         clk             => dmaClk,
         rst             => dmaRst);

   --------------
   -- RSSI Server
   --------------
   U_RssiServer : entity surf.RssiCoreWrapper
      generic map (
         TPD_G               => TPD_G,
         SERVER_G            => true,
         CLK_FREQUENCY_G     => CLK_FREQUENCY_G,
         TIMEOUT_UNIT_G      => TIMEOUT_C,
         APP_ILEAVE_EN_G     => true,   -- true = AxiStreamPacketizer2
         APP_STREAMS_G       => 1,
         SEGMENT_ADDR_SIZE_G => bitSize(MAX_SEG_SIZE_C/8),
         WINDOW_ADDR_SIZE_G  => WINDOW_ADDR_SIZE_C,
         -- AXIS Configurations
         APP_AXIS_CONFIG_G   => APP_AXIS_CONFIG_C,
         TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
         -- Window parameters of receiver module
         MAX_NUM_OUTS_SEG_G  => (2**WINDOW_ADDR_SIZE_C),
         MAX_SEG_SIZE_G      => MAX_SEG_SIZE_C,
         -- Counters
         MAX_RETRANS_CNT_G   => (2**WINDOW_ADDR_SIZE_C),
         MAX_CUM_ACK_CNT_G   => WINDOW_ADDR_SIZE_C)
      port map (
         clk_i                => dmaClk,
         rst_i                => dmaRst,
         openRq_i             => '1',
         -- Application Layer Interface
         sAppAxisMasters_i(0) => appObMaster,
         sAppAxisSlaves_o(0)  => appObSlave,
         mAppAxisMasters_o(0) => appIbMaster,
         mAppAxisSlaves_i(0)  => appIbSlave,
         -- Transport Layer Interface
         sTspAxisMaster_i     => obServerMasters(0),
         sTspAxisSlave_o      => obServerSlaves(0),
         mTspAxisMaster_o     => ibServerMasters(0),
         mTspAxisSlave_i      => ibServerSlaves(0));

   ---------------
   -- SRPv3 Module
   ---------------
   U_SRPv3 : entity surf.SrpV3AxiLite
      generic map (
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         GEN_SYNC_FIFO_G     => true,
         AXI_STREAM_CONFIG_G => AXIS_CONFIG_C)
      port map (
         -- Streaming Slave (Rx) Interface (sAxisClk domain)
         sAxisClk         => dmaClk,
         sAxisRst         => dmaRst,
         sAxisMaster      => appIbMaster,
         sAxisSlave       => appIbSlave,
         -- Streaming Master (Tx) Data Interface (mAxisClk domain)
         mAxisClk         => dmaClk,
         mAxisRst         => dmaRst,
         mAxisMaster      => appObMaster,
         mAxisSlave       => appObSlave,
         -- Master AXI-Lite Interface (axilClk domain)
         axilClk          => dmaClk,
         axilRst          => dmaRst,
         mAxilReadMaster  => axilReadMaster,
         mAxilReadSlave   => axilReadSlave,
         mAxilWriteMaster => axilWriteMaster,
         mAxilWriteSlave  => axilWriteSlave);

end mapping;
