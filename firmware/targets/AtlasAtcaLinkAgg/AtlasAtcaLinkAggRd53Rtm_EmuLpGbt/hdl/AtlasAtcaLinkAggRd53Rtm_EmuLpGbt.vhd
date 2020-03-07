-------------------------------------------------------------------------------
-- File       : AtlasAtcaLinkAggRd53Rtm_EmuLpGbt.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top Level Firmware for reading out RD53 on 24 mDP via RTM
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS ATCA LINK AGG DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS ATCA LINK AGG DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasAtcaLinkAggRd53Rtm_EmuLpGbt is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      BUILD_INFO_G : BuildInfoType);
   port (
      --------------------- 
      --  Application Ports
      --------------------- 
      -- Jitter Cleaner PLL Ports
      fpgaToPllClkP  : out   sl;
      fpgaToPllClkN  : out   sl;
      pllToFpgaClkP  : in    sl;
      pllToFpgaClkN  : in    sl;
      -- Front Panel Clock/LED/TTL Ports
      smaClkP        : in    sl;
      smaClkN        : in    sl;
      ledRedL        : out   slv(1 downto 0) := "11";
      ledBlueL       : out   slv(1 downto 0) := "11";
      ledGreenL      : out   slv(1 downto 0) := "11";
      fpTrigInL      : in    sl;
      fpBusyOut      : out   sl              := '0';
      fpSpareOut     : out   sl              := '0';
      fpSpareInL     : in    sl;
      -- Backplane Clocks Ports
      bpClkIn        : in    slv(5 downto 0);
      bpClkOut       : out   slv(5 downto 0) := (others => '0');
      -- Front Panel QSFP+ Ports
      qsfpEthRefClkP : in    sl;
      qsfpEthRefClkN : in    sl;
      qsfpRef160ClkP : in    sl;
      qsfpRef160ClkN : in    sl;
      qsfpPllClkP    : in    sl;
      qsfpPllClkN    : in    sl;
      qsfpTxP        : out   Slv4Array(1 downto 0);
      qsfpTxN        : out   Slv4Array(1 downto 0);
      qsfpRxP        : in    Slv4Array(1 downto 0);
      qsfpRxN        : in    Slv4Array(1 downto 0);
      -- Front Panel SFP+ Ports
      sfpEthRefClkP  : in    sl;
      sfpEthRefClkN  : in    sl;
      sfpRef160ClkP  : in    sl;
      sfpRef160ClkN  : in    sl;
      sfpPllClkP     : in    sl;
      sfpPllClkN     : in    sl;
      sfpTxP         : out   slv(3 downto 0);
      sfpTxN         : out   slv(3 downto 0);
      sfpRxP         : in    slv(3 downto 0);
      sfpRxN         : in    slv(3 downto 0);
      -- RTM Ports
      rtmIo          : inout Slv8Array(3 downto 0);
      dpmToRtmP      : inout Slv16Array(3 downto 0);
      dpmToRtmN      : inout Slv16Array(3 downto 0);
      rtmToDpmP      : inout Slv16Array(3 downto 0);
      rtmToDpmN      : inout Slv16Array(3 downto 0);
      -------------------   
      --  Top Level Ports
      -------------------   
      -- Jitter Cleaner PLL Ports
      pllSpiCsL      : out   sl;
      pllSpiSclk     : out   sl;
      pllSpiSdi      : out   sl;
      pllSpiSdo      : in    sl;
      pllSpiRstL     : out   sl;
      pllSpiOeL      : out   sl;
      pllIntrL       : in    sl;
      pllLolL        : in    sl;
      pllClkScl      : inout sl;
      pllClkSda      : inout sl;
      -- Front Panel I2C Ports
      fpScl          : inout sl;
      fpSda          : inout sl;
      sfpScl         : inout slv(3 downto 0);
      sfpSda         : inout slv(3 downto 0);
      qsfpScl        : inout slv(1 downto 0);
      qsfpSda        : inout slv(1 downto 0);
      -- Front Panel: ETH[1:0] SGMII Ports
      sgmiiClkP      : in    sl;
      sgmiiClkN      : in    sl;
      sgmiiRxP       : in    slv(1 downto 0);
      sgmiiRxN       : in    slv(1 downto 0);
      sgmiiTxP       : out   slv(1 downto 0);
      sgmiiTxN       : out   slv(1 downto 0);
      -- ATCA Backplane: FABRIC ETH[1:4]
      fabEthRefClkP  : in    sl;
      fabEthRefClkN  : in    sl;
      fabEthTxP      : out   Slv4Array(4 downto 1);
      fabEthTxN      : out   Slv4Array(4 downto 1);
      fabEthRxP      : in    Slv4Array(4 downto 1);
      fabEthRxN      : in    Slv4Array(4 downto 1);
      -- IMPC Ports
      ipmcScl        : inout sl;
      ipmcSda        : inout sl;
      -- SYSMON Ports
      vPIn           : in    sl;
      vNIn           : in    sl);
end AtlasAtcaLinkAggRd53Rtm_EmuLpGbt;

architecture top_level of AtlasAtcaLinkAggRd53Rtm_EmuLpGbt is

   constant ETH_CONFIG_C : EthConfigArray := (
      -----------------------------------------------------------------------------------
      ETH_FAB1_IDX_C => (               -- Using slot#1 COB for data processing
         enable      => true,
         enDhcp      => true,
         enXvc       => false,
         enSrp       => false,          -- No SRPv3 channel access
         fabConfig   => ETH_10G_4LANE,  -- Using 10GbE XAUI
         -- Streaming Data Server Configurations
         numSrvData  => 1,  -- Moving all the data to one RSSI client on one RCE element
         enSrvDataTx => true,
         enSrvDataRx => true,
         -- Streaming Data Client Configurations
         numCltData  => 0,              -- Client disabled
         enCltDataTx => false,
         enCltDataRx => false),
      -----------------------------------------------------------------------------------
      ETH_FAB2_IDX_C => ETH_PORT_DISABLED_C,  -- Disabling slot#2 communication
      ETH_FAB3_IDX_C => ETH_PORT_DISABLED_C,  -- Disabling slot#3 communication
      ETH_FAB4_IDX_C => ETH_PORT_DISABLED_C,  -- Disabling slot#4 communication
      -----------------------------------------------------------------------------------
      ETH_FP0_IDX_C  => ETH_PORT_SRP_ONLY_C,  -- Using Front Panel SFP for SRPv3 configuration only
      ETH_FP1_IDX_C  => ETH_PORT_SRP_ONLY_C);  -- Using Front Panel SFP for SRPv3 configuration only

   signal axilClk         : sl;
   signal axilRst         : sl;
   signal axilReadMaster  : AxiLiteReadMasterType;
   signal axilReadSlave   : AxiLiteReadSlaveType;
   signal axilWriteMaster : AxiLiteWriteMasterType;
   signal axilWriteSlave  : AxiLiteWriteSlaveType;

   signal srvIbMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal srvIbSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);
   signal srvObMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal srvObSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);

   signal cltIbMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal cltIbSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);
   signal cltObMasters : AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0);
   signal cltObSlaves  : AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0);

   signal ref156Clk : sl;
   signal ref156Rst : sl;
   signal ipmiBsi   : BsiBusType;

   signal dPortDataP : Slv4Array(23 downto 0);
   signal dPortDataN : Slv4Array(23 downto 0);
   signal dPortCmdP  : slv(23 downto 0);
   signal dPortCmdN  : slv(23 downto 0);

   signal i2cScl : slv(3 downto 0);
   signal i2cSda : slv(3 downto 0);

begin

   U_RTM_Mapping : entity work.AtlasAtcaLinkAggRd53RtmMapping
      generic map (
         TPD_G => TPD_G)
      port map (
         -- mDP DATA/CMD Interface
         dPortDataP => dPortDataP,
         dPortDataN => dPortDataN,
         dPortCmdP  => dPortCmdP,
         dPortCmdN  => dPortCmdN,
         -- I2C Interface
         i2cScl     => i2cScl,
         i2cSda     => i2cSda,
         -- RTM Ports
         rtmIo      => rtmIo,
         dpmToRtmP  => dpmToRtmP,
         dpmToRtmN  => dpmToRtmN,
         rtmToDpmP  => rtmToDpmP,
         rtmToDpmN  => rtmToDpmN);

   U_App : entity work.Application
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G)
      port map (
         -----------------------------
         --  Interfaces to Application
         -----------------------------
         -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- Server Streaming Interface (axilClk domain)
         srvIbMasters    => srvIbMasters,
         srvIbSlaves     => srvIbSlaves,
         srvObMasters    => srvObMasters,
         srvObSlaves     => srvObSlaves,
         -- Client Streaming Interface (axilClk domain)
         cltIbMasters    => cltIbMasters,
         cltIbSlaves     => cltIbSlaves,
         cltObMasters    => cltObMasters,
         cltObSlaves     => cltObSlaves,
         -- Misc. Interface 
         ref156Clk       => ref156Clk,
         ref156Rst       => ref156Rst,
         ipmiBsi         => ipmiBsi,
         -- mDP DATA/CMD Interface
         dPortDataP      => dPortDataP,
         dPortDataN      => dPortDataN,
         dPortCmdP       => dPortCmdP,
         dPortCmdN       => dPortCmdN,
         -- I2C Interface
         i2cScl          => i2cScl,
         i2cSda          => i2cSda,
         --------------------- 
         --  Application Ports
         --------------------- 
         -- Jitter Cleaner PLL Ports
         fpgaToPllClkP   => fpgaToPllClkP,
         fpgaToPllClkN   => fpgaToPllClkN,
         pllToFpgaClkP   => pllToFpgaClkP,
         pllToFpgaClkN   => pllToFpgaClkN,
         -- Front Panel Clock/LED/TTL Ports
         smaClkP         => smaClkP,
         smaClkN         => smaClkN,
         ledRedL         => ledRedL,
         ledBlueL        => ledBlueL,
         ledGreenL       => ledGreenL,
         fpTrigInL       => fpTrigInL,
         fpBusyOut       => fpBusyOut,
         fpSpareOut      => fpSpareOut,
         fpSpareInL      => fpSpareInL,
         -- Backplane Clocks Ports
         bpClkIn         => bpClkIn,
         bpClkOut        => bpClkOut,
         -- Front Panel QSFP+ Ports
         qsfpEthRefClkP  => qsfpEthRefClkP,
         qsfpEthRefClkN  => qsfpEthRefClkN,
         qsfpRef160ClkP  => qsfpRef160ClkP,
         qsfpRef160ClkN  => qsfpRef160ClkN,
         qsfpPllClkP     => qsfpPllClkP,
         qsfpPllClkN     => qsfpPllClkN,
         qsfpTxP         => qsfpTxP,
         qsfpTxN         => qsfpTxN,
         qsfpRxP         => qsfpRxP,
         qsfpRxN         => qsfpRxN,
         -- Front Panel SFP+ Ports
         sfpEthRefClkP   => sfpEthRefClkP,
         sfpEthRefClkN   => sfpEthRefClkN,
         sfpRef160ClkP   => sfpRef160ClkP,
         sfpRef160ClkN   => sfpRef160ClkN,
         sfpPllClkP      => sfpPllClkP,
         sfpPllClkN      => sfpPllClkN,
         sfpTxP          => sfpTxP,
         sfpTxN          => sfpTxN,
         sfpRxP          => sfpRxP,
         sfpRxN          => sfpRxN);

   U_Core : entity atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggCore
      generic map (
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         BUILD_INFO_G       => BUILD_INFO_G,
         MEMORY_INIT_FILE_G => "AtlasAtcaLinkAggRd53Rtm_EmuLpGbt.mem",
         ETH_CONFIG_G       => ETH_CONFIG_C)
      port map (
         -----------------------------
         --  Interfaces to Application
         -----------------------------
         -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave,
         -- Server Streaming Interface (axilClk domain)
         srvIbMasters    => srvIbMasters,
         srvIbSlaves     => srvIbSlaves,
         srvObMasters    => srvObMasters,
         srvObSlaves     => srvObSlaves,
         -- Client Streaming Interface (axilClk domain)
         cltIbMasters    => cltIbMasters,
         cltIbSlaves     => cltIbSlaves,
         cltObMasters    => cltObMasters,
         cltObSlaves     => cltObSlaves,
         -- Misc. Interface 
         ref156Clk       => ref156Clk,
         ref156Rst       => ref156Rst,
         ipmiBsi         => ipmiBsi,
         -------------------   
         --  Top Level Ports
         -------------------   
         -- Jitter Cleaner PLL Ports
         pllSpiCsL       => pllSpiCsL,
         pllSpiSclk      => pllSpiSclk,
         pllSpiSdi       => pllSpiSdi,
         pllSpiSdo       => pllSpiSdo,
         pllSpiRstL      => pllSpiRstL,
         pllSpiOeL       => pllSpiOeL,
         pllIntrL        => pllIntrL,
         pllLolL         => pllLolL,
         pllClkScl       => pllClkScl,
         pllClkSda       => pllClkSda,
         -- Front Panel I2C Ports
         fpScl           => fpScl,
         fpSda           => fpSda,
         sfpScl          => sfpScl,
         sfpSda          => sfpSda,
         qsfpScl         => qsfpScl,
         qsfpSda         => qsfpSda,
         -- Front Panel: ETH[1:0] SGMII Ports
         sgmiiClkP       => sgmiiClkP,
         sgmiiClkN       => sgmiiClkN,
         sgmiiTxP        => sgmiiTxP,
         sgmiiTxN        => sgmiiTxN,
         sgmiiRxP        => sgmiiRxP,
         sgmiiRxN        => sgmiiRxN,
         -- ATCA Backplane: FABRIC ETH[1:4]
         fabEthRefClkP   => fabEthRefClkP,
         fabEthRefClkN   => fabEthRefClkN,
         fabEthTxP       => fabEthTxP,
         fabEthTxN       => fabEthTxN,
         fabEthRxP       => fabEthRxP,
         fabEthRxN       => fabEthRxN,
         -- IMPC Ports
         ipmcScl         => ipmcScl,
         ipmcSda         => ipmcSda,
         -- SYSMON Ports
         vPIn            => vPIn,
         vNIn            => vNIn);

end top_level;
