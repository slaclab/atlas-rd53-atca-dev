-------------------------------------------------------------------------------
-- File       : AtlasRd53HsSelectioBank66Tb.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Simulation Testbed for testing the FPGA module
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity AtlasRd53HsSelectioBank66Tb is end AtlasRd53HsSelectioBank66Tb;

architecture testbed of AtlasRd53HsSelectioBank66Tb is

   constant TPD_G : time := 1 ns;

   component AtlasRd53HsSelectioBank66
      port (
         rx_ce_0                    : in  std_logic;
         rx_inc_0                   : in  std_logic;
         rx_load_0                  : in  std_logic;
         rx_en_vtc_0                : in  std_logic;
         rx_ce_2                    : in  std_logic;
         rx_inc_2                   : in  std_logic;
         rx_load_2                  : in  std_logic;
         rx_en_vtc_2                : in  std_logic;
         rx_ce_4                    : in  std_logic;
         rx_inc_4                   : in  std_logic;
         rx_load_4                  : in  std_logic;
         rx_en_vtc_4                : in  std_logic;
         rx_ce_6                    : in  std_logic;
         rx_inc_6                   : in  std_logic;
         rx_load_6                  : in  std_logic;
         rx_en_vtc_6                : in  std_logic;
         rx_ce_8                    : in  std_logic;
         rx_inc_8                   : in  std_logic;
         rx_load_8                  : in  std_logic;
         rx_en_vtc_8                : in  std_logic;
         rx_ce_10                   : in  std_logic;
         rx_inc_10                  : in  std_logic;
         rx_load_10                 : in  std_logic;
         rx_en_vtc_10               : in  std_logic;
         rx_ce_13                   : in  std_logic;
         rx_inc_13                  : in  std_logic;
         rx_load_13                 : in  std_logic;
         rx_en_vtc_13               : in  std_logic;
         rx_ce_15                   : in  std_logic;
         rx_inc_15                  : in  std_logic;
         rx_load_15                 : in  std_logic;
         rx_en_vtc_15               : in  std_logic;
         rx_ce_17                   : in  std_logic;
         rx_inc_17                  : in  std_logic;
         rx_load_17                 : in  std_logic;
         rx_en_vtc_17               : in  std_logic;
         rx_ce_19                   : in  std_logic;
         rx_inc_19                  : in  std_logic;
         rx_load_19                 : in  std_logic;
         rx_en_vtc_19               : in  std_logic;
         rx_ce_21                   : in  std_logic;
         rx_inc_21                  : in  std_logic;
         rx_load_21                 : in  std_logic;
         rx_en_vtc_21               : in  std_logic;
         rx_ce_23                   : in  std_logic;
         rx_inc_23                  : in  std_logic;
         rx_load_23                 : in  std_logic;
         rx_en_vtc_23               : in  std_logic;
         rx_ce_26                   : in  std_logic;
         rx_inc_26                  : in  std_logic;
         rx_load_26                 : in  std_logic;
         rx_en_vtc_26               : in  std_logic;
         rx_ce_28                   : in  std_logic;
         rx_inc_28                  : in  std_logic;
         rx_load_28                 : in  std_logic;
         rx_en_vtc_28               : in  std_logic;
         rx_ce_30                   : in  std_logic;
         rx_inc_30                  : in  std_logic;
         rx_load_30                 : in  std_logic;
         rx_en_vtc_30               : in  std_logic;
         rx_ce_32                   : in  std_logic;
         rx_inc_32                  : in  std_logic;
         rx_load_32                 : in  std_logic;
         rx_en_vtc_32               : in  std_logic;
         rx_ce_34                   : in  std_logic;
         rx_inc_34                  : in  std_logic;
         rx_load_34                 : in  std_logic;
         rx_en_vtc_34               : in  std_logic;
         rx_ce_36                   : in  std_logic;
         rx_inc_36                  : in  std_logic;
         rx_load_36                 : in  std_logic;
         rx_en_vtc_36               : in  std_logic;
         rx_ce_39                   : in  std_logic;
         rx_inc_39                  : in  std_logic;
         rx_load_39                 : in  std_logic;
         rx_en_vtc_39               : in  std_logic;
         rx_ce_41                   : in  std_logic;
         rx_inc_41                  : in  std_logic;
         rx_load_41                 : in  std_logic;
         rx_en_vtc_41               : in  std_logic;
         rx_ce_43                   : in  std_logic;
         rx_inc_43                  : in  std_logic;
         rx_load_43                 : in  std_logic;
         rx_en_vtc_43               : in  std_logic;
         rx_ce_45                   : in  std_logic;
         rx_inc_45                  : in  std_logic;
         rx_load_45                 : in  std_logic;
         rx_en_vtc_45               : in  std_logic;
         rx_ce_47                   : in  std_logic;
         rx_inc_47                  : in  std_logic;
         rx_load_47                 : in  std_logic;
         rx_en_vtc_47               : in  std_logic;
         rx_ce_49                   : in  std_logic;
         rx_inc_49                  : in  std_logic;
         rx_load_49                 : in  std_logic;
         rx_en_vtc_49               : in  std_logic;
         rx_clk                     : in  std_logic;
         fifo_rd_clk_0              : in  std_logic;
         fifo_rd_clk_2              : in  std_logic;
         fifo_rd_clk_4              : in  std_logic;
         fifo_rd_clk_6              : in  std_logic;
         fifo_rd_clk_8              : in  std_logic;
         fifo_rd_clk_10             : in  std_logic;
         fifo_rd_clk_13             : in  std_logic;
         fifo_rd_clk_15             : in  std_logic;
         fifo_rd_clk_17             : in  std_logic;
         fifo_rd_clk_19             : in  std_logic;
         fifo_rd_clk_21             : in  std_logic;
         fifo_rd_clk_23             : in  std_logic;
         fifo_rd_clk_26             : in  std_logic;
         fifo_rd_clk_28             : in  std_logic;
         fifo_rd_clk_30             : in  std_logic;
         fifo_rd_clk_32             : in  std_logic;
         fifo_rd_clk_34             : in  std_logic;
         fifo_rd_clk_36             : in  std_logic;
         fifo_rd_clk_39             : in  std_logic;
         fifo_rd_clk_41             : in  std_logic;
         fifo_rd_clk_43             : in  std_logic;
         fifo_rd_clk_45             : in  std_logic;
         fifo_rd_clk_47             : in  std_logic;
         fifo_rd_clk_49             : in  std_logic;
         fifo_rd_en_0               : in  std_logic;
         fifo_rd_en_2               : in  std_logic;
         fifo_rd_en_4               : in  std_logic;
         fifo_rd_en_6               : in  std_logic;
         fifo_rd_en_8               : in  std_logic;
         fifo_rd_en_10              : in  std_logic;
         fifo_rd_en_13              : in  std_logic;
         fifo_rd_en_15              : in  std_logic;
         fifo_rd_en_17              : in  std_logic;
         fifo_rd_en_19              : in  std_logic;
         fifo_rd_en_21              : in  std_logic;
         fifo_rd_en_23              : in  std_logic;
         fifo_rd_en_26              : in  std_logic;
         fifo_rd_en_28              : in  std_logic;
         fifo_rd_en_30              : in  std_logic;
         fifo_rd_en_32              : in  std_logic;
         fifo_rd_en_34              : in  std_logic;
         fifo_rd_en_36              : in  std_logic;
         fifo_rd_en_39              : in  std_logic;
         fifo_rd_en_41              : in  std_logic;
         fifo_rd_en_43              : in  std_logic;
         fifo_rd_en_45              : in  std_logic;
         fifo_rd_en_47              : in  std_logic;
         fifo_rd_en_49              : in  std_logic;
         fifo_empty_0               : out std_logic;
         fifo_empty_2               : out std_logic;
         fifo_empty_4               : out std_logic;
         fifo_empty_6               : out std_logic;
         fifo_empty_8               : out std_logic;
         fifo_empty_10              : out std_logic;
         fifo_empty_13              : out std_logic;
         fifo_empty_15              : out std_logic;
         fifo_empty_17              : out std_logic;
         fifo_empty_19              : out std_logic;
         fifo_empty_21              : out std_logic;
         fifo_empty_23              : out std_logic;
         fifo_empty_26              : out std_logic;
         fifo_empty_28              : out std_logic;
         fifo_empty_30              : out std_logic;
         fifo_empty_32              : out std_logic;
         fifo_empty_34              : out std_logic;
         fifo_empty_36              : out std_logic;
         fifo_empty_39              : out std_logic;
         fifo_empty_41              : out std_logic;
         fifo_empty_43              : out std_logic;
         fifo_empty_45              : out std_logic;
         fifo_empty_47              : out std_logic;
         fifo_empty_49              : out std_logic;
         dly_rdy_bsc0               : out std_logic;
         dly_rdy_bsc1               : out std_logic;
         dly_rdy_bsc2               : out std_logic;
         dly_rdy_bsc3               : out std_logic;
         dly_rdy_bsc4               : out std_logic;
         dly_rdy_bsc5               : out std_logic;
         dly_rdy_bsc6               : out std_logic;
         dly_rdy_bsc7               : out std_logic;
         rst_seq_done               : out std_logic;
         shared_pll0_clkoutphy_out  : out std_logic;
         pll0_clkout0               : out std_logic;
         rst                        : in  std_logic;
         clk                        : in  std_logic;
         riu_clk                    : in  std_logic;
         pll0_locked                : out std_logic;
         data5_3p_0                 : in  std_logic;
         data_to_fabric_data5_3p_0  : out std_logic_vector(7 downto 0);
         data5_3n_1                 : in  std_logic;
         data5_2p_2                 : in  std_logic;
         data_to_fabric_data5_2p_2  : out std_logic_vector(7 downto 0);
         data5_2n_3                 : in  std_logic;
         data5_1p_4                 : in  std_logic;
         data_to_fabric_data5_1p_4  : out std_logic_vector(7 downto 0);
         data5_1n_5                 : in  std_logic;
         data5_0p_6                 : in  std_logic;
         data_to_fabric_data5_0p_6  : out std_logic_vector(7 downto 0);
         data5_0n_7                 : in  std_logic;
         data4_3p_8                 : in  std_logic;
         data_to_fabric_data4_3p_8  : out std_logic_vector(7 downto 0);
         data4_3n_9                 : in  std_logic;
         data4_2p_10                : in  std_logic;
         data_to_fabric_data4_2p_10 : out std_logic_vector(7 downto 0);
         data4_2n_11                : in  std_logic;
         data4_1p_13                : in  std_logic;
         data_to_fabric_data4_1p_13 : out std_logic_vector(7 downto 0);
         data4_1n_14                : in  std_logic;
         data4_0p_15                : in  std_logic;
         data_to_fabric_data4_0p_15 : out std_logic_vector(7 downto 0);
         data4_0n_16                : in  std_logic;
         data3_3p_17                : in  std_logic;
         data_to_fabric_data3_3p_17 : out std_logic_vector(7 downto 0);
         data3_3n_18                : in  std_logic;
         data3_2p_19                : in  std_logic;
         data_to_fabric_data3_2p_19 : out std_logic_vector(7 downto 0);
         data3_2n_20                : in  std_logic;
         data3_1p_21                : in  std_logic;
         data_to_fabric_data3_1p_21 : out std_logic_vector(7 downto 0);
         data3_1n_22                : in  std_logic;
         data3_0p_23                : in  std_logic;
         data_to_fabric_data3_0p_23 : out std_logic_vector(7 downto 0);
         data3_0n_24                : in  std_logic;
         data0_0p_26                : in  std_logic;
         data_to_fabric_data0_0p_26 : out std_logic_vector(7 downto 0);
         data0_0n_27                : in  std_logic;
         data0_1p_28                : in  std_logic;
         data_to_fabric_data0_1p_28 : out std_logic_vector(7 downto 0);
         data0_1n_29                : in  std_logic;
         data0_2p_30                : in  std_logic;
         data_to_fabric_data0_2p_30 : out std_logic_vector(7 downto 0);
         data0_2n_31                : in  std_logic;
         data0_3p_32                : in  std_logic;
         data_to_fabric_data0_3p_32 : out std_logic_vector(7 downto 0);
         data0_3n_33                : in  std_logic;
         data1_0p_34                : in  std_logic;
         data_to_fabric_data1_0p_34 : out std_logic_vector(7 downto 0);
         data1_0n_35                : in  std_logic;
         data1_1p_36                : in  std_logic;
         data_to_fabric_data1_1p_36 : out std_logic_vector(7 downto 0);
         data1_1n_37                : in  std_logic;
         data1_2p_39                : in  std_logic;
         data_to_fabric_data1_2p_39 : out std_logic_vector(7 downto 0);
         data1_2n_40                : in  std_logic;
         data1_3p_41                : in  std_logic;
         data_to_fabric_data1_3p_41 : out std_logic_vector(7 downto 0);
         data1_3n_42                : in  std_logic;
         data2_0p_43                : in  std_logic;
         data_to_fabric_data2_0p_43 : out std_logic_vector(7 downto 0);
         data2_0n_44                : in  std_logic;
         data2_1p_45                : in  std_logic;
         data_to_fabric_data2_1p_45 : out std_logic_vector(7 downto 0);
         data2_1n_46                : in  std_logic;
         data2_2p_47                : in  std_logic;
         data_to_fabric_data2_2p_47 : out std_logic_vector(7 downto 0);
         data2_2n_48                : in  std_logic;
         data2_3p_49                : in  std_logic;
         data_to_fabric_data2_3p_49 : out std_logic_vector(7 downto 0);
         data2_3n_50                : in  std_logic
         );
   end component;

   signal ref160Clk : sl := '0';
   signal ref160Rst : sl := '1';

   signal dPortDataP : Slv4Array(23 downto 0) := (others => x"F");
   signal dPortDataN : Slv4Array(23 downto 0) := (others => x"0");
   signal dlySlip    : slv(95 downto 0)       := (others => '0');

   signal clock160MHz : slv(0 downto 0);
   signal reset160MHz : slv(0 downto 0);
   signal locked      : slv(0 downto 0);

   signal rx_clk  : slv(0 downto 0);
   signal riu_clk : slv(0 downto 0);

   signal dly_rdy_bsc0              : slv(0 downto 0);
   signal dly_rdy_bsc1              : slv(0 downto 0);
   signal dly_rdy_bsc2              : slv(0 downto 0);
   signal dly_rdy_bsc3              : slv(0 downto 0);
   signal dly_rdy_bsc4              : slv(0 downto 0);
   signal dly_rdy_bsc5              : slv(0 downto 0);
   signal dly_rdy_bsc6              : slv(0 downto 0);
   signal dly_rdy_bsc7              : slv(0 downto 0);
   signal rst_seq_done              : slv(0 downto 0);
   signal shared_pll0_clkoutphy_out : slv(0 downto 0);
   signal readEnable                : slv(3 downto 0);

   signal empty : slv(23 downto 0);
   signal rdEn  : slv(23 downto 0);
   signal vtc   : slv(23 downto 0);
   signal load  : slv(23 downto 0);
   signal inc   : slv(23 downto 0);
   signal ce    : slv(23 downto 0);
   signal data  : Slv8Array(23 downto 0);

begin

   U_Clk160 : entity work.ClkRst
      generic map (
         CLK_PERIOD_G      => 6.25 ns,
         RST_START_DELAY_G => 0 ns,
         RST_HOLD_TIME_G   => 1000 ns)
      port map (
         clkP => ref160Clk,
         rst  => ref160Rst);

   rx_clk  <= (others => ref160Clk);
   riu_clk <= (others => ref160Clk);

   GEN_RST :
   for i in 0 downto 0 generate

      U_Rst0 : entity work.RstSync
         generic map (
            TPD_G          => TPD_G,
            IN_POLARITY_G  => '0',
            OUT_POLARITY_G => '1')
         port map (
            clk      => clock160MHz(i),
            asyncRst => locked(i),
            syncRst  => reset160MHz(i));

      -----------------------------------------------------------------------
      -- For multi-clock source synchronous interfaces, the FIFO_RD_EN is 
      -- connected to the NOR of FIFO_EMPTY of all bitslices in the interface
      -----------------------------------------------------------------------
      readEnable(i*4+0) <= not(uOr(empty(24*i+11 downto 24*i+6)));
      readEnable(i*4+1) <= not(uOr(empty(24*i+5 downto 24*i+0)));
      readEnable(i*4+2) <= not(uOr(empty(24*i+17 downto 24*i+12)));
      readEnable(i*4+3) <= not(uOr(empty(24*i+23 downto 24*i+18)));
      process(clock160MHz)
      begin
         if rising_edge(clock160MHz(0)) then
            rdEn(24*i+11 downto 24*i+6)  <= (others => readEnable(i*4+0)) after TPD_G;
            rdEn(24*i+5 downto 24*i+0)   <= (others => readEnable(i*4+1)) after TPD_G;
            rdEn(24*i+17 downto 24*i+12) <= (others => readEnable(i*4+2)) after TPD_G;
            rdEn(24*i+23 downto 24*i+18) <= (others => readEnable(i*4+3)) after TPD_G;
         end if;
      end process;

   end generate GEN_RST;

   GEN_VEC :
   for i in 23 downto 0 generate

      ce(i)   <= dlySlip(i);
      inc(i)  <= dlySlip(i);
      load(i) <= '0';
      vtc(i)  <= '0';

      process(clock160MHz)
      begin
         if rising_edge(clock160MHz(0)) then
            dPortDataP(i) <= dPortDataP(i) + 1 after TPD_G;
         end if;
      end process;

      dPortDataN(i) <= not(dPortDataP(i));
      
   end generate GEN_VEC;


   U_Bank66 : AtlasRd53HsSelectioBank66
      port map (
         clk                        => ref160Clk,
         rst                        => ref160Rst,
         pll0_locked                => locked(0),
         pll0_clkout0               => clock160MHz(0),
         rx_clk                     => rx_clk(0),
         riu_clk                    => riu_clk(0),
         dly_rdy_bsc0               => dly_rdy_bsc0(0),
         dly_rdy_bsc1               => dly_rdy_bsc1(0),
         dly_rdy_bsc2               => dly_rdy_bsc2(0),
         dly_rdy_bsc3               => dly_rdy_bsc3(0),
         dly_rdy_bsc4               => dly_rdy_bsc4(0),
         dly_rdy_bsc5               => dly_rdy_bsc5(0),
         dly_rdy_bsc6               => dly_rdy_bsc6(0),
         dly_rdy_bsc7               => dly_rdy_bsc7(0),
         rst_seq_done               => rst_seq_done(0),
         shared_pll0_clkoutphy_out  => shared_pll0_clkoutphy_out(0),
         -- DATA[0][0]
         data0_0p_26                => dPortDataP(6*0+0)(0),
         data0_0n_27                => dPortDataN(6*0+0)(0),
         data_to_fabric_data0_0p_26 => data(24*0+0),
         rx_ce_26                   => ce(24*0+0),
         rx_inc_26                  => inc(24*0+0),
         rx_load_26                 => load(24*0+0),
         rx_en_vtc_26               => vtc(24*0+0),
         fifo_rd_clk_26             => clock160MHz(0),
         fifo_rd_en_26              => rdEn(24*0+0),
         fifo_empty_26              => empty(24*0+0),
         -- DATA[0][1]
         data0_1p_28                => dPortDataP(6*0+0)(1),
         data0_1n_29                => dPortDataN(6*0+0)(1),
         data_to_fabric_data0_1p_28 => data(24*0+1),
         rx_ce_28                   => ce(24*0+1),
         rx_inc_28                  => inc(24*0+1),
         rx_load_28                 => load(24*0+1),
         rx_en_vtc_28               => vtc(24*0+1),
         fifo_rd_clk_28             => clock160MHz(0),
         fifo_rd_en_28              => rdEn(24*0+1),
         fifo_empty_28              => empty(24*0+1),
         -- DATA[0][2]
         data0_2p_30                => dPortDataP(6*0+0)(2),
         data0_2n_31                => dPortDataN(6*0+0)(2),
         data_to_fabric_data0_2p_30 => data(24*0+2),
         rx_ce_30                   => ce(24*0+2),
         rx_inc_30                  => inc(24*0+2),
         rx_load_30                 => load(24*0+2),
         rx_en_vtc_30               => vtc(24*0+2),
         fifo_rd_clk_30             => clock160MHz(0),
         fifo_rd_en_30              => rdEn(24*0+2),
         fifo_empty_30              => empty(24*0+2),
         -- DATA[0][3]
         data0_3p_32                => dPortDataP(6*0+0)(3),
         data0_3n_33                => dPortDataN(6*0+0)(3),
         data_to_fabric_data0_3p_32 => data(24*0+3),
         rx_ce_32                   => ce(24*0+3),
         rx_inc_32                  => inc(24*0+3),
         rx_load_32                 => load(24*0+3),
         rx_en_vtc_32               => vtc(24*0+3),
         fifo_rd_clk_32             => clock160MHz(0),
         fifo_rd_en_32              => rdEn(24*0+3),
         fifo_empty_32              => empty(24*0+3),
         -- DATA[1][0]
         data1_0p_34                => dPortDataP(6*0+1)(0),
         data1_0n_35                => dPortDataN(6*0+1)(0),
         data_to_fabric_data1_0p_34 => data(24*0+4),
         rx_ce_34                   => ce(24*0+4),
         rx_inc_34                  => inc(24*0+4),
         rx_load_34                 => load(24*0+4),
         rx_en_vtc_34               => vtc(24*0+4),
         fifo_rd_clk_34             => clock160MHz(0),
         fifo_rd_en_34              => rdEn(24*0+4),
         fifo_empty_34              => empty(24*0+4),
         -- DATA[1][1]
         data1_1p_36                => dPortDataP(6*0+1)(1),
         data1_1n_37                => dPortDataN(6*0+1)(1),
         data_to_fabric_data1_1p_36 => data(24*0+5),
         rx_ce_36                   => ce(24*0+5),
         rx_inc_36                  => inc(24*0+5),
         rx_load_36                 => load(24*0+5),
         rx_en_vtc_36               => vtc(24*0+5),
         fifo_rd_clk_36             => clock160MHz(0),
         fifo_rd_en_36              => rdEn(24*0+5),
         fifo_empty_36              => empty(24*0+5),
         -- DATA[1][2]
         data1_2p_39                => dPortDataP(6*0+1)(2),
         data1_2n_40                => dPortDataN(6*0+1)(2),
         data_to_fabric_data1_2p_39 => data(24*0+6),
         rx_ce_39                   => ce(24*0+6),
         rx_inc_39                  => inc(24*0+6),
         rx_load_39                 => load(24*0+6),
         rx_en_vtc_39               => vtc(24*0+6),
         fifo_rd_clk_39             => clock160MHz(0),
         fifo_rd_en_39              => rdEn(24*0+6),
         fifo_empty_39              => empty(24*0+6),
         -- DATA[1][3]
         data1_3p_41                => dPortDataP(6*0+1)(3),
         data1_3n_42                => dPortDataN(6*0+1)(3),
         data_to_fabric_data1_3p_41 => data(24*0+7),
         rx_ce_41                   => ce(24*0+7),
         rx_inc_41                  => inc(24*0+7),
         rx_load_41                 => load(24*0+7),
         rx_en_vtc_41               => vtc(24*0+7),
         fifo_rd_clk_41             => clock160MHz(0),
         fifo_rd_en_41              => rdEn(24*0+7),
         fifo_empty_41              => empty(24*0+7),
         -- DATA[2][0]
         data2_0p_43                => dPortDataP(6*0+2)(0),
         data2_0n_44                => dPortDataN(6*0+2)(0),
         data_to_fabric_data2_0p_43 => data(24*0+8),
         rx_ce_43                   => ce(24*0+8),
         rx_inc_43                  => inc(24*0+8),
         rx_load_43                 => load(24*0+8),
         rx_en_vtc_43               => vtc(24*0+8),
         fifo_rd_clk_43             => clock160MHz(0),
         fifo_rd_en_43              => rdEn(24*0+8),
         fifo_empty_43              => empty(24*0+8),
         -- DATA[2][1]
         data2_1p_45                => dPortDataP(6*0+2)(1),
         data2_1n_46                => dPortDataN(6*0+2)(1),
         data_to_fabric_data2_1p_45 => data(24*0+9),
         rx_ce_45                   => ce(24*0+9),
         rx_inc_45                  => inc(24*0+9),
         rx_load_45                 => load(24*0+9),
         rx_en_vtc_45               => vtc(24*0+9),
         fifo_rd_clk_45             => clock160MHz(0),
         fifo_rd_en_45              => rdEn(24*0+9),
         fifo_empty_45              => empty(24*0+9),
         -- DATA[2][2]
         data2_2p_47                => dPortDataP(6*0+2)(2),
         data2_2n_48                => dPortDataN(6*0+2)(2),
         data_to_fabric_data2_2p_47 => data(24*0+10),
         rx_ce_47                   => ce(24*0+10),
         rx_inc_47                  => inc(24*0+10),
         rx_load_47                 => load(24*0+10),
         rx_en_vtc_47               => vtc(24*0+10),
         fifo_rd_clk_47             => clock160MHz(0),
         fifo_rd_en_47              => rdEn(24*0+10),
         fifo_empty_47              => empty(24*0+10),
         -- DATA[2][3]
         data2_3p_49                => dPortDataP(6*0+2)(3),
         data2_3n_50                => dPortDataN(6*0+2)(3),
         data_to_fabric_data2_3p_49 => data(24*0+11),
         rx_ce_49                   => ce(24*0+11),
         rx_inc_49                  => inc(24*0+11),
         rx_load_49                 => load(24*0+11),
         rx_en_vtc_49               => vtc(24*0+11),
         fifo_rd_clk_49             => clock160MHz(0),
         fifo_rd_en_49              => rdEn(24*0+11),
         fifo_empty_49              => empty(24*0+11),
         -- DATA[3][0]
         data3_0p_23                => dPortDataP(6*0+3)(0),
         data3_0n_24                => dPortDataN(6*0+3)(0),
         data_to_fabric_data3_0p_23 => data(24*0+12),
         rx_ce_23                   => ce(24*0+12),
         rx_inc_23                  => inc(24*0+12),
         rx_load_23                 => load(24*0+12),
         rx_en_vtc_23               => vtc(24*0+12),
         fifo_rd_clk_23             => clock160MHz(0),
         fifo_rd_en_23              => rdEn(24*0+12),
         fifo_empty_23              => empty(24*0+12),
         -- DATA[3][1]
         data3_1p_21                => dPortDataP(6*0+3)(1),
         data3_1n_22                => dPortDataN(6*0+3)(1),
         data_to_fabric_data3_1p_21 => data(24*0+13),
         rx_ce_21                   => ce(24*0+13),
         rx_inc_21                  => inc(24*0+13),
         rx_load_21                 => load(24*0+13),
         rx_en_vtc_21               => vtc(24*0+13),
         fifo_rd_clk_21             => clock160MHz(0),
         fifo_rd_en_21              => rdEn(24*0+13),
         fifo_empty_21              => empty(24*0+13),
         -- DATA[3][2]
         data3_2p_19                => dPortDataP(6*0+3)(2),
         data3_2n_20                => dPortDataN(6*0+3)(2),
         data_to_fabric_data3_2p_19 => data(24*0+14),
         rx_ce_19                   => ce(24*0+14),
         rx_inc_19                  => inc(24*0+14),
         rx_load_19                 => load(24*0+14),
         rx_en_vtc_19               => vtc(24*0+14),
         fifo_rd_clk_19             => clock160MHz(0),
         fifo_rd_en_19              => rdEn(24*0+14),
         fifo_empty_19              => empty(24*0+14),
         -- DATA[3][3]
         data3_3p_17                => dPortDataP(6*0+3)(3),
         data3_3n_18                => dPortDataN(6*0+3)(3),
         data_to_fabric_data3_3p_17 => data(24*0+15),
         rx_ce_17                   => ce(24*0+15),
         rx_inc_17                  => inc(24*0+15),
         rx_load_17                 => load(24*0+15),
         rx_en_vtc_17               => vtc(24*0+15),
         fifo_rd_clk_17             => clock160MHz(0),
         fifo_rd_en_17              => rdEn(24*0+15),
         fifo_empty_17              => empty(24*0+15),
         -- DATA[4][0]
         data4_0p_15                => dPortDataP(6*0+4)(0),
         data4_0n_16                => dPortDataN(6*0+4)(0),
         data_to_fabric_data4_0p_15 => data(24*0+16),
         rx_ce_15                   => ce(24*0+16),
         rx_inc_15                  => inc(24*0+16),
         rx_load_15                 => load(24*0+16),
         rx_en_vtc_15               => vtc(24*0+16),
         fifo_rd_clk_15             => clock160MHz(0),
         fifo_rd_en_15              => rdEn(24*0+16),
         fifo_empty_15              => empty(24*0+16),
         -- DATA[4][1]
         data4_1p_13                => dPortDataP(6*0+4)(1),
         data4_1n_14                => dPortDataN(6*0+4)(1),
         data_to_fabric_data4_1p_13 => data(24*0+17),
         rx_ce_13                   => ce(24*0+17),
         rx_inc_13                  => inc(24*0+17),
         rx_load_13                 => load(24*0+17),
         rx_en_vtc_13               => vtc(24*0+17),
         fifo_rd_clk_13             => clock160MHz(0),
         fifo_rd_en_13              => rdEn(24*0+17),
         fifo_empty_13              => empty(24*0+17),
         -- DATA[4][2]
         data4_2p_10                => dPortDataP(6*0+4)(2),
         data4_2n_11                => dPortDataN(6*0+4)(2),
         data_to_fabric_data4_2p_10 => data(24*0+18),
         rx_ce_10                   => ce(24*0+18),
         rx_inc_10                  => inc(24*0+18),
         rx_load_10                 => load(24*0+18),
         rx_en_vtc_10               => vtc(24*0+18),
         fifo_rd_clk_10             => clock160MHz(0),
         fifo_rd_en_10              => rdEn(24*0+18),
         fifo_empty_10              => empty(24*0+18),
         -- DATA[4][3]
         data4_3p_8                 => dPortDataP(6*0+4)(3),
         data4_3n_9                 => dPortDataN(6*0+4)(3),
         data_to_fabric_data4_3p_8  => data(24*0+19),
         rx_ce_8                    => ce(24*0+19),
         rx_inc_8                   => inc(24*0+19),
         rx_load_8                  => load(24*0+19),
         rx_en_vtc_8                => vtc(24*0+19),
         fifo_rd_clk_8              => clock160MHz(0),
         fifo_rd_en_8               => rdEn(24*0+19),
         fifo_empty_8               => empty(24*0+19),
         -- DATA[5][0]
         data5_0p_6                 => dPortDataP(6*0+5)(0),
         data5_0n_7                 => dPortDataN(6*0+5)(0),
         data_to_fabric_data5_0p_6  => data(24*0+20),
         rx_ce_6                    => ce(24*0+20),
         rx_inc_6                   => inc(24*0+20),
         rx_load_6                  => load(24*0+20),
         rx_en_vtc_6                => vtc(24*0+20),
         fifo_rd_clk_6              => clock160MHz(0),
         fifo_rd_en_6               => rdEn(24*0+20),
         fifo_empty_6               => empty(24*0+20),
         -- DATA[5][1]
         data5_1p_4                 => dPortDataP(6*0+5)(1),
         data5_1n_5                 => dPortDataN(6*0+5)(1),
         data_to_fabric_data5_1p_4  => data(24*0+21),
         rx_ce_4                    => ce(24*0+21),
         rx_inc_4                   => inc(24*0+21),
         rx_load_4                  => load(24*0+21),
         rx_en_vtc_4                => vtc(24*0+21),
         fifo_rd_clk_4              => clock160MHz(0),
         fifo_rd_en_4               => rdEn(24*0+21),
         fifo_empty_4               => empty(24*0+21),
         -- DATA[5][2]
         data5_2p_2                 => dPortDataP(6*0+5)(2),
         data5_2n_3                 => dPortDataN(6*0+5)(2),
         data_to_fabric_data5_2p_2  => data(24*0+22),
         rx_ce_2                    => ce(24*0+22),
         rx_inc_2                   => inc(24*0+22),
         rx_load_2                  => load(24*0+22),
         rx_en_vtc_2                => vtc(24*0+22),
         fifo_rd_clk_2              => clock160MHz(0),
         fifo_rd_en_2               => rdEn(24*0+22),
         fifo_empty_2               => empty(24*0+22),
         -- DATA[5][3]
         data5_3p_0                 => dPortDataP(6*0+5)(3),
         data5_3n_1                 => dPortDataN(6*0+5)(3),
         data_to_fabric_data5_3p_0  => data(24*0+23),
         rx_ce_0                    => ce(24*0+23),
         rx_inc_0                   => inc(24*0+23),
         rx_load_0                  => load(24*0+23),
         rx_en_vtc_0                => vtc(24*0+23),
         fifo_rd_clk_0              => clock160MHz(0),
         fifo_rd_en_0               => rdEn(24*0+23),
         fifo_empty_0               => empty(24*0+23));

end testbed;
