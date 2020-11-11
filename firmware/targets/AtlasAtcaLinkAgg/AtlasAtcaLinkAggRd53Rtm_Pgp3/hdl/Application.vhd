-------------------------------------------------------------------------------
-- File       : Application.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Top-Level Application Wrapper
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.I2cPkg.all;
use surf.Pgp3Pkg.all;

library atlas_rd53_fw_lib;

library atlas_atca_link_agg_fw_lib;
use atlas_atca_link_agg_fw_lib.AtlasAtcaLinkAggPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Application is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      -----------------------------
      --  Interfaces to Application
      -----------------------------
      -- AXI-Lite Interface (axilClk domain): Address Range = [0x80000000:0xFFFFFFFF]
      axilClk         : in    sl;
      axilRst         : in    sl;
      axilReadMaster  : in    AxiLiteReadMasterType;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- Server Streaming Interface (axilClk domain)
      srvIbMasters    : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvIbSlaves     : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      srvObMasters    : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      srvObSlaves     : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Client Streaming Interface (axilClk domain)
      cltIbMasters    : out   AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltIbSlaves     : in    AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      cltObMasters    : in    AxiStreamOctalMasterArray(NUM_ETH_C-1 downto 0) := (others => (others => AXI_STREAM_MASTER_INIT_C));
      cltObSlaves     : out   AxiStreamOctalSlaveArray(NUM_ETH_C-1 downto 0)  := (others => (others => AXI_STREAM_SLAVE_FORCE_C));
      -- Misc. Interface
      ref156Clk       : in    sl;
      ref156Rst       : in    sl;
      ipmiBsi         : in    BsiBusType;
      -- mDP DATA/CMD Interface
      dPortDataP      : in    Slv4Array(23 downto 0);
      dPortDataN      : in    Slv4Array(23 downto 0);
      dPortCmdP       : out   slv(31 downto 0);
      dPortCmdN       : out   slv(31 downto 0);
      -- I2C Interface
      i2cScl          : inout slv(3 downto 0);
      i2cSda          : inout slv(3 downto 0);
      ---------------------
      --  Application Ports
      ---------------------
      -- Jitter Cleaner PLL Ports
      fpgaToPllClkP   : out   sl;
      fpgaToPllClkN   : out   sl;
      pllToFpgaClkP   : in    sl;
      pllToFpgaClkN   : in    sl;
      -- Front Panel Clock/LED/TTL Ports
      smaClkP         : in    sl;
      smaClkN         : in    sl;
      ledRedL         : out   slv(1 downto 0)                                 := "11";
      ledBlueL        : out   slv(1 downto 0)                                 := "11";
      ledGreenL       : out   slv(1 downto 0)                                 := "11";
      fpTrigInL       : in    sl;
      fpBusyOut       : out   sl                                              := '0';
      fpSpareOut      : out   sl                                              := '0';
      fpSpareInL      : in    sl;
      -- Backplane Clocks Ports
      bpClkIn         : in    slv(5 downto 0);
      bpClkOut        : out   slv(5 downto 0)                                 := (others => '0');
      -- Front Panel QSFP+ Ports
      qsfpEthRefClkP  : in    sl;
      qsfpEthRefClkN  : in    sl;
      qsfpRef160ClkP  : in    sl;
      qsfpRef160ClkN  : in    sl;
      qsfpPllClkP     : in    sl;
      qsfpPllClkN     : in    sl;
      qsfpTxP         : out   Slv4Array(1 downto 0);
      qsfpTxN         : out   Slv4Array(1 downto 0);
      qsfpRxP         : in    Slv4Array(1 downto 0);
      qsfpRxN         : in    Slv4Array(1 downto 0);
      -- Front Panel SFP+ Ports
      sfpEthRefClkP   : in    sl;
      sfpEthRefClkN   : in    sl;
      sfpRef160ClkP   : in    sl;
      sfpRef160ClkN   : in    sl;
      sfpPllClkP      : in    sl;
      sfpPllClkN      : in    sl;
      sfpTxP          : out   slv(3 downto 0);
      sfpTxN          : out   slv(3 downto 0);
      sfpRxP          : in    slv(3 downto 0);
      sfpRxN          : in    slv(3 downto 0));
end Application;

architecture mapping of Application is

   impure function RxPhyRemapDefault return Slv7Array is
      variable i      : natural;
      variable retVar : Slv7Array(127 downto 0);
   begin
      for i in 0 to 127 loop
         retVar(i) := toSlv(i, 7);
      end loop;
      return retVar;
   end function;

   constant RX_PHY_TO_APP_INIT_C : Slv7Array(127 downto 0) := RxPhyRemapDefault;
   constant RX_APP_TO_PHY_INIT_C : Slv7Array(127 downto 0) := RxPhyRemapDefault;

   constant VALID_THOLD_C : positive := (1024/8);

   constant I2C_CONFIG_C : I2cAxiLiteDevArray(0 to 2) := (
      0              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100000",      -- PCA9555
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'),           -- Repeat Start
      1              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100001",      -- PCA9555
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'),           -- Repeat Start
      2              => MakeI2cAxiLiteDevType(
         i2cAddress  => "0100010",      -- PCA9555
         dataSize    => 8,              -- in units of bits
         addrSize    => 8,              -- in units of bits
         endianness  => '0',            -- Little endian
         repeatStart => '1'));          -- Repeat Start

   constant NUM_AXIL_MASTERS_C : positive := 10;

   constant RX_PHY_INDEX_C       : natural := 0;
   constant EMU_INDEX_C          : natural := 1;  -- [1:2]
   constant I2C_INDEX_C          : natural := 4;  -- [4:7]
   constant RX_PHY_REMAP_INDEX_C : natural := 8;
   constant PGP_INDEX_C          : natural := 9;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, APP_AXIL_BASE_ADDR_C, 28, 24);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   constant RX_PHY_CONFIG_C : AxiLiteCrossbarMasterConfigArray(31 downto 0) := genAxiLiteConfig(32, AXIL_CONFIG_C(RX_PHY_INDEX_C).baseAddr, 24, 16);

   signal rxPhyWriteMasters : AxiLiteWriteMasterArray(31 downto 0);
   signal rxPhyWriteSlaves  : AxiLiteWriteSlaveArray(31 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_DECERR_C);
   signal rxPhyReadMasters  : AxiLiteReadMasterArray(31 downto 0);
   signal rxPhyReadSlaves   : AxiLiteReadSlaveArray(31 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_DECERR_C);

   signal mDataMasters : AxiStreamMasterArray(31 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal mDataSlaves  : AxiStreamSlaveArray(31 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal mConfigMasters : AxiStreamMasterArray(31 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal mConfigSlaves  : AxiStreamSlaveArray(31 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal sConfigMasters : AxiStreamMasterArray(31 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal sConfigSlaves  : AxiStreamSlaveArray(31 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal emuTimingMasters : AxiStreamMasterArray(31 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal emuTimingSlaves  : AxiStreamSlaveArray(31 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal serDesData : Slv8Array(127 downto 0) := (others => (others => '0'));
   signal dlyLoad    : slv(127 downto 0)       := (others => '0');
   signal dlyCfg     : Slv9Array(127 downto 0) := (others => (others => '0'));

   signal cmdBusyOut : slv(31 downto 0) := (others => '0');
   signal cmdBusyAll : sl               := '0';

   signal ref160Clock : sl := '0';
   signal ref160Clk   : sl := '0';
   signal ref160Rst   : sl := '1';

   signal clk160MHz : sl := '0';
   signal rst160MHz : sl := '1';

   signal smaClk       : sl := '0';
   signal pllToFpgaClk : sl := '0';

   signal iDelayCtrlRdy : sl := '0';
   signal refClk300MHz  : sl := '0';
   signal refRst300MHz  : sl := '1';

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   -------------------------
   -- Terminate Unused Ports
   -------------------------
   U_smaClk : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => smaClkP,
         IB    => smaClkN,
         CEB   => '0',
         ODIV2 => smaClk,
         O     => open);

   U_pllToFpgaClk : IBUFDS
      port map (
         I  => pllToFpgaClkP,
         IB => pllToFpgaClkN,
         O  => pllToFpgaClk);

   U_fpgaToPllClk : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => '0',
         clkOutP => fpgaToPllClkP,
         clkOutN => fpgaToPllClkN);

   --------------------------
   -- Reference 300 MHz clock
   --------------------------
   U_MMCM : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => SIMULATION_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 6.0,
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 300 MHz = 937.5 MHz/3.125
      port map(
         clkIn     => axilClk,
         rstIn     => axilRst,
         clkOut(0) => refClk300MHz,
         rstOut(0) => refRst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   -----------
   -- Clocking
   -----------
   U_IBUFDS_GTE4 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => qsfpRef160ClkP,
         IB    => qsfpRef160ClkN,
         CEB   => '0',
         ODIV2 => ref160Clock,
         O     => open);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => ref160Clock,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => ref160Clk);

   U_ref160Rst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ref160Clk,
         rstIn  => ref156Rst,
         rstOut => ref160Rst);

   ------------------------------
   -- High Speed SelectIO Modules
   ------------------------------
   U_Selectio : entity work.AtlasRd53HsSelectioWrapper
      generic map(
         TPD_G                => TPD_G,
         SIMULATION_G         => SIMULATION_G,
         RX_PHY_TO_APP_INIT_G => RX_PHY_TO_APP_INIT_C)
      port map (
         ref160Clk       => ref160Clk,
         ref160Rst       => ref160Rst,
         -- Deserialization Interface
         serDesData      => serDesData,
         dlyLoad         => dlyLoad,
         dlyCfg          => dlyCfg,
         iDelayCtrlRdy   => iDelayCtrlRdy,
         -- mDP DATA Interface
         dPortDataP      => dPortDataP,
         dPortDataN      => dPortDataN,
         -- Timing Clock/Reset Interface
         clk160MHz       => clk160MHz,
         rst160MHz       => rst160MHz,
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(RX_PHY_REMAP_INDEX_C),
         axilReadSlave   => axilReadSlaves(RX_PHY_REMAP_INDEX_C),
         axilWriteMaster => axilWriteMasters(RX_PHY_REMAP_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(RX_PHY_REMAP_INDEX_C));

   --------------------
   -- AXI-Lite Crossbar
   --------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
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

   U_RX_PHY_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => 32,
         MASTERS_CONFIG_G   => RX_PHY_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMasters(RX_PHY_INDEX_C),
         sAxiWriteSlaves(0)  => axilWriteSlaves(RX_PHY_INDEX_C),
         sAxiReadMasters(0)  => axilReadMasters(RX_PHY_INDEX_C),
         sAxiReadSlaves(0)   => axilReadSlaves(RX_PHY_INDEX_C),
         mAxiWriteMasters    => rxPhyWriteMasters,
         mAxiWriteSlaves     => rxPhyWriteSlaves,
         mAxiReadMasters     => rxPhyReadMasters,
         mAxiReadSlaves      => rxPhyReadSlaves);

   NOT_SIM : if (SIMULATION_G = false) generate

      ----------------------------------------------------
      -- https://www.xilinx.com/support/answers/70060.html
      ----------------------------------------------------
      GEN_QSFP :
      for i in 1 downto 0 generate
         U_TERM_GTs : entity surf.Gtye4ChannelDummy
            generic map (
               TPD_G   => TPD_G,
               WIDTH_G => 4)
            port map (
               refClk => ref156Clk,
               gtRxP  => qsfpRxP(i),
               gtRxN  => qsfpRxN(i),
               gtTxP  => qsfpTxP(i),
               gtTxN  => qsfpTxN(i));
      end generate GEN_QSFP;

      ----------------------
      -- AXI-Lite: Power I2C
      ----------------------
      GEN_I2C :
      for i in 3 downto 0 generate

         U_PCA9555 : entity surf.AxiI2cRegMaster
            generic map (
               TPD_G          => TPD_G,
               DEVICE_MAP_G   => I2C_CONFIG_C,
               I2C_SCL_FREQ_G => 400.0E+3,  -- units of Hz
               AXI_CLK_FREQ_G => AXIL_CLK_FREQ_C)
            port map (
               -- I2C Ports
               scl            => i2cScl(i),
               sda            => i2cSda(i),
               -- AXI-Lite Register Interface
               axiReadMaster  => axilReadMasters(i+I2C_INDEX_C),
               axiReadSlave   => axilReadSlaves(i+I2C_INDEX_C),
               axiWriteMaster => axilWriteMasters(i+I2C_INDEX_C),
               axiWriteSlave  => axilWriteSlaves(i+I2C_INDEX_C),
               -- Clocks and Resets
               axiClk         => axilClk,
               axiRst         => axilRst);

      end generate GEN_I2C;

   end generate;

   ----------------------------------
   -- Emulation Timing/Trigger Module
   ----------------------------------
   U_EmuTiming : entity atlas_rd53_fw_lib.AtlasRd53EmuTiming
      generic map(
         TPD_G         => TPD_G,
         NUM_AXIS_G    => 32,
         ADDR_WIDTH_G  => 10,
         SYNTH_MODE_G  => "xpm",
         MEMORY_TYPE_G => "block")
      port map(
         -- AXI-Lite Interface (axilClk domain)
         axilClk          => axilClk,
         axilRst          => axilRst,
         axilReadMasters  => axilReadMasters(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilReadSlaves   => axilReadSlaves(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilWriteMasters => axilWriteMasters(EMU_INDEX_C+1 downto EMU_INDEX_C),
         axilWriteSlaves  => axilWriteSlaves(EMU_INDEX_C+1 downto EMU_INDEX_C),
         -- Streaming RD53 Trig Interface (clk160MHz domain)
         clk160MHz        => clk160MHz,
         rst160MHz        => rst160MHz,
         emuTimingMasters => emuTimingMasters,
         emuTimingSlaves  => emuTimingSlaves);

   ------------------------
   -- Rd53 CMD/DATA Modules
   ------------------------
   GEN_mDP :
   for i in 31 downto 0 generate
      U_Core : entity atlas_rd53_fw_lib.AtlasRd53Core
         generic map (
            TPD_G         => TPD_G,
            SIMULATION_G  => SIMULATION_G,
            EN_RX_G       => ite((i < 24), true, false),  -- Only implement 24 RX core to fit into the FPGA
            AXIS_CONFIG_G => PGP3_AXIS_CONFIG_C,
            VALID_THOLD_G => VALID_THOLD_C,
            XIL_DEVICE_G  => XIL_DEVICE_C)
         port map (
            -- CMD busy Flags
            cmdBusyOut      => cmdBusyOut(i),
            cmdBusyAll      => cmdBusyAll,
            -- AXI-Lite Interface
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => rxPhyReadMasters(i),
            axilReadSlave   => rxPhyReadSlaves(i),
            axilWriteMaster => rxPhyWriteMasters(i),
            axilWriteSlave  => rxPhyWriteSlaves(i),
            -- Streaming EMU Trig Interface (clk160MHz domain)
            emuTimingMaster => emuTimingMasters(i),
            emuTimingSlave  => emuTimingSlaves(i),
            -- Streaming Data/Config Interface (axisClk domain)
            axisClk         => axilClk,
            axisRst         => axilRst,
            mDataMaster     => mDataMasters(i),
            mDataSlave      => mDataSlaves(i),
            sConfigMaster   => sConfigMasters(i),
            sConfigSlave    => sConfigSlaves(i),
            mConfigMaster   => mConfigMasters(i),
            mConfigSlave    => mConfigSlaves(i),
            -- Timing/Trigger Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- Deserialization Interface
            serDesData      => serDesData(4*i+3 downto 4*i),
            dlyLoad         => dlyLoad(4*i+3 downto 4*i),
            dlyCfg          => dlyCfg(4*i+3 downto 4*i),
            -- RD53 ASIC Serial Ports
            dPortCmdP       => dPortCmdP(i),
            dPortCmdN       => dPortCmdN(i));
   end generate GEN_mDP;

   process(clk160MHz)
   begin
      if rising_edge(clk160MHz) then
         cmdBusyAll <= uOr(cmdBusyOut) after TPD_G;
      end if;
   end process;

   U_Pgp3PhyGthQuad : entity work.Pgp3PhyGthQuad
      generic map (
         TPD_G            => TPD_G,
         SIMULATION_G     => SIMULATION_G,
         NUM_VC_G         => 16,        -- 8CMD/8DATA per lane
         AXIL_BASE_ADDR_G => AXIL_CONFIG_C(PGP_INDEX_C).baseAddr)
      port map (
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(PGP_INDEX_C),
         axilReadSlave   => axilReadSlaves(PGP_INDEX_C),
         axilWriteMaster => axilWriteMasters(PGP_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(PGP_INDEX_C),
         -- Streaming Interface (axilClk domain)
         rxConfigMasters => sConfigMasters,
         rxConfigSlaves  => sConfigSlaves,
         txConfigMasters => mConfigMasters,
         txConfigSlaves  => mConfigSlaves,
         txDataMasters   => mDataMasters,
         txDataSlaves    => mDataSlaves,
         -- PGP Ports
         pgpClkP         => sfpEthRefClkP,
         pgpClkN         => sfpEthRefClkN,
         pgpRxP          => sfpRxP,
         pgpRxN          => sfpRxN,
         pgpTxP          => sfpTxP,
         pgpTxN          => sfpTxN);

end mapping;
