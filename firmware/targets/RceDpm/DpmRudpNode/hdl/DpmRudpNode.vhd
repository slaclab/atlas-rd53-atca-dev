-------------------------------------------------------------------------------
-- File       : DpmRudpNode.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RUDP DPM: Top Level Firmware
-- 
-- Refer to atlas-rd53-atca-dev/firmware/targets/RceDpm/DpmRudpNode/README.md 
-- for how to setup the RCE and how to establish the RUDP connections
-- 
-------------------------------------------------------------------------------
-- This file is part of 'RCE Development Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'RCE Development Firmware', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.EthMacPkg.all;

library rce_gen3_fw_lib;
use rce_gen3_fw_lib.RceG3Pkg.all;

library unisim;
use unisim.vcomponents.all;

entity DpmRudpNode is
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
end DpmRudpNode;

architecture TOP_LEVEL of DpmRudpNode is

   constant SERVER_SIZE_C : positive := 1;
   constant SERVER_PORTS_C : PositiveArray(SERVER_SIZE_C-1 downto 0) := (
      0 => 8192);

   constant CLIENT_SIZE_C : positive := 1;
   constant CLIENT_PORTS_C : PositiveArray(CLIENT_SIZE_C-1 downto 0) := (
      0 => 9000);

   constant UDP_SIZE_C : positive := SERVER_SIZE_C+CLIENT_SIZE_C;
   constant UDP_PORTS_C : PositiveArray(UDP_SIZE_C-1 downto 0) := (
      0 => SERVER_PORTS_C(0),
      1 => CLIENT_PORTS_C(0));

   constant APP_AXIS_CONFIG_C : AxiStreamConfigArray(0 downto 0) := (others => RCEG3_AXIS_DMA_CONFIG_C);

   constant AXIL_CLK_FREQ_C    : real     := 156.25E+6;  -- In units of Hz   
   constant TIMEOUT_C          : real     := 1.0E-3;  -- In units of seconds   
   constant WINDOW_ADDR_SIZE_C : positive := 6;
   constant MAX_SEG_SIZE_C     : positive := 1024;

   constant NUM_AXIL_MASTERS_C : natural := 3;

   constant UDP_INDEX_C : natural := 0;
   constant SRV_INDEX_C : natural := 1;
   constant CLT_INDEX_C : natural := 2;

   constant AXIL_XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, x"A0000000", 20, 16);

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

   signal coreClk         : sl;
   signal coreRst         : sl;
   signal coreReadMaster  : AxiLiteReadMasterType;
   signal coreReadSlave   : AxiLiteReadSlaveType;
   signal coreWriteMaster : AxiLiteWriteMasterType;
   signal coreWriteSlave  : AxiLiteWriteSlaveType;

   signal dmaClk       : slv(2 downto 0);
   signal dmaRst       : slv(2 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(2 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(2 downto 0);
   signal dmaObMasters : AxiStreamMasterArray(2 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(2 downto 0);

   signal localMac : slv(47 downto 0);
   signal localIp  : slv(31 downto 0);

   signal ibMacMaster : AxiStreamMasterType;
   signal ibMacSlave  : AxiStreamSlaveType;
   signal obMacMaster : AxiStreamMasterType;
   signal obMacSlave  : AxiStreamSlaveType;

   signal obServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0);
   signal ibServerMasters : AxiStreamMasterArray(SERVER_SIZE_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(SERVER_SIZE_C-1 downto 0);

   signal obClientMasters : AxiStreamMasterArray(CLIENT_SIZE_C-1 downto 0);
   signal obClientSlaves  : AxiStreamSlaveArray(CLIENT_SIZE_C-1 downto 0);
   signal ibClientMasters : AxiStreamMasterArray(CLIENT_SIZE_C-1 downto 0);
   signal ibClientSlaves  : AxiStreamSlaveArray(CLIENT_SIZE_C-1 downto 0);

begin

   led <= "00";

   --------------------------------------------------
   -- PS + DMA + ETH MAC
   --------------------------------------------------
   U_DpmCore : entity rce_gen3_fw_lib.DpmCore
      generic map (
         TPD_G              => TPD_G,
         RCE_DMA_MODE_G     => RCE_DMA_AXISV2_C,  -- AXIS DMA Version2
         BUILD_INFO_G       => BUILD_INFO_G,
         ----------------------------------------------------------
         -- ETH_TYPE_G         => "1000BASE-KX", -- 1GbE w/ 1 lane (supported for all COB versions)
         ETH_TYPE_G         => "10GBASE-KX4",  -- 10GbE w/ 4 lane (Only support for COB C09 (or older) )
         -- ETH_TYPE_G         => "10GBASE-KR", -- 10GbE w/ 1 lane (Only support for COB C10 (or newer) )
         ----------------------------------------------------------
         UDP_SERVER_EN_G    => true,
         UDP_SERVER_SIZE_G  => UDP_SIZE_C,
         UDP_SERVER_PORTS_G => UDP_PORTS_C)
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
         -- AXI-Lite Register Interface [0xA0000000:0xAFFFFFFF]
         axiClk             => coreClk,
         axiClkRst          => coreRst,
         extAxilReadMaster  => coreReadMaster,
         extAxilReadSlave   => coreReadSlave,
         extAxilWriteMaster => coreWriteMaster,
         extAxilWriteSlave  => coreWriteSlave,
         -- AXI Stream DMA Interfaces
         dmaClk             => dmaClk,
         dmaClkRst          => dmaRst,
         dmaObMaster        => dmaObMasters,
         dmaObSlave         => dmaObSlaves,
         dmaIbMaster        => dmaIbMasters,
         dmaIbSlave         => dmaIbSlaves,
         -- User ETH interface (userEthClk domain)
         userEthClk         => axilClk,
         userEthClkRst      => axilRst,
         userEthIpAddr      => localIp,
         userEthMacAddr     => localMac,
         userEthUdpIbMaster => ibMacMaster,
         userEthUdpIbSlave  => ibMacSlave,
         userEthUdpObMaster => obMacMaster,
         userEthUdpObSlave  => obMacSlave);

   dmaClk <= (others => axilClk);
   dmaRst <= (others => axilRst);

   --------------------
   -- DMA[2] = Loopback
   --------------------
   dmaIbMasters(2) <= dmaObMasters(2);
   dmaObSlaves(2)  <= dmaIbSlaves(2);

   ----------------------------------------         
   -- Move AXI-Lite to another clock domain
   ----------------------------------------         
   U_AxiLiteAsync : entity surf.AxiLiteAsync
      generic map (
         TPD_G           => TPD_G,
         COMMON_CLK_G    => false,
         NUM_ADDR_BITS_G => 32)
      port map (
         -- Slave Interface
         sAxiClk         => coreClk,
         sAxiClkRst      => coreRst,
         sAxiReadMaster  => coreReadMaster,
         sAxiReadSlave   => coreReadSlave,
         sAxiWriteMaster => coreWriteMaster,
         sAxiWriteSlave  => coreWriteSlave,
         -- Master Interface
         mAxiClk         => axilClk,
         mAxiClkRst      => axilRst,
         mAxiReadMaster  => axilReadMaster,
         mAxiReadSlave   => axilReadSlave,
         mAxiWriteMaster => axilWriteMaster,
         mAxiWriteSlave  => axilWriteSlave);

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

   -----------
   -- IPv4/UDP
   -----------
   U_UDP : entity surf.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => SERVER_SIZE_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Server Generics
         CLIENT_EN_G    => true,
         CLIENT_SIZE_G  => CLIENT_SIZE_C,
         CLIENT_PORTS_G => CLIENT_PORTS_C)
      port map (
         -- Local Configurations
         localMac        => localMac,
         localIp         => localIp,
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
         -- Interface to UDP Client engine(s)
         obClientMasters => obClientMasters,
         obClientSlaves  => obClientSlaves,
         ibClientMasters => ibClientMasters,
         ibClientSlaves  => ibClientSlaves,
         -- AXI-Lite Interface
         axilReadMaster  => axilReadMasters(UDP_INDEX_C),
         axilReadSlave   => axilReadSlaves(UDP_INDEX_C),
         axilWriteMaster => axilWriteMasters(UDP_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(UDP_INDEX_C),
         -- Clock and Reset
         clk             => axilClk,
         rst             => axilRst);

   -----------------------
   -- DMA[1] = RUDP Server
   -----------------------
   U_RssiServer : entity surf.RssiCoreWrapper
      generic map (
         TPD_G               => TPD_G,
         SERVER_G            => true,
         CLK_FREQUENCY_G     => AXIL_CLK_FREQ_C,
         TIMEOUT_UNIT_G      => TIMEOUT_C,
         APP_ILEAVE_EN_G     => true,   -- true = AxiStreamPacketizer2
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
         clk_i                => axilClk,
         rst_i                => axilRst,
         -- Application Layer Interface
         sAppAxisMasters_i(0) => dmaObMasters(1),
         sAppAxisSlaves_o(0)  => dmaObSlaves(1),
         mAppAxisMasters_o(0) => dmaIbMasters(1),
         mAppAxisSlaves_i(0)  => dmaIbSlaves(1),
         -- Transport Layer Interface
         sTspAxisMaster_i     => obServerMasters(0),
         sTspAxisSlave_o      => obServerSlaves(0),
         mTspAxisMaster_o     => ibServerMasters(0),
         mTspAxisSlave_i      => ibServerSlaves(0),
         -- High level  Application side interface
         openRq_i             => '1',  -- Automatically start the connection without SW
         closeRq_i            => '0',
         inject_i             => '0',
         -- AXI-Lite Interface
         axiClk_i             => axilClk,
         axiRst_i             => axilRst,
         axilReadMaster       => axilReadMasters(SRV_INDEX_C),
         axilReadSlave        => axilReadSlaves(SRV_INDEX_C),
         axilWriteMaster      => axilWriteMasters(SRV_INDEX_C),
         axilWriteSlave       => axilWriteSlaves(SRV_INDEX_C));

   -----------------------
   -- DMA[0] = RUDP Client
   -----------------------
   U_RssiClient : entity surf.RssiCoreWrapper
      generic map (
         TPD_G               => TPD_G,
         SERVER_G            => false,  -- false = Client mode
         CLK_FREQUENCY_G     => AXIL_CLK_FREQ_C,
         TIMEOUT_UNIT_G      => TIMEOUT_C,
         APP_ILEAVE_EN_G     => true,   -- true = AxiStreamPacketizer2
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
         clk_i                => axilClk,
         rst_i                => axilRst,
         -- Application Layer Interface
         sAppAxisMasters_i(0) => dmaObMasters(0),
         sAppAxisSlaves_o(0)  => dmaObSlaves(0),
         mAppAxisMasters_o(0) => dmaIbMasters(0),
         mAppAxisSlaves_i(0)  => dmaIbSlaves(0),
         -- Transport Layer Interface
         sTspAxisMaster_i     => obClientMasters(0),
         sTspAxisSlave_o      => obClientSlaves(0),
         mTspAxisMaster_o     => ibClientMasters(0),
         mTspAxisSlave_i      => ibClientSlaves(0),
         -- High level  Application side interface
         openRq_i             => '1',  -- Automatically start the connection without SW
         closeRq_i            => '0',
         inject_i             => '0',
         -- AXI-Lite Interface
         axiClk_i             => axilClk,
         axiRst_i             => axilRst,
         axilReadMaster       => axilReadMasters(CLT_INDEX_C),
         axilReadSlave        => axilReadSlaves(CLT_INDEX_C),
         axilWriteMaster      => axilWriteMasters(CLT_INDEX_C),
         axilWriteSlave       => axilWriteSlaves(CLT_INDEX_C));

   ----------
   -- RTM GTs
   ----------
   U_TERM_GTs : entity surf.Gtxe2ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 12)
      port map (
         refClk => axilClk,
         gtRxP  => rtmToDpmHsP,
         gtRxN  => rtmToDpmHsM,
         gtTxP  => dpmToRtmHsP,
         gtTxN  => dpmToRtmHsM);

   ------------
   -- DTM Clock
   ------------
   U_DtmClkgen : for i in 1 downto 0 generate
      U_DtmClkIn : IBUFDS
         generic map (DIFF_TERM => true)
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
