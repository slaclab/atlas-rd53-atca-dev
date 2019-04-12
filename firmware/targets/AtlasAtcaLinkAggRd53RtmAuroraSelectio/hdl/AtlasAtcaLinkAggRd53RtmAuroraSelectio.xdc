##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { IOSTANDARD LVDS }                        [get_ports { rtmToDpmP[*][12] }]; #  CMD[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][0]  }]; # DATA[0][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][1]  }]; # DATA[0][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][2]  }]; # DATA[0][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][3]  }]; # DATA[0][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { rtmToDpmP[*][13] }]; #  CMD[1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][4]  }]; # DATA[1][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][5]  }]; # DATA[1][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][6]  }]; # DATA[1][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][7]  }]; # DATA[1][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { rtmToDpmP[*][14] }]; #  CMD[2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][8]  }]; # DATA[2][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][9]  }]; # DATA[2][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][10] }]; # DATA[2][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][11] }]; # DATA[2][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { dpmToRtmP[*][12] }]; #  CMD[3]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][0]  }]; # DATA[3][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][1]  }]; # DATA[3][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][2]  }]; # DATA[3][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][3]  }]; # DATA[3][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { dpmToRtmP[*][13] }]; #  CMD[4]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][4]  }]; # DATA[4][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][5]  }]; # DATA[4][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][6]  }]; # DATA[4][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][7]  }]; # DATA[4][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { dpmToRtmP[*][14] }]; #  CMD[5]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][8]  }]; # DATA[5][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][9]  }]; # DATA[5][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][10] }]; # DATA[5][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][11] }]; # DATA[5][3]

##############################################################################

#######################
# Placement Constraints
#######################

create_pblock PBLOCK_RD53_A
add_cells_to_pblock [get_pblocks PBLOCK_RD53_A] [get_cells {U_App/GEN_mDP[0].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_A] [get_cells {U_App/GEN_mDP[1].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_A] [get_cells {U_App/GEN_mDP[2].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_A] [get_cells {U_App/GEN_mDP[3].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_A] [get_cells {U_App/GEN_mDP[4].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_A] [get_cells {U_App/GEN_mDP[5].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
resize_pblock       [get_pblocks PBLOCK_RD53_A] -add {CLOCKREGION_X2Y2:CLOCKREGION_X2Y2}

create_pblock PBLOCK_RD53_B
add_cells_to_pblock [get_pblocks PBLOCK_RD53_B] [get_cells {U_App/GEN_mDP[6].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_B] [get_cells {U_App/GEN_mDP[7].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_B] [get_cells {U_App/GEN_mDP[8].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_B] [get_cells {U_App/GEN_mDP[9].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_B] [get_cells {U_App/GEN_mDP[10].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_B] [get_cells {U_App/GEN_mDP[11].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
resize_pblock       [get_pblocks PBLOCK_RD53_B] -add {CLOCKREGION_X2Y7:CLOCKREGION_X2Y7}

create_pblock PBLOCK_RD53_C
add_cells_to_pblock [get_pblocks PBLOCK_RD53_C] [get_cells {U_App/GEN_mDP[12].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_C] [get_cells {U_App/GEN_mDP[13].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_C] [get_cells {U_App/GEN_mDP[14].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_C] [get_cells {U_App/GEN_mDP[15].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_C] [get_cells {U_App/GEN_mDP[16].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_C] [get_cells {U_App/GEN_mDP[17].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
resize_pblock       [get_pblocks PBLOCK_RD53_C] -add {CLOCKREGION_X2Y5:CLOCKREGION_X2Y5}

create_pblock PBLOCK_RD53_D
add_cells_to_pblock [get_pblocks PBLOCK_RD53_D] [get_cells {U_App/GEN_mDP[18].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_D] [get_cells {U_App/GEN_mDP[19].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_D] [get_cells {U_App/GEN_mDP[20].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_D] [get_cells {U_App/GEN_mDP[21].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_D] [get_cells {U_App/GEN_mDP[22].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
add_cells_to_pblock [get_pblocks PBLOCK_RD53_D] [get_cells {U_App/GEN_mDP[23].U_Core/U_RxPhyLayer/GEN_LANE[*].U_Rx/U_SerDes}]
resize_pblock       [get_pblocks PBLOCK_RD53_D] -add {CLOCKREGION_X2Y4:CLOCKREGION_X2Y4}

set_property LOC PLL_X0Y5  [get_cells {U_App/GEN_PLL[0].U_ClkRst/GEN_REAL.U_PLL}]
set_property LOC PLL_X0Y15 [get_cells {U_App/GEN_PLL[1].U_ClkRst/GEN_REAL.U_PLL}]
set_property LOC PLL_X0Y11 [get_cells {U_App/GEN_PLL[2].U_ClkRst/GEN_REAL.U_PLL}]
set_property LOC PLL_X0Y9  [get_cells {U_App/GEN_PLL[3].U_ClkRst/GEN_REAL.U_PLL}]

####################
# Timing Constraints
####################

create_generated_clock -name clk300MHz [get_pins {U_App/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]

create_generated_clock -name clk640MHz_A [get_pins {U_App/GEN_PLL[0].U_ClkRst/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk640MHz_B [get_pins {U_App/GEN_PLL[1].U_ClkRst/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk640MHz_C [get_pins {U_App/GEN_PLL[2].U_ClkRst/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk640MHz_D [get_pins {U_App/GEN_PLL[3].U_ClkRst/GEN_REAL.U_PLL/CLKOUT0}]

create_generated_clock -name clk160MHz_A [get_pins {U_App/GEN_PLL[0].U_ClkRst/U_Bufg160/O}]
create_generated_clock -name clk160MHz_B [get_pins {U_App/GEN_PLL[1].U_ClkRst/U_Bufg160/O}]
create_generated_clock -name clk160MHz_C [get_pins {U_App/GEN_PLL[2].U_ClkRst/U_Bufg160/O}]
create_generated_clock -name clk160MHz_D [get_pins {U_App/GEN_PLL[3].U_ClkRst/U_Bufg160/O}]

set_clock_groups -asynchronous -group [get_clocks {clk160MHz_A}] -group [get_clocks {clk160MHz_B}] -group [get_clocks {clk160MHz_C}] -group [get_clocks {clk160MHz_D}]

set_property CLOCK_DELAY_GROUP RD53_CLK_A_GRP [get_nets {U_App/GEN_PLL[0].U_ClkRst/clk160MHz[*]}] [get_nets {U_App/GEN_PLL[0].U_ClkRst/clk640MHz[*]}]
set_property CLOCK_DELAY_GROUP RD53_CLK_B_GRP [get_nets {U_App/GEN_PLL[1].U_ClkRst/clk160MHz[*]}] [get_nets {U_App/GEN_PLL[1].U_ClkRst/clk640MHz[*]}]
set_property CLOCK_DELAY_GROUP RD53_CLK_C_GRP [get_nets {U_App/GEN_PLL[2].U_ClkRst/clk160MHz[*]}] [get_nets {U_App/GEN_PLL[2].U_ClkRst/clk640MHz[*]}]
set_property CLOCK_DELAY_GROUP RD53_CLK_D_GRP [get_nets {U_App/GEN_PLL[3].U_ClkRst/clk160MHz[*]}] [get_nets {U_App/GEN_PLL[3].U_ClkRst/clk640MHz[*]}]
