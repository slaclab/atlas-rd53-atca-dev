-------------------------------------------------------------------------------
-- File       : CmdPhyMux.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: PLL and Deserialization Wrapper
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

library unisim;
use unisim.vcomponents.all;

entity CmdPhyMux is
   generic (
      TPD_G                : time   := 1 ns;
      TX_APP_TO_PHY_INIT_G : Slv7Array(31 downto 0);
      XIL_DEVICE_G         : string := "ULTRASCALE");
   port (
      -- mDP CMD Interface
      cmdOutP         : out slv(31 downto 0);
      cmdOutN         : out slv(31 downto 0);
      -- Timing Clock/Reset Interface
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      cmd             : in  slv(127 downto 0);
      invCmd          : in  slv(127 downto 0);
      dlyCmd          : in  slv(127 downto 0);
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end CmdPhyMux;

architecture mapping of CmdPhyMux is

   type RegType is record
      init           : sl;
      we             : sl;
      cnt            : slv(3 downto 0);
      addr           : slv(4 downto 0);
      data           : slv(6 downto 0);
      appToPhyRemap  : Slv7Array(31 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;
   constant REG_INIT_C : RegType := (
      init           => '1',
      we             => '0',
      cnt            => x"1",
      addr           => (others => '1'),
      data           => (others => '1'),
      appToPhyRemap  => TX_APP_TO_PHY_INIT_G,
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal ramData : slv(6 downto 0) := (others => '0');

   signal cmd_phy    : slv(31 downto 0) := (others => '0');
   signal invCmd_phy : slv(31 downto 0) := (others => '0');
   signal dlyCmd_phy : slv(31 downto 0) := (others => '0');

   signal cmdMask    : slv(31 downto 0) := (others => '0');
   signal cmdMaskDly : slv(31 downto 0) := (others => '0');
   signal D1         : slv(31 downto 0) := (others => '0');
   signal D2         : slv(31 downto 0) := (others => '0');
   signal cmdOutReg  : slv(31 downto 0) := (others => '0');

begin

   U_AxiDualPortRam : entity surf.AxiDualPortRam
      generic map (
         TPD_G          => TPD_G,
         SYNTH_MODE_G   => "inferred",
         MEMORY_TYPE_G  => "block",
         READ_LATENCY_G => 3,
         AXI_WR_EN_G    => true,
         SYS_WR_EN_G    => true,
         COMMON_CLK_G   => false,
         ADDR_WIDTH_G   => 5,
         DATA_WIDTH_G   => 7)
      port map (
         -- Axi Port
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave,
         -- Standard Port
         clk            => clk160MHz,
         rst            => rst160MHz,
         we             => r.we,
         addr           => r.addr,
         din            => r.data,
         dout           => ramData);

   comb : process (r, ramData, rst160MHz) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.we := '0';

      -- Check for init
      if (r.init = '1') then

         -- Load default configuration
         v.we   := '1';
         v.addr := r.addr + 1;
         v.data := TX_APP_TO_PHY_INIT_G(conv_integer(v.addr));

         -- Check for last write
         if (uAnd(v.addr) = '1') then
            -- Initialization is completed
            v.init := '0';
         end if;

      else

         -- Increment the counter
         v.cnt := r.cnt + 1;

         -- Check the counter
         if (r.cnt = 0) then

            -- Update the remap value
            v.appToPhyRemap(conv_integer(r.addr)) := ramData;

            -- Increment the counter
            v.addr := r.addr + 1;

         end if;

      end if;

      -- Synchronous Reset
      if (rst160MHz = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clk160MHz) is
   begin
      if (rising_edge(clk160MHz)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   GEN_APP_TO_PHY :
   for i in 31 downto 0 generate

      U_cmd : entity surf.Mux
         generic map (
            TPD_G       => TPD_G,
            SEL_WIDTH_G => 7)
         port map (
            clk  => clk160MHz,
            sel  => r.appToPhyRemap(i),
            din  => cmd,
            dout => cmd_phy(i));

      U_invCmd : entity surf.Mux
         generic map (
            TPD_G       => TPD_G,
            SEL_WIDTH_G => 7)
         port map (
            clk  => clk160MHz,
            sel  => r.appToPhyRemap(i),
            din  => invCmd,
            dout => invCmd_phy(i));

      U_dlyCmd : entity surf.Mux
         generic map (
            TPD_G       => TPD_G,
            SEL_WIDTH_G => 7)
         port map (
            clk  => clk160MHz,
            sel  => r.appToPhyRemap(i),
            din  => dlyCmd,
            dout => dlyCmd_phy(i));

   end generate GEN_APP_TO_PHY;

   GEN_CMD :
   for i in 31 downto 0 generate

      ----------------------------------
      -- Set the command polarity output
      ----------------------------------
      cmdMask(i) <= cmd_phy(i) xor invCmd_phy(i);

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
      D1(i) <= cmdMask(i) when (dlyCmd_phy(i) = '0') else cmdMaskDly(i);
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

end mapping;
