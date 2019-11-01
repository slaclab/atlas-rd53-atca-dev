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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.lpgbtfpga_package.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53EmuLpGbtLane is
   generic (
      TPD_G        : time                  := 1 ns;
      NUM_ELINK_G  : positive range 1 to 6 := 4;
      XIL_DEVICE_G : string                := "ULTRASCALE");
   port (
      -- AXI-Lite interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType  := AXI_LITE_READ_SLAVE_EMPTY_OK_C;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType := AXI_LITE_WRITE_SLAVE_EMPTY_OK_C;
      -- Timing Interface
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      -- RD53 ASIC Ports (clk160MHz domain)
      cmdOutP         : out slv(NUM_ELINK_G-1 downto 0);
      cmdOutN         : out slv(NUM_ELINK_G-1 downto 0);
      -- Deserialization Interface (clk160MHz domain)
      serDesData      : in  Slv8Array(NUM_ELINK_G-1 downto 0);
      rxLinkUp        : in  slv(NUM_ELINK_G-1 downto 0);
      -- SFP Interface
      refClk320       : in  sl;  -- Using jitter clean FMC 320 MHz reference
      gtRefClk320     : in  sl;  -- Using jitter clean FMC 320 MHz reference
      sfpTxP          : out sl;
      sfpTxN          : out sl;
      sfpRxP          : in  sl;
      sfpRxN          : in  sl);
end AtlasRd53EmuLpGbtLane;

architecture rtl of AtlasRd53EmuLpGbtLane is

   signal invCmd : slv(NUM_ELINK_G-1 downto 0) := (others => '0');
   signal dlyCmd : slv(NUM_ELINK_G-1 downto 0) := (others => '0');

   signal data : Slv8Array(NUM_ELINK_G-1 downto 0);

   signal cmd        : slv(NUM_ELINK_G-1 downto 0);
   signal cmdMask    : slv(NUM_ELINK_G-1 downto 0);
   signal cmdMaskDly : slv(NUM_ELINK_G-1 downto 0);
   signal D1         : slv(NUM_ELINK_G-1 downto 0);
   signal D2         : slv(NUM_ELINK_G-1 downto 0);
   signal cmdOutReg  : slv(NUM_ELINK_G-1 downto 0);

   signal downlinkUserData : slv(31 downto 0) := (others => '0');
   signal downlinkEcData   : slv(1 downto 0)  := (others => '0');
   signal downlinkIcData   : slv(1 downto 0)  := (others => '0');
   signal downlinkReady    : sl;
   signal donwlinkClk      : sl;
   signal downlinkRst      : sl;
   signal downlinkClkEn    : sl;

   signal uplinkUserData : slv(229 downto 0) := (others => '0');
   signal uplinkEcData   : slv(1 downto 0)   := (others => '0');
   signal uplinkIcData   : slv(1 downto 0)   := (others => '0');
   signal uplinkReady    : sl;
   signal uplinkClk      : sl;
   signal uplinkRst      : sl;
   signal uplinkClkEn    : sl;

   signal reset160MHz : sl;

begin

   U_rst160MHz : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clk160MHz,
         rstIn  => rst160MHz,
         rstOut => reset160MHz);

   -------------------------
   -- Generate the uplinkRst
   -------------------------
   U_uplinkRst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => axilRst,
         clk    => uplinkClk,
         rstOut => uplinkRst);

   -------------------------
   -- DATA Generation Module
   -------------------------
   GEN_DATA :
   for i in NUM_ELINK_G-1 downto 0 generate

      -- Only send the data (include invert) if the delay alignment is completed
      data(i) <= not(serDesData(i)) when(rxLinkUp(i) = '1') else x"00";

      U_Gearbox_Data : entity work.AsyncGearbox
         generic map (
            TPD_G                => TPD_G,
            SLAVE_WIDTH_G        => 8,
            MASTER_WIDTH_G       => 32,
            -- Pipelining generics
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 0,
            -- Async FIFO generics
            FIFO_BRAM_EN_G       => false,
            FIFO_ADDR_WIDTH_G    => 5)
         port map (
            -- Slave Interface
            slaveClk    => clk160MHz,
            slaveRst    => reset160MHz,
            slaveData   => data(i),
            slaveValid  => '1',
            slaveReady  => open,
            -- Master Interface
            masterClk   => uplinkClk,
            masterRst   => uplinkRst,
            masterData  => uplinkUserData((i*32)+31 downto i*32),
            masterValid => open,
            masterReady => uplinkClkEn);

   end generate GEN_DATA;

   -----------------------
   -- Emulation LpGBT FPGA
   -----------------------
   lpgbtFpga_top_inst : entity work.EmuLpGbtFpga10g24
      generic map (
         FEC => FEC12)
      port map (
         -- Up link
         uplinkClk_o         => uplinkClk,      -- 320 MHz
         uplinkClkEn_o       => uplinkClkEn,    -- 40 MHz strobe
         uplinkRst_i         => uplinkRst,
         uplinkUserData_i    => uplinkUserData,
         uplinkEcData_i      => uplinkEcData,
         uplinkIcData_i      => uplinkIcData,
         uplinkReady_o       => uplinkReady,
         -- Down link
         donwlinkClk_o       => donwlinkClk,    -- 320 MHz
         downlinkClkEn_o     => downlinkClkEn,  -- 40 MHz strobe
         downlinkRst_i       => downlinkRst,
         downlinkUserData_o  => downlinkUserData,
         downlinkEcData_o    => downlinkEcData,
         downlinkIcData_o    => downlinkIcData,
         downlinkReady_o     => downlinkReady,
         -- MGT
         clk_refclk_i        => refClk320,
         clk_mgtrefclk_i     => gtRefClk320,
         clk_mgtfreedrpclk_i => axilClk,
         mgt_rxn_i           => sfpRxN,
         mgt_rxp_i           => sfpRxP,
         mgt_txn_o           => sfpTxN,
         mgt_txp_o           => sfpTxP);

   ---------------------------
   -- Generate the downlinkRst
   ---------------------------
   U_downlinkRst : entity work.PwrUpRst
      generic map (
         TPD_G => TPD_G)
      port map (
         arst   => axilRst,
         clk    => donwlinkClk,
         rstOut => downlinkRst);

   ------------------------
   -- CMD Generation Module
   ------------------------
   GEN_CMD :
   for i in NUM_ELINK_G-1 downto 0 generate

      U_Gearbox_Cmd : entity work.AsyncGearbox
         generic map (
            TPD_G                => TPD_G,
            SLAVE_WIDTH_G        => 4,
            MASTER_WIDTH_G       => 1,
            -- Pipelining generics
            INPUT_PIPE_STAGES_G  => 0,
            OUTPUT_PIPE_STAGES_G => 0,
            -- Async FIFO generics
            FIFO_BRAM_EN_G       => false,
            FIFO_ADDR_WIDTH_G    => 5)
         port map (
            -- Slave Interface
            slaveClk      => donwlinkClk,
            slaveRst      => downlinkRst,
            slaveData     => downlinkUserData((i*4)+3 downto i*4),
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
