##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { IOSTANDARD LVDS }                        [get_ports { rtmToDpmP[*][0] }];  #  CMD[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][4] }];  # DATA[0][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][5] }];  # DATA[0][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][6] }];  # DATA[0][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][7] }];  # DATA[0][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { rtmToDpmP[*][1]  }]; #  CMD[1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][8]  }]; # DATA[1][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][9]  }]; # DATA[1][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][10] }]; # DATA[1][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][11] }]; # DATA[1][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { rtmToDpmP[*][2]  }]; #  CMD[2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][12] }]; # DATA[2][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][13] }]; # DATA[2][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][14] }]; # DATA[2][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { rtmToDpmP[*][15] }]; # DATA[2][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { dpmToRtmP[*][0] }];  #  CMD[3]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][4] }];  # DATA[3][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][5] }];  # DATA[3][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][6] }];  # DATA[3][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][7] }];  # DATA[3][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { dpmToRtmP[*][1]  }]; #  CMD[4]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][8]  }]; # DATA[4][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][9]  }]; # DATA[4][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][10] }]; # DATA[4][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][11] }]; # DATA[4][3]

set_property -dict { IOSTANDARD LVDS }                        [get_ports { dpmToRtmP[*][2]  }]; #  CMD[5]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][12] }]; # DATA[5][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][13] }]; # DATA[5][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][14] }]; # DATA[5][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 } [get_ports { dpmToRtmP[*][15] }]; # DATA[5][3]

##############################################################################

####################
# Timing Constraints
####################

create_generated_clock -name clk300MHz [get_pins {U_App/U_Pll/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0}]

create_generated_clock -name clk640MHz [get_pins {U_App/U_Pll/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk160MHz [get_pins {U_App/U_Pll/U_Bufg160/O}]
