-------------------------------------------------------------------------------
-- File       : AtlasRd53HsSelectioWrapper.vhd
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

library atlas_rd53_fw_lib;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53HsSelectioWrapper is
   generic (
      TPD_G                : time    := 1 ns;
      SIMULATION_G         : boolean := false;
      RX_PHY_TO_APP_INIT_C : Slv7Array(127 downto 0);
      RX_APP_TO_PHY_INIT_C : Slv7Array(127 downto 0));
   port (
      ref160Clk       : in  sl;
      ref160Rst       : in  sl;
      -- Deserialization Interface
      serDesData      : out Slv8Array(127 downto 0);
      dlyLoad         : in  slv(127 downto 0);
      dlyCfg          : in  Slv9Array(127 downto 0);
      iDelayCtrlRdy   : in  sl;
      -- mDP DATA Interface
      dPortDataP      : in  Slv4Array(23 downto 0);
      dPortDataN      : in  Slv4Array(23 downto 0);
      -- Timing Clock/Reset Interface
      clk160MHz       : out sl;
      rst160MHz       : out sl;
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end AtlasRd53HsSelectioWrapper;

architecture mapping of AtlasRd53HsSelectioWrapper is

   type RegType is record
      init           : sl;
      we             : sl;
      cnt            : slv(3 downto 0);
      addr           : slv(6 downto 0);
      data           : slv(13 downto 0);
      phyToAppRemap  : Slv7Array(127 downto 0);
      appToPhyRemap  : Slv7Array(127 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;
   constant REG_INIT_C : RegType := (
      init           => '1',
      we             => '0',
      cnt            => x"1",
      addr           => (others => '1'),
      data           => (others => '1'),
      phyToAppRemap  => RX_PHY_TO_APP_INIT_C,
      appToPhyRemap  => RX_APP_TO_PHY_INIT_C,
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal clock160 : sl := '0';
   signal reset160 : sl := '0';

   signal serDesData_s : Slv8Array(127 downto 0) := (others => (others => '0'));
   signal dlyLoad_s    : slv(127 downto 0)       := (others => '0');
   signal dlyCfg_s     : Slv9Array(127 downto 0) := (others => (others => '0'));

   signal ramData : slv(13 downto 0) := (others => '0');

begin

   clk160MHz <= clock160;
   rst160MHz <= reset160;

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
         serDesData    => serDesData_s(95 downto 0),
         dlyLoad       => dlyLoad_s(95 downto 0),
         dlyCfg        => dlyCfg_s(95 downto 0),
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- mDP DATA Interface
         dPortDataP    => dPortDataP,
         dPortDataN    => dPortDataN,
         -- Timing Clock/Reset Interface
         clk160MHz     => clock160,
         rst160MHz     => reset160);

--   process(clock160)
--      variable i : natural;
--   begin
--      if rising_edge(clock160) then
--         for i in 0 to 127 loop
--            serDesData(i)                               <= serDesData_s(conv_integer(r.phyToAppRemap(i))) after TPD_G;
--            dlyLoad_s(conv_integer(r.appToPhyRemap(i))) <= dlyLoad(i)                                     after TPD_G;
--            dlyCfg_s(conv_integer(r.appToPhyRemap(i)))  <= dlyCfg(i)                                      after TPD_G;
--         end loop;
--      end if;
--   end process;

   U_RxPhyMux : entity work.RxPhyMux
      generic map (
         TPD_G => TPD_G)
      port map (
         clk            => clock160,
         phyToAppRemap  => r.phyToAppRemap,
         appToPhyRemap  => r.appToPhyRemap,
         -- Application Interface
         serDesData_app => serDesData,
         dlyLoad_app    => dlyLoad,
         dlyCfg_app     => dlyCfg,
         -- PHY Interface
         serDesData_phy => serDesData_s,
         dlyLoad_phy    => dlyLoad_s,
         dlyCfg_phy     => dlyCfg_s);

   U_AxiDualPortRam : entity surf.AxiDualPortRam
      generic map (
         TPD_G          => TPD_G,
         SYNTH_MODE_G   => "inferred",
         MEMORY_TYPE_G  => "block",
         READ_LATENCY_G => 3,
         AXI_WR_EN_G    => true,
         SYS_WR_EN_G    => true,
         COMMON_CLK_G   => false,
         ADDR_WIDTH_G   => 7,
         DATA_WIDTH_G   => 14)
      port map (
         -- Axi Port
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMaster,
         axiReadSlave   => axilReadSlave,
         axiWriteMaster => axilWriteMaster,
         axiWriteSlave  => axilWriteSlave,
         -- Standard Port
         clk            => clock160,
         rst            => reset160,
         we             => r.we,
         addr           => r.addr,
         din            => r.data,
         dout           => ramData);

   comb : process (r, ramData, reset160) is
      variable v : RegType;

   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.we := '0';

      -- Check for init
      if (r.init = '1') then

         -- Load default configuration
         v.we                := '1';
         v.addr              := r.addr + 1;
         v.data(6 downto 0)  := RX_PHY_TO_APP_INIT_C(conv_integer(v.addr));
         v.data(13 downto 7) := RX_APP_TO_PHY_INIT_C(conv_integer(v.addr));

         -- Check for last write
         if (v.addr = "1111111") then
            -- Initialization is completed
            v.init := '0';
         end if;

      else

         -- Increment the counter
         v.cnt := r.cnt + 1;

         -- Check the counter
         if (r.cnt = 0) then

            -- Update the remap value
            v.phyToAppRemap(conv_integer(r.addr)) := ramData(6 downto 0);
            v.appToPhyRemap(conv_integer(r.addr)) := ramData(13 downto 7);

            -- Increment the counter
            v.addr := r.addr + 1;

         end if;

      end if;

      -- Synchronous Reset
      if (reset160 = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clock160) is
   begin
      if (rising_edge(clock160)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
