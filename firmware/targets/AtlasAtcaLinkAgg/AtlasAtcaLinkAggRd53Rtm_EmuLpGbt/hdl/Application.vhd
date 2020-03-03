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
      dPortCmdP       : out   slv(23 downto 0);
      dPortCmdN       : out   slv(23 downto 0);
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

   constant NUM_AXIL_MASTERS_C : positive := 8;

   constant LP_GBT_INDEX_C : natural := 0;  -- [0:3]
   constant I2C_INDEX_C    : natural := 4;  -- [4:7]

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, APP_AXIL_BASE_ADDR_C, 28, 24);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0) := (others => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0)  := (others => AXI_LITE_READ_SLAVE_EMPTY_OK_C);

   signal serDesData : Slv8Array(95 downto 0);
   signal dlyLoad    : slv(95 downto 0);
   signal rxLinkUp   : slv(95 downto 0);
   signal dlyCfg     : Slv9Array(95 downto 0);

   signal ref160Clock : sl;
   signal ref160Clk   : sl;
   signal ref160Rst   : sl;

   signal clk160MHz : sl;
   signal rst160MHz : sl;

   signal smaClk : sl;

   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   signal refClk160     : sl;
   signal drpClk        : sl;
   signal rxRecClk      : slv(3 downto 0);
   signal qplllock      : slv(1 downto 0);
   signal qplloutclk    : slv(1 downto 0);
   signal qplloutrefclk : slv(1 downto 0);
   signal qpllRst       : slv(3 downto 0);

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

   ---------------------------------------------------------------------------------
   -- External Reference clock (required for synchronizing to remote LpGBT receiver) 
   ---------------------------------------------------------------------------------
   U_fpgaToPllClk : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_C)
      port map (
         clkIn   => rxRecClk(0),  -- emulation LP-GBT recovered clock used as jitter cleaner reference
         clkOutP => fpgaToPllClkP,
         clkOutN => fpgaToPllClkN);

   --------------------------------
   -- 160 MHz External Reference Clock
   --------------------------------
   U_IBUFDS_refClk160 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => sfpRef160ClkP,
         IB    => sfpRef160ClkN,
         CEB   => '0',
         ODIV2 => open,
         O     => refClk160);

   ------------------------
   -- LP-GBT QPLL Reference
   ------------------------
   U_EmuLpGbtQpll : entity work.xlx_ku_mgt_10g24_emu_qpll
      port map (
         -- MGT Clock Port (320 MHz)
         gtClkP        => sfpPllClkP,
         gtClkN        => sfpPllClkN,
         -- Quad PLL Interface
         qplllock      => qplllock,
         qplloutclk    => qplloutclk,
         qplloutrefclk => qplloutrefclk,
         qpllRst       => qpllRst(0));

   --------------------------
   -- 160 MHz Reference Clock
   --------------------------
   U_IBUFDS_ref160Clk : IBUFDS
      port map (
         I  => pllToFpgaClkP,
         IB => pllToFpgaClkN,
         O  => ref160Clock);

   U_BUFG_ref160Clk : BUFG
      port map (
         I => ref160Clock,
         O => ref160Clk);

   U_ref160Rst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => ref160Clk,
         rstIn  => axilRst,
         rstOut => ref160Rst);

   U_drp_clk : BUFGCE_DIV
      generic map (
         BUFGCE_DIVIDE => 4)
      port map (
         I   => axilClk,                -- 156.25 MHz 
         CE  => '1',
         CLR => '0',
         O   => drpClk);                -- 39.0625 MHz         

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

   ------------------------------         
   -- High Speed SelectIO Modules
   ------------------------------         
   U_Selectio : entity atlas_rd53_fw_lib.AtlasRd53HsSelectio
      generic map(
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         NUM_CHIP_G   => 24,
         XIL_DEVICE_G => "ULTRASCALE_PLUS")
      port map (
         ref160Clk     => ref160Clk,
         ref160Rst     => ref160Rst,
         -- Deserialization Interface
         serDesData    => serDesData,
         dlyLoad       => dlyLoad,
         dlyCfg        => dlyCfg,
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- mDP DATA Interface
         dPortDataP    => dPortDataP,
         dPortDataN    => dPortDataN,
         -- Timing Clock/Reset Interface
         clk160MHz     => clk160MHz,
         rst160MHz     => rst160MHz);

   ----------------------------------------------------------
   -- Using AuroraRxLane for this is IDELAY alignment feature
   ----------------------------------------------------------
   GEN_LANE : for i in (24*4)-1 downto 0 generate
      U_Rx : entity atlas_rd53_fw_lib.AuroraRxLane
         generic map (
            TPD_G        => TPD_G,
            SIMULATION_G => SIMULATION_G)
         port map (
            -- RD53 ASIC Serial Interface
            serDesData => serDesData(i),
            dlyLoad    => dlyLoad(i),
            dlyCfg     => dlyCfg(i),
            -- Timing Interface
            clk160MHz  => clk160MHz,
            rst160MHz  => rst160MHz,
            -- Output
            rxLinkUp   => rxLinkUp(i));
   end generate GEN_LANE;

   ------------------------------------------
   -- LpGBT Links for Rd53 CMD/DATA transport
   ------------------------------------------
   GEN_SFP :
   for i in 3 downto 0 generate
      U_EMU_LP_GBT : entity work.AtlasRd53EmuLpGbtLane
         generic map (
            TPD_G        => TPD_G,
            NUM_ELINK_G  => 6,
            XIL_DEVICE_G => XIL_DEVICE_C)
         port map (
            -- AXI-Lite interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMasters(LP_GBT_INDEX_C+i),
            axilReadSlave   => axilReadSlaves(LP_GBT_INDEX_C+i),
            axilWriteMaster => axilWriteMasters(LP_GBT_INDEX_C+i),
            axilWriteSlave  => axilWriteSlaves(LP_GBT_INDEX_C+i),
            -- Timing Interface
            clk160MHz       => clk160MHz,
            rst160MHz       => rst160MHz,
            -- RD53 ASIC Ports (clk160MHz domain)
            cmdOutP         => dPortCmdP(6*i+5 downto 6*i),
            cmdOutN         => dPortCmdN(6*i+5 downto 6*i),
            -- Deserialization Interface (clk160MHz domain)
            serDesData(0)   => serDesData(24*i+4*0+3),
            serDesData(1)   => serDesData(24*i+4*1+3),
            serDesData(2)   => serDesData(24*i+4*2+3),
            serDesData(3)   => serDesData(24*i+4*3+3),
            serDesData(4)   => serDesData(24*i+4*4+3),
            serDesData(5)   => serDesData(24*i+4*5+3),
            rxLinkUp(0)     => rxLinkUp(24*i+4*0+3),
            rxLinkUp(1)     => rxLinkUp(24*i+4*1+3),
            rxLinkUp(2)     => rxLinkUp(24*i+4*2+3),
            rxLinkUp(3)     => rxLinkUp(24*i+4*3+3),
            rxLinkUp(4)     => rxLinkUp(24*i+4*4+3),
            rxLinkUp(5)     => rxLinkUp(24*i+4*5+3),
            -- SFP Interface
            refClk160       => refClk160,
            rxRecClk        => rxRecClk(i),
            drpClk          => drpClk,
            qplllock        => qplllock,
            qplloutclk      => qplloutclk,
            qplloutrefclk   => qplloutrefclk,
            qpllRst         => qpllRst(i),
            sfpTxP          => sfpTxP(i),
            sfpTxN          => sfpTxN(i),
            sfpRxP          => sfpRxP(i),
            sfpRxN          => sfpRxN(i));
   end generate GEN_SFP;

end mapping;
