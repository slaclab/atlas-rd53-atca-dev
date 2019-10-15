-------------------------------------------------------------------------------
-- File       : AtlasRd53HsSelectio.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: PLL and Deserialization
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

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53HsSelectio is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      ref160Clk  : in  sl;
      ref160Rst  : in  sl;
      -- Deserialization Interface
      serDesData : out Slv8Array(95 downto 0);
      dlySlip    : in  slv(95 downto 0);
      -- mDP DATA Interface
      dPortDataP : in  Slv4Array(23 downto 0);
      dPortDataN : in  Slv4Array(23 downto 0);
      -- Timing Clock/Reset Interface
      clk160MHz  : out sl;
      rst160MHz  : out sl);
end AtlasRd53HsSelectio;

architecture mapping of AtlasRd53HsSelectio is

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

   component AtlasRd53HsSelectioBank68
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

   component AtlasRd53HsSelectioBank69
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

   component AtlasRd53HsSelectioBank71
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

   signal clock160MHz : slv(3 downto 0);
   signal reset160MHz : slv(3 downto 0);
   signal locked      : slv(3 downto 0);

   signal rx_clk  : slv(3 downto 0);
   signal riu_clk : slv(3 downto 0);
   
   signal readClk : sl;
   signal readRst : sl;

   signal dly_rdy_bsc0              : slv(3 downto 0);
   signal dly_rdy_bsc1              : slv(3 downto 0);
   signal dly_rdy_bsc2              : slv(3 downto 0);
   signal dly_rdy_bsc3              : slv(3 downto 0);
   signal dly_rdy_bsc4              : slv(3 downto 0);
   signal dly_rdy_bsc5              : slv(3 downto 0);
   signal dly_rdy_bsc6              : slv(3 downto 0);
   signal dly_rdy_bsc7              : slv(3 downto 0);
   signal rst_seq_done              : slv(3 downto 0);
   signal shared_pll0_clkoutphy_out : slv(3 downto 0);
   signal readEnable                : slv(15 downto 0);

   signal empty : slv(95 downto 0);
   signal rdEn  : slv(95 downto 0);
   signal vtc   : slv(95 downto 0);
   signal load  : slv(95 downto 0);
   signal inc   : slv(95 downto 0);
   signal ce    : slv(95 downto 0);
   signal data  : Slv8Array(95 downto 0);
   signal test  : Slv8Array(95 downto 0);

begin

   clk160MHz <= readClk;
   rst160MHz <= readRst;
   
   readClk <= ref160Clk;

   U_Rst0 : entity work.RstSync
      generic map (
         TPD_G          => TPD_G,
         IN_POLARITY_G  => '0',
         OUT_POLARITY_G => '1')
      port map (
         clk      => readClk,
         asyncRst => locked(0),
         syncRst  => readRst);

   rx_clk  <= (others => ref160Clk);
   riu_clk <= (others => ref160Clk);
   
   GEN_VEC :
   for i in 95 downto 0 generate

      rdEn(i) <= not(empty(i));
      
      ce(i)   <= dlySlip(i);
      inc(i)  <= dlySlip(i);
      load(i) <= '0';
      vtc(i)  <= '0';

      -- serDesData(i) <= test(i);
      serDesData(i) <= data(i);

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
         fifo_rd_clk_26             => readClk,
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
         fifo_rd_clk_28             => readClk,
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
         fifo_rd_clk_30             => readClk,
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
         fifo_rd_clk_32             => readClk,
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
         fifo_rd_clk_34             => readClk,
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
         fifo_rd_clk_36             => readClk,
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
         fifo_rd_clk_39             => readClk,
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
         fifo_rd_clk_41             => readClk,
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
         fifo_rd_clk_43             => readClk,
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
         fifo_rd_clk_45             => readClk,
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
         fifo_rd_clk_47             => readClk,
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
         fifo_rd_clk_49             => readClk,
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
         fifo_rd_clk_23             => readClk,
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
         fifo_rd_clk_21             => readClk,
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
         fifo_rd_clk_19             => readClk,
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
         fifo_rd_clk_17             => readClk,
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
         fifo_rd_clk_15             => readClk,
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
         fifo_rd_clk_13             => readClk,
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
         fifo_rd_clk_10             => readClk,
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
         fifo_rd_clk_8              => readClk,
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
         fifo_rd_clk_6              => readClk,
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
         fifo_rd_clk_4              => readClk,
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
         fifo_rd_clk_2              => readClk,
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
         fifo_rd_clk_0              => readClk,
         fifo_rd_en_0               => rdEn(24*0+23),
         fifo_empty_0               => empty(24*0+23));

   U_Bank71 : AtlasRd53HsSelectioBank71
      port map (
         clk                        => ref160Clk,
         rst                        => ref160Rst,
         pll0_locked                => locked(1),
         pll0_clkout0               => clock160MHz(1),
         rx_clk                     => rx_clk(1),
         riu_clk                    => riu_clk(1),
         dly_rdy_bsc0               => dly_rdy_bsc0(1),
         dly_rdy_bsc1               => dly_rdy_bsc1(1),
         dly_rdy_bsc2               => dly_rdy_bsc2(1),
         dly_rdy_bsc3               => dly_rdy_bsc3(1),
         dly_rdy_bsc4               => dly_rdy_bsc4(1),
         dly_rdy_bsc5               => dly_rdy_bsc5(1),
         dly_rdy_bsc6               => dly_rdy_bsc6(1),
         dly_rdy_bsc7               => dly_rdy_bsc7(1),
         rst_seq_done               => rst_seq_done(1),
         shared_pll0_clkoutphy_out  => shared_pll0_clkoutphy_out(1),
         -- DATA[0][0]
         data0_0p_26                => dPortDataP(6*1+0)(0),
         data0_0n_27                => dPortDataN(6*1+0)(0),
         data_to_fabric_data0_0p_26 => data(24*1+0),
         rx_ce_26                   => ce(24*1+0),
         rx_inc_26                  => inc(24*1+0),
         rx_load_26                 => load(24*1+0),
         rx_en_vtc_26               => vtc(24*1+0),
         fifo_rd_clk_26             => readClk,
         fifo_rd_en_26              => rdEn(24*1+0),
         fifo_empty_26              => empty(24*1+0),
         -- DATA[0][1]
         data0_1p_28                => dPortDataP(6*1+0)(1),
         data0_1n_29                => dPortDataN(6*1+0)(1),
         data_to_fabric_data0_1p_28 => data(24*1+1),
         rx_ce_28                   => ce(24*1+1),
         rx_inc_28                  => inc(24*1+1),
         rx_load_28                 => load(24*1+1),
         rx_en_vtc_28               => vtc(24*1+1),
         fifo_rd_clk_28             => readClk,
         fifo_rd_en_28              => rdEn(24*1+1),
         fifo_empty_28              => empty(24*1+1),
         -- DATA[0][2]
         data0_2p_30                => dPortDataP(6*1+0)(2),
         data0_2n_31                => dPortDataN(6*1+0)(2),
         data_to_fabric_data0_2p_30 => data(24*1+2),
         rx_ce_30                   => ce(24*1+2),
         rx_inc_30                  => inc(24*1+2),
         rx_load_30                 => load(24*1+2),
         rx_en_vtc_30               => vtc(24*1+2),
         fifo_rd_clk_30             => readClk,
         fifo_rd_en_30              => rdEn(24*1+2),
         fifo_empty_30              => empty(24*1+2),
         -- DATA[0][3]
         data0_3p_32                => dPortDataP(6*1+0)(3),
         data0_3n_33                => dPortDataN(6*1+0)(3),
         data_to_fabric_data0_3p_32 => data(24*1+3),
         rx_ce_32                   => ce(24*1+3),
         rx_inc_32                  => inc(24*1+3),
         rx_load_32                 => load(24*1+3),
         rx_en_vtc_32               => vtc(24*1+3),
         fifo_rd_clk_32             => readClk,
         fifo_rd_en_32              => rdEn(24*1+3),
         fifo_empty_32              => empty(24*1+3),
         -- DATA[1][0]
         data1_0p_34                => dPortDataP(6*1+1)(0),
         data1_0n_35                => dPortDataN(6*1+1)(0),
         data_to_fabric_data1_0p_34 => data(24*1+4),
         rx_ce_34                   => ce(24*1+4),
         rx_inc_34                  => inc(24*1+4),
         rx_load_34                 => load(24*1+4),
         rx_en_vtc_34               => vtc(24*1+4),
         fifo_rd_clk_34             => readClk,
         fifo_rd_en_34              => rdEn(24*1+4),
         fifo_empty_34              => empty(24*1+4),
         -- DATA[1][1]
         data1_1p_36                => dPortDataP(6*1+1)(1),
         data1_1n_37                => dPortDataN(6*1+1)(1),
         data_to_fabric_data1_1p_36 => data(24*1+5),
         rx_ce_36                   => ce(24*1+5),
         rx_inc_36                  => inc(24*1+5),
         rx_load_36                 => load(24*1+5),
         rx_en_vtc_36               => vtc(24*1+5),
         fifo_rd_clk_36             => readClk,
         fifo_rd_en_36              => rdEn(24*1+5),
         fifo_empty_36              => empty(24*1+5),
         -- DATA[1][2]
         data1_2p_39                => dPortDataP(6*1+1)(2),
         data1_2n_40                => dPortDataN(6*1+1)(2),
         data_to_fabric_data1_2p_39 => data(24*1+6),
         rx_ce_39                   => ce(24*1+6),
         rx_inc_39                  => inc(24*1+6),
         rx_load_39                 => load(24*1+6),
         rx_en_vtc_39               => vtc(24*1+6),
         fifo_rd_clk_39             => readClk,
         fifo_rd_en_39              => rdEn(24*1+6),
         fifo_empty_39              => empty(24*1+6),
         -- DATA[1][3]
         data1_3p_41                => dPortDataP(6*1+1)(3),
         data1_3n_42                => dPortDataN(6*1+1)(3),
         data_to_fabric_data1_3p_41 => data(24*1+7),
         rx_ce_41                   => ce(24*1+7),
         rx_inc_41                  => inc(24*1+7),
         rx_load_41                 => load(24*1+7),
         rx_en_vtc_41               => vtc(24*1+7),
         fifo_rd_clk_41             => readClk,
         fifo_rd_en_41              => rdEn(24*1+7),
         fifo_empty_41              => empty(24*1+7),
         -- DATA[2][0]
         data2_0p_43                => dPortDataP(6*1+2)(0),
         data2_0n_44                => dPortDataN(6*1+2)(0),
         data_to_fabric_data2_0p_43 => data(24*1+8),
         rx_ce_43                   => ce(24*1+8),
         rx_inc_43                  => inc(24*1+8),
         rx_load_43                 => load(24*1+8),
         rx_en_vtc_43               => vtc(24*1+8),
         fifo_rd_clk_43             => readClk,
         fifo_rd_en_43              => rdEn(24*1+8),
         fifo_empty_43              => empty(24*1+8),
         -- DATA[2][1]
         data2_1p_45                => dPortDataP(6*1+2)(1),
         data2_1n_46                => dPortDataN(6*1+2)(1),
         data_to_fabric_data2_1p_45 => data(24*1+9),
         rx_ce_45                   => ce(24*1+9),
         rx_inc_45                  => inc(24*1+9),
         rx_load_45                 => load(24*1+9),
         rx_en_vtc_45               => vtc(24*1+9),
         fifo_rd_clk_45             => readClk,
         fifo_rd_en_45              => rdEn(24*1+9),
         fifo_empty_45              => empty(24*1+9),
         -- DATA[2][2]
         data2_2p_47                => dPortDataP(6*1+2)(2),
         data2_2n_48                => dPortDataN(6*1+2)(2),
         data_to_fabric_data2_2p_47 => data(24*1+10),
         rx_ce_47                   => ce(24*1+10),
         rx_inc_47                  => inc(24*1+10),
         rx_load_47                 => load(24*1+10),
         rx_en_vtc_47               => vtc(24*1+10),
         fifo_rd_clk_47             => readClk,
         fifo_rd_en_47              => rdEn(24*1+10),
         fifo_empty_47              => empty(24*1+10),
         -- DATA[2][3]
         data2_3p_49                => dPortDataP(6*1+2)(3),
         data2_3n_50                => dPortDataN(6*1+2)(3),
         data_to_fabric_data2_3p_49 => data(24*1+11),
         rx_ce_49                   => ce(24*1+11),
         rx_inc_49                  => inc(24*1+11),
         rx_load_49                 => load(24*1+11),
         rx_en_vtc_49               => vtc(24*1+11),
         fifo_rd_clk_49             => readClk,
         fifo_rd_en_49              => rdEn(24*1+11),
         fifo_empty_49              => empty(24*1+11),
         -- DATA[3][0]
         data3_0p_23                => dPortDataP(6*1+3)(0),
         data3_0n_24                => dPortDataN(6*1+3)(0),
         data_to_fabric_data3_0p_23 => data(24*1+12),
         rx_ce_23                   => ce(24*1+12),
         rx_inc_23                  => inc(24*1+12),
         rx_load_23                 => load(24*1+12),
         rx_en_vtc_23               => vtc(24*1+12),
         fifo_rd_clk_23             => readClk,
         fifo_rd_en_23              => rdEn(24*1+12),
         fifo_empty_23              => empty(24*1+12),
         -- DATA[3][1]
         data3_1p_21                => dPortDataP(6*1+3)(1),
         data3_1n_22                => dPortDataN(6*1+3)(1),
         data_to_fabric_data3_1p_21 => data(24*1+13),
         rx_ce_21                   => ce(24*1+13),
         rx_inc_21                  => inc(24*1+13),
         rx_load_21                 => load(24*1+13),
         rx_en_vtc_21               => vtc(24*1+13),
         fifo_rd_clk_21             => readClk,
         fifo_rd_en_21              => rdEn(24*1+13),
         fifo_empty_21              => empty(24*1+13),
         -- DATA[3][2]
         data3_2p_19                => dPortDataP(6*1+3)(2),
         data3_2n_20                => dPortDataN(6*1+3)(2),
         data_to_fabric_data3_2p_19 => data(24*1+14),
         rx_ce_19                   => ce(24*1+14),
         rx_inc_19                  => inc(24*1+14),
         rx_load_19                 => load(24*1+14),
         rx_en_vtc_19               => vtc(24*1+14),
         fifo_rd_clk_19             => readClk,
         fifo_rd_en_19              => rdEn(24*1+14),
         fifo_empty_19              => empty(24*1+14),
         -- DATA[3][3]
         data3_3p_17                => dPortDataP(6*1+3)(3),
         data3_3n_18                => dPortDataN(6*1+3)(3),
         data_to_fabric_data3_3p_17 => data(24*1+15),
         rx_ce_17                   => ce(24*1+15),
         rx_inc_17                  => inc(24*1+15),
         rx_load_17                 => load(24*1+15),
         rx_en_vtc_17               => vtc(24*1+15),
         fifo_rd_clk_17             => readClk,
         fifo_rd_en_17              => rdEn(24*1+15),
         fifo_empty_17              => empty(24*1+15),
         -- DATA[4][0]
         data4_0p_15                => dPortDataP(6*1+4)(0),
         data4_0n_16                => dPortDataN(6*1+4)(0),
         data_to_fabric_data4_0p_15 => data(24*1+16),
         rx_ce_15                   => ce(24*1+16),
         rx_inc_15                  => inc(24*1+16),
         rx_load_15                 => load(24*1+16),
         rx_en_vtc_15               => vtc(24*1+16),
         fifo_rd_clk_15             => readClk,
         fifo_rd_en_15              => rdEn(24*1+16),
         fifo_empty_15              => empty(24*1+16),
         -- DATA[4][1]
         data4_1p_13                => dPortDataP(6*1+4)(1),
         data4_1n_14                => dPortDataN(6*1+4)(1),
         data_to_fabric_data4_1p_13 => data(24*1+17),
         rx_ce_13                   => ce(24*1+17),
         rx_inc_13                  => inc(24*1+17),
         rx_load_13                 => load(24*1+17),
         rx_en_vtc_13               => vtc(24*1+17),
         fifo_rd_clk_13             => readClk,
         fifo_rd_en_13              => rdEn(24*1+17),
         fifo_empty_13              => empty(24*1+17),
         -- DATA[4][2]
         data4_2p_10                => dPortDataP(6*1+4)(2),
         data4_2n_11                => dPortDataN(6*1+4)(2),
         data_to_fabric_data4_2p_10 => data(24*1+18),
         rx_ce_10                   => ce(24*1+18),
         rx_inc_10                  => inc(24*1+18),
         rx_load_10                 => load(24*1+18),
         rx_en_vtc_10               => vtc(24*1+18),
         fifo_rd_clk_10             => readClk,
         fifo_rd_en_10              => rdEn(24*1+18),
         fifo_empty_10              => empty(24*1+18),
         -- DATA[4][3]
         data4_3p_8                 => dPortDataP(6*1+4)(3),
         data4_3n_9                 => dPortDataN(6*1+4)(3),
         data_to_fabric_data4_3p_8  => data(24*1+19),
         rx_ce_8                    => ce(24*1+19),
         rx_inc_8                   => inc(24*1+19),
         rx_load_8                  => load(24*1+19),
         rx_en_vtc_8                => vtc(24*1+19),
         fifo_rd_clk_8              => readClk,
         fifo_rd_en_8               => rdEn(24*1+19),
         fifo_empty_8               => empty(24*1+19),
         -- DATA[5][0]
         data5_0p_6                 => dPortDataP(6*1+5)(0),
         data5_0n_7                 => dPortDataN(6*1+5)(0),
         data_to_fabric_data5_0p_6  => data(24*1+20),
         rx_ce_6                    => ce(24*1+20),
         rx_inc_6                   => inc(24*1+20),
         rx_load_6                  => load(24*1+20),
         rx_en_vtc_6                => vtc(24*1+20),
         fifo_rd_clk_6              => readClk,
         fifo_rd_en_6               => rdEn(24*1+20),
         fifo_empty_6               => empty(24*1+20),
         -- DATA[5][1]
         data5_1p_4                 => dPortDataP(6*1+5)(1),
         data5_1n_5                 => dPortDataN(6*1+5)(1),
         data_to_fabric_data5_1p_4  => data(24*1+21),
         rx_ce_4                    => ce(24*1+21),
         rx_inc_4                   => inc(24*1+21),
         rx_load_4                  => load(24*1+21),
         rx_en_vtc_4                => vtc(24*1+21),
         fifo_rd_clk_4              => readClk,
         fifo_rd_en_4               => rdEn(24*1+21),
         fifo_empty_4               => empty(24*1+21),
         -- DATA[5][2]
         data5_2p_2                 => dPortDataP(6*1+5)(2),
         data5_2n_3                 => dPortDataN(6*1+5)(2),
         data_to_fabric_data5_2p_2  => data(24*1+22),
         rx_ce_2                    => ce(24*1+22),
         rx_inc_2                   => inc(24*1+22),
         rx_load_2                  => load(24*1+22),
         rx_en_vtc_2                => vtc(24*1+22),
         fifo_rd_clk_2              => readClk,
         fifo_rd_en_2               => rdEn(24*1+22),
         fifo_empty_2               => empty(24*1+22),
         -- DATA[5][3]
         data5_3p_0                 => dPortDataP(6*1+5)(3),
         data5_3n_1                 => dPortDataN(6*1+5)(3),
         data_to_fabric_data5_3p_0  => data(24*1+23),
         rx_ce_0                    => ce(24*1+23),
         rx_inc_0                   => inc(24*1+23),
         rx_load_0                  => load(24*1+23),
         rx_en_vtc_0                => vtc(24*1+23),
         fifo_rd_clk_0              => readClk,
         fifo_rd_en_0               => rdEn(24*1+23),
         fifo_empty_0               => empty(24*1+23));

   U_Bank69 : AtlasRd53HsSelectioBank69
      port map (
         clk                        => ref160Clk,
         rst                        => ref160Rst,
         pll0_locked                => locked(2),
         pll0_clkout0               => clock160MHz(2),
         rx_clk                     => rx_clk(2),
         riu_clk                    => riu_clk(2),
         dly_rdy_bsc0               => dly_rdy_bsc0(2),
         dly_rdy_bsc1               => dly_rdy_bsc1(2),
         dly_rdy_bsc2               => dly_rdy_bsc2(2),
         dly_rdy_bsc3               => dly_rdy_bsc3(2),
         dly_rdy_bsc4               => dly_rdy_bsc4(2),
         dly_rdy_bsc5               => dly_rdy_bsc5(2),
         dly_rdy_bsc6               => dly_rdy_bsc6(2),
         dly_rdy_bsc7               => dly_rdy_bsc7(2),
         rst_seq_done               => rst_seq_done(2),
         shared_pll0_clkoutphy_out  => shared_pll0_clkoutphy_out(2),
         -- DATA[0][0]
         data0_0p_26                => dPortDataP(6*2+0)(0),
         data0_0n_27                => dPortDataN(6*2+0)(0),
         data_to_fabric_data0_0p_26 => data(24*2+0),
         rx_ce_26                   => ce(24*2+0),
         rx_inc_26                  => inc(24*2+0),
         rx_load_26                 => load(24*2+0),
         rx_en_vtc_26               => vtc(24*2+0),
         fifo_rd_clk_26             => readClk,
         fifo_rd_en_26              => rdEn(24*2+0),
         fifo_empty_26              => empty(24*2+0),
         -- DATA[0][1]
         data0_1p_28                => dPortDataP(6*2+0)(1),
         data0_1n_29                => dPortDataN(6*2+0)(1),
         data_to_fabric_data0_1p_28 => data(24*2+1),
         rx_ce_28                   => ce(24*2+1),
         rx_inc_28                  => inc(24*2+1),
         rx_load_28                 => load(24*2+1),
         rx_en_vtc_28               => vtc(24*2+1),
         fifo_rd_clk_28             => readClk,
         fifo_rd_en_28              => rdEn(24*2+1),
         fifo_empty_28              => empty(24*2+1),
         -- DATA[0][2]
         data0_2p_30                => dPortDataP(6*2+0)(2),
         data0_2n_31                => dPortDataN(6*2+0)(2),
         data_to_fabric_data0_2p_30 => data(24*2+2),
         rx_ce_30                   => ce(24*2+2),
         rx_inc_30                  => inc(24*2+2),
         rx_load_30                 => load(24*2+2),
         rx_en_vtc_30               => vtc(24*2+2),
         fifo_rd_clk_30             => readClk,
         fifo_rd_en_30              => rdEn(24*2+2),
         fifo_empty_30              => empty(24*2+2),
         -- DATA[0][3]
         data0_3p_32                => dPortDataP(6*2+0)(3),
         data0_3n_33                => dPortDataN(6*2+0)(3),
         data_to_fabric_data0_3p_32 => data(24*2+3),
         rx_ce_32                   => ce(24*2+3),
         rx_inc_32                  => inc(24*2+3),
         rx_load_32                 => load(24*2+3),
         rx_en_vtc_32               => vtc(24*2+3),
         fifo_rd_clk_32             => readClk,
         fifo_rd_en_32              => rdEn(24*2+3),
         fifo_empty_32              => empty(24*2+3),
         -- DATA[1][0]
         data1_0p_34                => dPortDataP(6*2+1)(0),
         data1_0n_35                => dPortDataN(6*2+1)(0),
         data_to_fabric_data1_0p_34 => data(24*2+4),
         rx_ce_34                   => ce(24*2+4),
         rx_inc_34                  => inc(24*2+4),
         rx_load_34                 => load(24*2+4),
         rx_en_vtc_34               => vtc(24*2+4),
         fifo_rd_clk_34             => readClk,
         fifo_rd_en_34              => rdEn(24*2+4),
         fifo_empty_34              => empty(24*2+4),
         -- DATA[1][1]
         data1_1p_36                => dPortDataP(6*2+1)(1),
         data1_1n_37                => dPortDataN(6*2+1)(1),
         data_to_fabric_data1_1p_36 => data(24*2+5),
         rx_ce_36                   => ce(24*2+5),
         rx_inc_36                  => inc(24*2+5),
         rx_load_36                 => load(24*2+5),
         rx_en_vtc_36               => vtc(24*2+5),
         fifo_rd_clk_36             => readClk,
         fifo_rd_en_36              => rdEn(24*2+5),
         fifo_empty_36              => empty(24*2+5),
         -- DATA[1][2]
         data1_2p_39                => dPortDataP(6*2+1)(2),
         data1_2n_40                => dPortDataN(6*2+1)(2),
         data_to_fabric_data1_2p_39 => data(24*2+6),
         rx_ce_39                   => ce(24*2+6),
         rx_inc_39                  => inc(24*2+6),
         rx_load_39                 => load(24*2+6),
         rx_en_vtc_39               => vtc(24*2+6),
         fifo_rd_clk_39             => readClk,
         fifo_rd_en_39              => rdEn(24*2+6),
         fifo_empty_39              => empty(24*2+6),
         -- DATA[1][3]
         data1_3p_41                => dPortDataP(6*2+1)(3),
         data1_3n_42                => dPortDataN(6*2+1)(3),
         data_to_fabric_data1_3p_41 => data(24*2+7),
         rx_ce_41                   => ce(24*2+7),
         rx_inc_41                  => inc(24*2+7),
         rx_load_41                 => load(24*2+7),
         rx_en_vtc_41               => vtc(24*2+7),
         fifo_rd_clk_41             => readClk,
         fifo_rd_en_41              => rdEn(24*2+7),
         fifo_empty_41              => empty(24*2+7),
         -- DATA[2][0]
         data2_0p_43                => dPortDataP(6*2+2)(0),
         data2_0n_44                => dPortDataN(6*2+2)(0),
         data_to_fabric_data2_0p_43 => data(24*2+8),
         rx_ce_43                   => ce(24*2+8),
         rx_inc_43                  => inc(24*2+8),
         rx_load_43                 => load(24*2+8),
         rx_en_vtc_43               => vtc(24*2+8),
         fifo_rd_clk_43             => readClk,
         fifo_rd_en_43              => rdEn(24*2+8),
         fifo_empty_43              => empty(24*2+8),
         -- DATA[2][1]
         data2_1p_45                => dPortDataP(6*2+2)(1),
         data2_1n_46                => dPortDataN(6*2+2)(1),
         data_to_fabric_data2_1p_45 => data(24*2+9),
         rx_ce_45                   => ce(24*2+9),
         rx_inc_45                  => inc(24*2+9),
         rx_load_45                 => load(24*2+9),
         rx_en_vtc_45               => vtc(24*2+9),
         fifo_rd_clk_45             => readClk,
         fifo_rd_en_45              => rdEn(24*2+9),
         fifo_empty_45              => empty(24*2+9),
         -- DATA[2][2]
         data2_2p_47                => dPortDataP(6*2+2)(2),
         data2_2n_48                => dPortDataN(6*2+2)(2),
         data_to_fabric_data2_2p_47 => data(24*2+10),
         rx_ce_47                   => ce(24*2+10),
         rx_inc_47                  => inc(24*2+10),
         rx_load_47                 => load(24*2+10),
         rx_en_vtc_47               => vtc(24*2+10),
         fifo_rd_clk_47             => readClk,
         fifo_rd_en_47              => rdEn(24*2+10),
         fifo_empty_47              => empty(24*2+10),
         -- DATA[2][3]
         data2_3p_49                => dPortDataP(6*2+2)(3),
         data2_3n_50                => dPortDataN(6*2+2)(3),
         data_to_fabric_data2_3p_49 => data(24*2+11),
         rx_ce_49                   => ce(24*2+11),
         rx_inc_49                  => inc(24*2+11),
         rx_load_49                 => load(24*2+11),
         rx_en_vtc_49               => vtc(24*2+11),
         fifo_rd_clk_49             => readClk,
         fifo_rd_en_49              => rdEn(24*2+11),
         fifo_empty_49              => empty(24*2+11),
         -- DATA[3][0]
         data3_0p_23                => dPortDataP(6*2+3)(0),
         data3_0n_24                => dPortDataN(6*2+3)(0),
         data_to_fabric_data3_0p_23 => data(24*2+12),
         rx_ce_23                   => ce(24*2+12),
         rx_inc_23                  => inc(24*2+12),
         rx_load_23                 => load(24*2+12),
         rx_en_vtc_23               => vtc(24*2+12),
         fifo_rd_clk_23             => readClk,
         fifo_rd_en_23              => rdEn(24*2+12),
         fifo_empty_23              => empty(24*2+12),
         -- DATA[3][1]
         data3_1p_21                => dPortDataP(6*2+3)(1),
         data3_1n_22                => dPortDataN(6*2+3)(1),
         data_to_fabric_data3_1p_21 => data(24*2+13),
         rx_ce_21                   => ce(24*2+13),
         rx_inc_21                  => inc(24*2+13),
         rx_load_21                 => load(24*2+13),
         rx_en_vtc_21               => vtc(24*2+13),
         fifo_rd_clk_21             => readClk,
         fifo_rd_en_21              => rdEn(24*2+13),
         fifo_empty_21              => empty(24*2+13),
         -- DATA[3][2]
         data3_2p_19                => dPortDataP(6*2+3)(2),
         data3_2n_20                => dPortDataN(6*2+3)(2),
         data_to_fabric_data3_2p_19 => data(24*2+14),
         rx_ce_19                   => ce(24*2+14),
         rx_inc_19                  => inc(24*2+14),
         rx_load_19                 => load(24*2+14),
         rx_en_vtc_19               => vtc(24*2+14),
         fifo_rd_clk_19             => readClk,
         fifo_rd_en_19              => rdEn(24*2+14),
         fifo_empty_19              => empty(24*2+14),
         -- DATA[3][3]
         data3_3p_17                => dPortDataP(6*2+3)(3),
         data3_3n_18                => dPortDataN(6*2+3)(3),
         data_to_fabric_data3_3p_17 => data(24*2+15),
         rx_ce_17                   => ce(24*2+15),
         rx_inc_17                  => inc(24*2+15),
         rx_load_17                 => load(24*2+15),
         rx_en_vtc_17               => vtc(24*2+15),
         fifo_rd_clk_17             => readClk,
         fifo_rd_en_17              => rdEn(24*2+15),
         fifo_empty_17              => empty(24*2+15),
         -- DATA[4][0]
         data4_0p_15                => dPortDataP(6*2+4)(0),
         data4_0n_16                => dPortDataN(6*2+4)(0),
         data_to_fabric_data4_0p_15 => data(24*2+16),
         rx_ce_15                   => ce(24*2+16),
         rx_inc_15                  => inc(24*2+16),
         rx_load_15                 => load(24*2+16),
         rx_en_vtc_15               => vtc(24*2+16),
         fifo_rd_clk_15             => readClk,
         fifo_rd_en_15              => rdEn(24*2+16),
         fifo_empty_15              => empty(24*2+16),
         -- DATA[4][1]
         data4_1p_13                => dPortDataP(6*2+4)(1),
         data4_1n_14                => dPortDataN(6*2+4)(1),
         data_to_fabric_data4_1p_13 => data(24*2+17),
         rx_ce_13                   => ce(24*2+17),
         rx_inc_13                  => inc(24*2+17),
         rx_load_13                 => load(24*2+17),
         rx_en_vtc_13               => vtc(24*2+17),
         fifo_rd_clk_13             => readClk,
         fifo_rd_en_13              => rdEn(24*2+17),
         fifo_empty_13              => empty(24*2+17),
         -- DATA[4][2]
         data4_2p_10                => dPortDataP(6*2+4)(2),
         data4_2n_11                => dPortDataN(6*2+4)(2),
         data_to_fabric_data4_2p_10 => data(24*2+18),
         rx_ce_10                   => ce(24*2+18),
         rx_inc_10                  => inc(24*2+18),
         rx_load_10                 => load(24*2+18),
         rx_en_vtc_10               => vtc(24*2+18),
         fifo_rd_clk_10             => readClk,
         fifo_rd_en_10              => rdEn(24*2+18),
         fifo_empty_10              => empty(24*2+18),
         -- DATA[4][3]
         data4_3p_8                 => dPortDataP(6*2+4)(3),
         data4_3n_9                 => dPortDataN(6*2+4)(3),
         data_to_fabric_data4_3p_8  => data(24*2+19),
         rx_ce_8                    => ce(24*2+19),
         rx_inc_8                   => inc(24*2+19),
         rx_load_8                  => load(24*2+19),
         rx_en_vtc_8                => vtc(24*2+19),
         fifo_rd_clk_8              => readClk,
         fifo_rd_en_8               => rdEn(24*2+19),
         fifo_empty_8               => empty(24*2+19),
         -- DATA[5][0]
         data5_0p_6                 => dPortDataP(6*2+5)(0),
         data5_0n_7                 => dPortDataN(6*2+5)(0),
         data_to_fabric_data5_0p_6  => data(24*2+20),
         rx_ce_6                    => ce(24*2+20),
         rx_inc_6                   => inc(24*2+20),
         rx_load_6                  => load(24*2+20),
         rx_en_vtc_6                => vtc(24*2+20),
         fifo_rd_clk_6              => readClk,
         fifo_rd_en_6               => rdEn(24*2+20),
         fifo_empty_6               => empty(24*2+20),
         -- DATA[5][1]
         data5_1p_4                 => dPortDataP(6*2+5)(1),
         data5_1n_5                 => dPortDataN(6*2+5)(1),
         data_to_fabric_data5_1p_4  => data(24*2+21),
         rx_ce_4                    => ce(24*2+21),
         rx_inc_4                   => inc(24*2+21),
         rx_load_4                  => load(24*2+21),
         rx_en_vtc_4                => vtc(24*2+21),
         fifo_rd_clk_4              => readClk,
         fifo_rd_en_4               => rdEn(24*2+21),
         fifo_empty_4               => empty(24*2+21),
         -- DATA[5][2]
         data5_2p_2                 => dPortDataP(6*2+5)(2),
         data5_2n_3                 => dPortDataN(6*2+5)(2),
         data_to_fabric_data5_2p_2  => data(24*2+22),
         rx_ce_2                    => ce(24*2+22),
         rx_inc_2                   => inc(24*2+22),
         rx_load_2                  => load(24*2+22),
         rx_en_vtc_2                => vtc(24*2+22),
         fifo_rd_clk_2              => readClk,
         fifo_rd_en_2               => rdEn(24*2+22),
         fifo_empty_2               => empty(24*2+22),
         -- DATA[5][3]
         data5_3p_0                 => dPortDataP(6*2+5)(3),
         data5_3n_1                 => dPortDataN(6*2+5)(3),
         data_to_fabric_data5_3p_0  => data(24*2+23),
         rx_ce_0                    => ce(24*2+23),
         rx_inc_0                   => inc(24*2+23),
         rx_load_0                  => load(24*2+23),
         rx_en_vtc_0                => vtc(24*2+23),
         fifo_rd_clk_0              => readClk,
         fifo_rd_en_0               => rdEn(24*2+23),
         fifo_empty_0               => empty(24*2+23));

   U_Bank68 : AtlasRd53HsSelectioBank68
      port map (
         clk                        => ref160Clk,
         rst                        => ref160Rst,
         pll0_locked                => locked(3),
         pll0_clkout0               => clock160MHz(3),
         rx_clk                     => rx_clk(3),
         riu_clk                    => riu_clk(3),
         dly_rdy_bsc0               => dly_rdy_bsc0(3),
         dly_rdy_bsc1               => dly_rdy_bsc1(3),
         dly_rdy_bsc2               => dly_rdy_bsc2(3),
         dly_rdy_bsc3               => dly_rdy_bsc3(3),
         dly_rdy_bsc4               => dly_rdy_bsc4(3),
         dly_rdy_bsc5               => dly_rdy_bsc5(3),
         dly_rdy_bsc6               => dly_rdy_bsc6(3),
         dly_rdy_bsc7               => dly_rdy_bsc7(3),
         rst_seq_done               => rst_seq_done(3),
         shared_pll0_clkoutphy_out  => shared_pll0_clkoutphy_out(3),
         -- DATA[0][0]
         data0_0p_26                => dPortDataP(6*3+0)(0),
         data0_0n_27                => dPortDataN(6*3+0)(0),
         data_to_fabric_data0_0p_26 => data(24*3+0),
         rx_ce_26                   => ce(24*3+0),
         rx_inc_26                  => inc(24*3+0),
         rx_load_26                 => load(24*3+0),
         rx_en_vtc_26               => vtc(24*3+0),
         fifo_rd_clk_26             => readClk,
         fifo_rd_en_26              => rdEn(24*3+0),
         fifo_empty_26              => empty(24*3+0),
         -- DATA[0][1]
         data0_1p_28                => dPortDataP(6*3+0)(1),
         data0_1n_29                => dPortDataN(6*3+0)(1),
         data_to_fabric_data0_1p_28 => data(24*3+1),
         rx_ce_28                   => ce(24*3+1),
         rx_inc_28                  => inc(24*3+1),
         rx_load_28                 => load(24*3+1),
         rx_en_vtc_28               => vtc(24*3+1),
         fifo_rd_clk_28             => readClk,
         fifo_rd_en_28              => rdEn(24*3+1),
         fifo_empty_28              => empty(24*3+1),
         -- DATA[0][2]
         data0_2p_30                => dPortDataP(6*3+0)(2),
         data0_2n_31                => dPortDataN(6*3+0)(2),
         data_to_fabric_data0_2p_30 => data(24*3+2),
         rx_ce_30                   => ce(24*3+2),
         rx_inc_30                  => inc(24*3+2),
         rx_load_30                 => load(24*3+2),
         rx_en_vtc_30               => vtc(24*3+2),
         fifo_rd_clk_30             => readClk,
         fifo_rd_en_30              => rdEn(24*3+2),
         fifo_empty_30              => empty(24*3+2),
         -- DATA[0][3]
         data0_3p_32                => dPortDataP(6*3+0)(3),
         data0_3n_33                => dPortDataN(6*3+0)(3),
         data_to_fabric_data0_3p_32 => data(24*3+3),
         rx_ce_32                   => ce(24*3+3),
         rx_inc_32                  => inc(24*3+3),
         rx_load_32                 => load(24*3+3),
         rx_en_vtc_32               => vtc(24*3+3),
         fifo_rd_clk_32             => readClk,
         fifo_rd_en_32              => rdEn(24*3+3),
         fifo_empty_32              => empty(24*3+3),
         -- DATA[1][0]
         data1_0p_34                => dPortDataP(6*3+1)(0),
         data1_0n_35                => dPortDataN(6*3+1)(0),
         data_to_fabric_data1_0p_34 => data(24*3+4),
         rx_ce_34                   => ce(24*3+4),
         rx_inc_34                  => inc(24*3+4),
         rx_load_34                 => load(24*3+4),
         rx_en_vtc_34               => vtc(24*3+4),
         fifo_rd_clk_34             => readClk,
         fifo_rd_en_34              => rdEn(24*3+4),
         fifo_empty_34              => empty(24*3+4),
         -- DATA[1][1]
         data1_1p_36                => dPortDataP(6*3+1)(1),
         data1_1n_37                => dPortDataN(6*3+1)(1),
         data_to_fabric_data1_1p_36 => data(24*3+5),
         rx_ce_36                   => ce(24*3+5),
         rx_inc_36                  => inc(24*3+5),
         rx_load_36                 => load(24*3+5),
         rx_en_vtc_36               => vtc(24*3+5),
         fifo_rd_clk_36             => readClk,
         fifo_rd_en_36              => rdEn(24*3+5),
         fifo_empty_36              => empty(24*3+5),
         -- DATA[1][2]
         data1_2p_39                => dPortDataP(6*3+1)(2),
         data1_2n_40                => dPortDataN(6*3+1)(2),
         data_to_fabric_data1_2p_39 => data(24*3+6),
         rx_ce_39                   => ce(24*3+6),
         rx_inc_39                  => inc(24*3+6),
         rx_load_39                 => load(24*3+6),
         rx_en_vtc_39               => vtc(24*3+6),
         fifo_rd_clk_39             => readClk,
         fifo_rd_en_39              => rdEn(24*3+6),
         fifo_empty_39              => empty(24*3+6),
         -- DATA[1][3]
         data1_3p_41                => dPortDataP(6*3+1)(3),
         data1_3n_42                => dPortDataN(6*3+1)(3),
         data_to_fabric_data1_3p_41 => data(24*3+7),
         rx_ce_41                   => ce(24*3+7),
         rx_inc_41                  => inc(24*3+7),
         rx_load_41                 => load(24*3+7),
         rx_en_vtc_41               => vtc(24*3+7),
         fifo_rd_clk_41             => readClk,
         fifo_rd_en_41              => rdEn(24*3+7),
         fifo_empty_41              => empty(24*3+7),
         -- DATA[2][0]
         data2_0p_43                => dPortDataP(6*3+2)(0),
         data2_0n_44                => dPortDataN(6*3+2)(0),
         data_to_fabric_data2_0p_43 => data(24*3+8),
         rx_ce_43                   => ce(24*3+8),
         rx_inc_43                  => inc(24*3+8),
         rx_load_43                 => load(24*3+8),
         rx_en_vtc_43               => vtc(24*3+8),
         fifo_rd_clk_43             => readClk,
         fifo_rd_en_43              => rdEn(24*3+8),
         fifo_empty_43              => empty(24*3+8),
         -- DATA[2][1]
         data2_1p_45                => dPortDataP(6*3+2)(1),
         data2_1n_46                => dPortDataN(6*3+2)(1),
         data_to_fabric_data2_1p_45 => data(24*3+9),
         rx_ce_45                   => ce(24*3+9),
         rx_inc_45                  => inc(24*3+9),
         rx_load_45                 => load(24*3+9),
         rx_en_vtc_45               => vtc(24*3+9),
         fifo_rd_clk_45             => readClk,
         fifo_rd_en_45              => rdEn(24*3+9),
         fifo_empty_45              => empty(24*3+9),
         -- DATA[2][2]
         data2_2p_47                => dPortDataP(6*3+2)(2),
         data2_2n_48                => dPortDataN(6*3+2)(2),
         data_to_fabric_data2_2p_47 => data(24*3+10),
         rx_ce_47                   => ce(24*3+10),
         rx_inc_47                  => inc(24*3+10),
         rx_load_47                 => load(24*3+10),
         rx_en_vtc_47               => vtc(24*3+10),
         fifo_rd_clk_47             => readClk,
         fifo_rd_en_47              => rdEn(24*3+10),
         fifo_empty_47              => empty(24*3+10),
         -- DATA[2][3]
         data2_3p_49                => dPortDataP(6*3+2)(3),
         data2_3n_50                => dPortDataN(6*3+2)(3),
         data_to_fabric_data2_3p_49 => data(24*3+11),
         rx_ce_49                   => ce(24*3+11),
         rx_inc_49                  => inc(24*3+11),
         rx_load_49                 => load(24*3+11),
         rx_en_vtc_49               => vtc(24*3+11),
         fifo_rd_clk_49             => readClk,
         fifo_rd_en_49              => rdEn(24*3+11),
         fifo_empty_49              => empty(24*3+11),
         -- DATA[3][0]
         data3_0p_23                => dPortDataP(6*3+3)(0),
         data3_0n_24                => dPortDataN(6*3+3)(0),
         data_to_fabric_data3_0p_23 => data(24*3+12),
         rx_ce_23                   => ce(24*3+12),
         rx_inc_23                  => inc(24*3+12),
         rx_load_23                 => load(24*3+12),
         rx_en_vtc_23               => vtc(24*3+12),
         fifo_rd_clk_23             => readClk,
         fifo_rd_en_23              => rdEn(24*3+12),
         fifo_empty_23              => empty(24*3+12),
         -- DATA[3][1]
         data3_1p_21                => dPortDataP(6*3+3)(1),
         data3_1n_22                => dPortDataN(6*3+3)(1),
         data_to_fabric_data3_1p_21 => data(24*3+13),
         rx_ce_21                   => ce(24*3+13),
         rx_inc_21                  => inc(24*3+13),
         rx_load_21                 => load(24*3+13),
         rx_en_vtc_21               => vtc(24*3+13),
         fifo_rd_clk_21             => readClk,
         fifo_rd_en_21              => rdEn(24*3+13),
         fifo_empty_21              => empty(24*3+13),
         -- DATA[3][2]
         data3_2p_19                => dPortDataP(6*3+3)(2),
         data3_2n_20                => dPortDataN(6*3+3)(2),
         data_to_fabric_data3_2p_19 => data(24*3+14),
         rx_ce_19                   => ce(24*3+14),
         rx_inc_19                  => inc(24*3+14),
         rx_load_19                 => load(24*3+14),
         rx_en_vtc_19               => vtc(24*3+14),
         fifo_rd_clk_19             => readClk,
         fifo_rd_en_19              => rdEn(24*3+14),
         fifo_empty_19              => empty(24*3+14),
         -- DATA[3][3]
         data3_3p_17                => dPortDataP(6*3+3)(3),
         data3_3n_18                => dPortDataN(6*3+3)(3),
         data_to_fabric_data3_3p_17 => data(24*3+15),
         rx_ce_17                   => ce(24*3+15),
         rx_inc_17                  => inc(24*3+15),
         rx_load_17                 => load(24*3+15),
         rx_en_vtc_17               => vtc(24*3+15),
         fifo_rd_clk_17             => readClk,
         fifo_rd_en_17              => rdEn(24*3+15),
         fifo_empty_17              => empty(24*3+15),
         -- DATA[4][0]
         data4_0p_15                => dPortDataP(6*3+4)(0),
         data4_0n_16                => dPortDataN(6*3+4)(0),
         data_to_fabric_data4_0p_15 => data(24*3+16),
         rx_ce_15                   => ce(24*3+16),
         rx_inc_15                  => inc(24*3+16),
         rx_load_15                 => load(24*3+16),
         rx_en_vtc_15               => vtc(24*3+16),
         fifo_rd_clk_15             => readClk,
         fifo_rd_en_15              => rdEn(24*3+16),
         fifo_empty_15              => empty(24*3+16),
         -- DATA[4][1]
         data4_1p_13                => dPortDataP(6*3+4)(1),
         data4_1n_14                => dPortDataN(6*3+4)(1),
         data_to_fabric_data4_1p_13 => data(24*3+17),
         rx_ce_13                   => ce(24*3+17),
         rx_inc_13                  => inc(24*3+17),
         rx_load_13                 => load(24*3+17),
         rx_en_vtc_13               => vtc(24*3+17),
         fifo_rd_clk_13             => readClk,
         fifo_rd_en_13              => rdEn(24*3+17),
         fifo_empty_13              => empty(24*3+17),
         -- DATA[4][2]
         data4_2p_10                => dPortDataP(6*3+4)(2),
         data4_2n_11                => dPortDataN(6*3+4)(2),
         data_to_fabric_data4_2p_10 => data(24*3+18),
         rx_ce_10                   => ce(24*3+18),
         rx_inc_10                  => inc(24*3+18),
         rx_load_10                 => load(24*3+18),
         rx_en_vtc_10               => vtc(24*3+18),
         fifo_rd_clk_10             => readClk,
         fifo_rd_en_10              => rdEn(24*3+18),
         fifo_empty_10              => empty(24*3+18),
         -- DATA[4][3]
         data4_3p_8                 => dPortDataP(6*3+4)(3),
         data4_3n_9                 => dPortDataN(6*3+4)(3),
         data_to_fabric_data4_3p_8  => data(24*3+19),
         rx_ce_8                    => ce(24*3+19),
         rx_inc_8                   => inc(24*3+19),
         rx_load_8                  => load(24*3+19),
         rx_en_vtc_8                => vtc(24*3+19),
         fifo_rd_clk_8              => readClk,
         fifo_rd_en_8               => rdEn(24*3+19),
         fifo_empty_8               => empty(24*3+19),
         -- DATA[5][0]
         data5_0p_6                 => dPortDataP(6*3+5)(0),
         data5_0n_7                 => dPortDataN(6*3+5)(0),
         data_to_fabric_data5_0p_6  => data(24*3+20),
         rx_ce_6                    => ce(24*3+20),
         rx_inc_6                   => inc(24*3+20),
         rx_load_6                  => load(24*3+20),
         rx_en_vtc_6                => vtc(24*3+20),
         fifo_rd_clk_6              => readClk,
         fifo_rd_en_6               => rdEn(24*3+20),
         fifo_empty_6               => empty(24*3+20),
         -- DATA[5][1]
         data5_1p_4                 => dPortDataP(6*3+5)(1),
         data5_1n_5                 => dPortDataN(6*3+5)(1),
         data_to_fabric_data5_1p_4  => data(24*3+21),
         rx_ce_4                    => ce(24*3+21),
         rx_inc_4                   => inc(24*3+21),
         rx_load_4                  => load(24*3+21),
         rx_en_vtc_4                => vtc(24*3+21),
         fifo_rd_clk_4              => readClk,
         fifo_rd_en_4               => rdEn(24*3+21),
         fifo_empty_4               => empty(24*3+21),
         -- DATA[5][2]
         data5_2p_2                 => dPortDataP(6*3+5)(2),
         data5_2n_3                 => dPortDataN(6*3+5)(2),
         data_to_fabric_data5_2p_2  => data(24*3+22),
         rx_ce_2                    => ce(24*3+22),
         rx_inc_2                   => inc(24*3+22),
         rx_load_2                  => load(24*3+22),
         rx_en_vtc_2                => vtc(24*3+22),
         fifo_rd_clk_2              => readClk,
         fifo_rd_en_2               => rdEn(24*3+22),
         fifo_empty_2               => empty(24*3+22),
         -- DATA[5][3]
         data5_3p_0                 => dPortDataP(6*3+5)(3),
         data5_3n_1                 => dPortDataN(6*3+5)(3),
         data_to_fabric_data5_3p_0  => data(24*3+23),
         rx_ce_0                    => ce(24*3+23),
         rx_inc_0                   => inc(24*3+23),
         rx_load_0                  => load(24*3+23),
         rx_en_vtc_0                => vtc(24*3+23),
         fifo_rd_clk_0              => readClk,
         fifo_rd_en_0               => rdEn(24*3+23),
         fifo_empty_0               => empty(24*3+23));

   -- SIM_TEST :
   -- for i in 23 downto 0 generate
   -- SIM_CH :
   -- for j in 3 downto 0 generate
   -- U_ISERDES : ISERDESE3
   -- generic map (
   -- DATA_WIDTH        => 8,
   -- FIFO_ENABLE       => "TRUE",
   -- FIFO_SYNC_MODE    => "FALSE",
   -- IS_CLK_B_INVERTED => '1',
   -- IS_CLK_INVERTED   => '0',
   -- IS_RST_INVERTED   => '0',
   -- SIM_DEVICE        => "ULTRASCALE_PLUS")
   -- port map (
   -- D           => dPortDataP(i)(j),
   -- Q           => test(4*i+j),
   -- CLK         => shared_pll0_clkoutphy_out(0),
   -- CLK_B       => shared_pll0_clkoutphy_out(0),
   -- CLKDIV      => clock160MHz(0),
   -- RST         => reset160MHz(0),
   -- FIFO_RD_CLK => clock160MHz(0),
   -- FIFO_RD_EN  => '1',
   -- FIFO_EMPTY  => open);
   -- end generate SIM_CH;
   -- end generate SIM_TEST;

end mapping;
