-------------------------------------------------------------------------------
-- File       : AtlasRd53EmuLpGbtLane.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Receives the CMD from LpGBT
--              and does the SELECTIO delay alignment before LpGBT transmit
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 FMC DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 FMC DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

use work.lpgbtfpga_package.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53EmuLpGbtLane is
   generic (
      TPD_G             : time                  := 1 ns;
      NUM_ELINK_G       : positive range 1 to 7 := 6;
      SELECT_GT_TYPE_G  : boolean               := false;  -- false = GTH, true = GTY
      CPLL_REFCLK_SEL_G : slv(2 downto 0)       := "001";
      XIL_DEVICE_G      : string                := "ULTRASCALE");
   port (
      -- AXI-Lite interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Timing Interface
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      -- RD53 ASIC Ports (clk160MHz domain)
      cmdOutP         : out slv(NUM_ELINK_G-1 downto 0);
      cmdOutN         : out slv(NUM_ELINK_G-1 downto 0);
      -- CMD Outputs (clk160MHz domain)
      cmdOut          : out slv(NUM_ELINK_G-1 downto 0);
      invCmdOut       : out slv(NUM_ELINK_G-1 downto 0);
      dlyCmdOut       : out slv(NUM_ELINK_G-1 downto 0);
      -- Deserialization Interface (clk160MHz domain)
      serDesData      : in  Slv8Array(NUM_ELINK_G-1 downto 0);
      rxLinkUp        : in  slv(NUM_ELINK_G-1 downto 0);
      -- SFP Interface
      refClk160       : in  sl;  -- Using jitter clean FMC 320 MHz reference
      drpClk          : in  sl;
      rxRecClk        : out sl;
      txWordClk160    : out sl;
      rxWordClk80     : out sl;
      txWordClk40     : in  sl;
      rxWordClk40     : in  sl;
      qplllock        : in  slv(1 downto 0);
      qplloutclk      : in  slv(1 downto 0);
      qplloutrefclk   : in  slv(1 downto 0);
      qpllRst         : out sl;
      downlinkUp      : out sl;
      uplinkUp        : out sl;
      sfpTxP          : out sl;
      sfpTxN          : out sl;
      sfpRxP          : in  sl;
      sfpRxN          : in  sl);
end AtlasRd53EmuLpGbtLane;

architecture rtl of AtlasRd53EmuLpGbtLane is

   signal invCmd : slv(NUM_ELINK_G-1 downto 0);
   signal dlyCmd : slv(NUM_ELINK_G-1 downto 0);

   signal invData         : sl;
   signal bitOrderData32b : sl;
   signal bitOrderCmd4b   : sl;

   signal data8bMask  : Slv8Array(6 downto 0)  := (others => (others => '0'));
   signal data8b      : Slv8Array(6 downto 0)  := (others => (others => '0'));
   signal data32bMask : Slv32Array(6 downto 0) := (others => (others => '0'));
   signal data32b     : Slv32Array(6 downto 0) := (others => (others => '0'));

   signal cmd        : slv(NUM_ELINK_G-1 downto 0);
   signal cmdMask    : slv(NUM_ELINK_G-1 downto 0);
   signal cmdMaskDly : slv(NUM_ELINK_G-1 downto 0);
   signal D1         : slv(NUM_ELINK_G-1 downto 0);
   signal D2         : slv(NUM_ELINK_G-1 downto 0);
   signal cmdOutReg  : slv(NUM_ELINK_G-1 downto 0);

   signal downlinkUserData : slv(31 downto 0) := (others => '0');
   signal downlinkData     : slv(31 downto 0) := (others => '0');
   signal downlinkEcData   : slv(1 downto 0)  := (others => '0');
   signal downlinkIcData   : slv(1 downto 0)  := (others => '0');
   signal downlinkReady    : sl;
   signal donwlinkClk      : sl;
   signal downlinkRst      : sl;
   signal downlinkClkEn    : sl;

   signal uplinkUserData : slv(229 downto 0) := (others => '0');
   signal uplinkEcData   : slv(1 downto 0);
   signal uplinkIcData   : slv(1 downto 0);
   signal uplinkReady    : sl;
   signal uplinkClk      : sl;
   signal uplinkRst      : sl;
   signal uplinkClkEn    : sl;

   signal fecMode           : sl;
   signal fecDisable        : sl := '0';
   signal interleaverBypass : sl := '0';
   signal scramblerBypass   : sl := '0';
   signal txDummyFec12Vec   : Slv10Array(1 downto 0);
   signal txDummyFec5Vec    : Slv6Array(1 downto 0);
   signal txDummyFec12      : slv(9 downto 0);
   signal txDummyFec5       : slv(5 downto 0);
   signal linkDownPattern   : slv(7 downto 0);

   signal debugMode     : slv(6 downto 0);
   signal debugPatternA : Slv32Array(6 downto 0);
   signal debugPatternB : Slv32Array(6 downto 0);
   signal data32bToggle : sl := '0';


begin

   downlinkUp <= downlinkReady;
   uplinkUp   <= uplinkReady;

   cmdOut    <= cmd;
   invCmdOut <= invCmd;
   dlyCmdOut <= dlyCmd;

   ---------------------------
   -- Axi-Lite Register Module
   ---------------------------
   U_AxilReg : entity work.AtlasRd53EmuLpGbtLaneReg
      generic map (
         TPD_G       => TPD_G,
         NUM_ELINK_G => NUM_ELINK_G)
      port map (
         -- Config/status Interface (clk160MHz domain)
         clk160MHz         => clk160MHz,
         rst160MHz         => rst160MHz,
         downlinkUp        => downlinkReady,
         uplinkUp          => uplinkReady,
         rxLinkUp          => rxLinkUp,
         invCmd            => invCmd,
         dlyCmd            => dlyCmd,
         downlinkRst       => downlinkRst,
         uplinkRst         => uplinkRst,
         invData           => invData,
         linkDownPattern   => linkDownPattern,
         -- Config/status Interface (uplinkClk domain)
         uplinkClk         => uplinkClk,
         fecMode           => fecMode,
         fecDisable        => fecDisable,
         interleaverBypass => interleaverBypass,
         scramblerBypass   => scramblerBypass,
         txDummyFec12      => txDummyFec12Vec,
         txDummyFec5       => txDummyFec5Vec,
         bitOrderData32b   => bitOrderData32b,
         debugMode         => debugMode,
         debugPatternA     => debugPatternA,
         debugPatternB     => debugPatternB,
         uplinkEcData      => uplinkEcData,
         uplinkIcData      => uplinkIcData,
         -- Config/status Interface (donwlinkClk domain)
         donwlinkClk       => donwlinkClk,
         bitOrderCmd4b     => bitOrderCmd4b,
         -- AXI-Lite Interface (axilClk domain)
         axilClk           => axilClk,
         axilRst           => axilRst,
         axilReadMaster    => axilReadMaster,
         axilReadSlave     => axilReadSlave,
         axilWriteMaster   => axilWriteMaster,
         axilWriteSlave    => axilWriteSlave);

   -------------------------
   -- DATA Generation Module
   -------------------------
   GEN_DATA :
   for i in NUM_ELINK_G-1 downto 0 generate

      -------------------------------------------------------------
      -- Set the data invert (in case of polarity swap on connector
      -------------------------------------------------------------
      data8bMask(i) <= not(serDesData(i)) when(invData = '1') else serDesData(i);

      ---------------------------------------------------------
      -- Only send the data if the delay alignment is completed
      ---------------------------------------------------------
      data8b(i) <= data8bMask(i) when(rxLinkUp(i) = '1') else linkDownPattern;

      ---------------
      -- 8:32 Gearbox
      ---------------
      U_Gearbox_Data : entity surf.AsyncGearbox
         generic map (
            TPD_G                => TPD_G,
            SLAVE_WIDTH_G        => 8,
            MASTER_WIDTH_G       => 32,
            -- Pipelining generics
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 0,
            -- Async FIFO generics
            FIFO_MEMORY_TYPE_G   => "distributed",
            FIFO_ADDR_WIDTH_G    => 5)
         port map (
            -- Slave Interface
            slaveClk    => clk160MHz,
            slaveRst    => rst160MHz,
            slaveData   => data8b(i),
            slaveValid  => '1',
            slaveReady  => open,
            -- Master Interface
            masterClk   => uplinkClk,
            masterRst   => uplinkRst,
            masterData  => data32b(i),
            masterValid => open,
            masterReady => uplinkClkEn);

      -----------------------
      -- Set the bit ordering
      -----------------------
      data32bMask(i) <= data32b(i) when(bitOrderData32b = '0') else bitReverse(data32b(i));

   end generate GEN_DATA;

   ----------------------------------------------------------
   -- Check if we are in debug mode and sending debug pattern
   ----------------------------------------------------------
   process(data32bMask, data32bToggle, debugMode, debugPatternA, debugPatternB,
           txDummyFec12Vec, txDummyFec5Vec)
      variable i : natural;
   begin
      for i in 6 downto 0 loop
         if (debugMode(i) = '0') then
            uplinkUserData((i*32)+31 downto i*32) <= data32bMask(i);
         else
            if (data32bToggle = '0') then
               uplinkUserData((i*32)+31 downto i*32) <= debugPatternA(i);
            else
               uplinkUserData((i*32)+31 downto i*32) <= debugPatternB(i);
            end if;
         end if;
      end loop;
      if (data32bToggle = '0') then
         txDummyFec12 <= txDummyFec12Vec(0);
         txDummyFec5  <= txDummyFec5Vec(0);
      else
         txDummyFec12 <= txDummyFec12Vec(1);
         txDummyFec5  <= txDummyFec5Vec(1);
      end if;
   end process;

   process(uplinkClk)
   begin
      if rising_edge(uplinkClk) then
         if data32bToggle = '1' then
            data32bToggle <= '0' after TPD_G;
         else
            data32bToggle <= '1' after TPD_G;
         end if;
      end if;
   end process;

   -----------------------
   -- Emulation LpGBT FPGA
   -----------------------
   lpgbtFpga_top_inst : entity work.EmuLpGbtFpga10g24
      generic map (
         SELECT_GT_TYPE_G  => SELECT_GT_TYPE_G,
         CPLL_REFCLK_SEL_G => CPLL_REFCLK_SEL_G)
      port map (
         -- Uplink mode
         fecMode             => fecMode,
         fecDisable          => fecDisable,
         interleaverBypass   => interleaverBypass,
         scramblerBypass     => scramblerBypass,
         txDummyFec12        => txDummyFec12,
         txDummyFec5         => txDummyFec5,
         -- Up link
         uplinkClk_o         => uplinkClk,      -- 40 MHz
         uplinkClkEn_o       => uplinkClkEn,    -- 40 MHz strobe
         uplinkRst_i         => uplinkRst,      -- ASYNC RST
         uplinkUserData_i    => uplinkUserData,
         uplinkEcData_i      => uplinkEcData,
         uplinkIcData_i      => uplinkIcData,
         uplinkReady_o       => uplinkReady,
         -- Down link
         donwlinkClk_o       => donwlinkClk,    -- 40 MHz
         downlinkClkEn_o     => downlinkClkEn,  -- 40 MHz strobe
         downlinkRst_i       => downlinkRst,    -- ASYNC RST
         downlinkUserData_o  => downlinkUserData,
         downlinkEcData_o    => downlinkEcData,
         downlinkIcData_o    => downlinkIcData,
         downlinkReady_o     => downlinkReady,
         -- MGT
         txWordClk160_o      => txWordClk160,
         rxWordClk80_o       => rxWordClk80,
         txWordClk40_i       => txWordClk40,
         rxWordClk40_i       => rxWordClk40,
         qplllock            => qplllock,
         qplloutclk          => qplloutclk,
         qplloutrefclk       => qplloutrefclk,
         qpllRst             => qpllRst,
         rxRecClk            => rxRecClk,
         clk_refclk_i        => refClk160,      -- CPLL using 160 MHz reference
         clk_mgtfreedrpclk_i => drpClk,
         mgt_rxn_i           => sfpRxN,
         mgt_rxp_i           => sfpRxP,
         mgt_txn_o           => sfpTxN,
         mgt_txp_o           => sfpTxP);

   ------------------------
   -- CMD Generation Module
   ------------------------
   GEN_CMD :
   for i in NUM_ELINK_G-1 downto 0 generate

      -----------------------
      -- Set the bit ordering
      -----------------------
      downlinkData((i*4)+3 downto i*4) <= downlinkUserData((i*4)+3 downto i*4) when(bitOrderCmd4b = '0') else bitReverse(downlinkUserData((i*4)+3 downto i*4));

      --------------
      -- 4:1 Gearbox
      --------------
      U_Gearbox_Cmd : entity surf.AsyncGearbox
         generic map (
            TPD_G                => TPD_G,
            SLAVE_WIDTH_G        => 4,
            MASTER_WIDTH_G       => 1,
            -- Pipelining generics
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 0,
            -- Async FIFO generics
            FIFO_MEMORY_TYPE_G   => "distributed",
            FIFO_ADDR_WIDTH_G    => 5)
         port map (
            -- Slave Interface
            slaveClk      => donwlinkClk,
            slaveRst      => downlinkRst,
            slaveData     => downlinkData((i*4)+3 downto i*4),
            slaveValid    => downlinkClkEn,
            slaveReady    => open,
            -- Master Interface
            masterClk     => clk160MHz,
            masterRst     => rst160MHz,
            masterData(0) => cmd(i),
            masterValid   => open,
            masterReady   => '1');

      ----------------------------------
      -- Set the command polarity output
      ----------------------------------
      cmdMask(i) <= cmd(i) xor invCmd(i);

      --------------------------
      -- Generate a delayed copy
      --------------------------
      process(clk160MHz)
      begin
         if rising_edge(clk160MHz) then
            cmdMaskDly(i) <= cmdMask(i) after TPD_G;
         end if;
      end process;

      -------------------------------------------------------------------------------------
      -- Add the ability to deskew the CMD with respect to the external re-timing flip-flop
      -------------------------------------------------------------------------------------
      D1(i) <= cmdMask(i) when (dlyCmd(i) = '0') else cmdMaskDly(i);
      D2(i) <= cmdMask(i);

      -----------------------------
      -- Output DDR Register Module
      -----------------------------
      GEN_7SERIES : if (XIL_DEVICE_G = "7SERIES") generate
         U_OutputReg : ODDR
            generic map (
               DDR_CLK_EDGE => "SAME_EDGE")
            port map (
               C  => clk160MHz,
               Q  => cmdOutReg(i),
               CE => '1',
               D1 => D1(i),
               D2 => D2(i),
               R  => '0',
               S  => '0');
      end generate;

      GEN_ULTRASCALE : if (XIL_DEVICE_G = "ULTRASCALE") or (XIL_DEVICE_G = "ULTRASCALE_PLUS") generate
         U_OutputReg : ODDRE1
            generic map (
               SIM_DEVICE => XIL_DEVICE_G)
            port map (
               C  => clk160MHz,
               Q  => cmdOutReg(i),
               D1 => D1(i),
               D2 => D2(i),
               SR => '0');
      end generate;

      U_OBUFDS : OBUFDS
         port map (
            I  => cmdOutReg(i),
            O  => cmdOutP(i),
            OB => cmdOutN(i));

   end generate GEN_CMD;

end rtl;
