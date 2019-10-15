##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { IOSTANDARD LVDS } [get_ports { rtmToDpmP[*][12] }]; #  CMD[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][0]  }]; # DATA[0][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][1]  }]; # DATA[0][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][2]  }]; # DATA[0][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][3]  }]; # DATA[0][3]

set_property -dict { IOSTANDARD LVDS } [get_ports { rtmToDpmP[*][13] }]; #  CMD[1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][4]  }]; # DATA[1][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][5]  }]; # DATA[1][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][6]  }]; # DATA[1][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][7]  }]; # DATA[1][3]

set_property -dict { IOSTANDARD LVDS } [get_ports { rtmToDpmP[*][14] }]; #  CMD[2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][8]  }]; # DATA[2][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][9]  }]; # DATA[2][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][10] }]; # DATA[2][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { rtmToDpmP[*][11] }]; # DATA[2][3]

set_property -dict { IOSTANDARD LVDS } [get_ports { dpmToRtmP[*][12] }]; #  CMD[3]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][0]  }]; # DATA[3][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][1]  }]; # DATA[3][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][2]  }]; # DATA[3][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][3]  }]; # DATA[3][3]

set_property -dict { IOSTANDARD LVDS } [get_ports { dpmToRtmP[*][13] }]; #  CMD[4]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][4]  }]; # DATA[4][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][5]  }]; # DATA[4][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][6]  }]; # DATA[4][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][7]  }]; # DATA[4][3]

set_property -dict { IOSTANDARD LVDS } [get_ports { dpmToRtmP[*][14] }]; #  CMD[5]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][8]  }]; # DATA[5][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][9]  }]; # DATA[5][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][10] }]; # DATA[5][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports { dpmToRtmP[*][11] }]; # DATA[5][3]

##############################################################################

####################
# Timing Constraints
####################

create_generated_clock -name clk160MHzPhy0 [get_pins {U_App/U_Selectio/U_Bank66/inst/top_inst/clk_rst_top_inst/clk_scheme_inst/GEN_PLL_IN_IP_USP.plle4_adv_pll0_inst/CLKOUT0}]
create_generated_clock -name clk160MHzPhy1 [get_pins {U_App/U_Selectio/U_Bank71/inst/top_inst/clk_rst_top_inst/clk_scheme_inst/GEN_PLL_IN_IP_USP.plle4_adv_pll0_inst/CLKOUT0}]
create_generated_clock -name clk160MHzPhy2 [get_pins {U_App/U_Selectio/U_Bank69/inst/top_inst/clk_rst_top_inst/clk_scheme_inst/GEN_PLL_IN_IP_USP.plle4_adv_pll0_inst/CLKOUT0}]
create_generated_clock -name clk160MHzPhy3 [get_pins {U_App/U_Selectio/U_Bank68/inst/top_inst/clk_rst_top_inst/clk_scheme_inst/GEN_PLL_IN_IP_USP.plle4_adv_pll0_inst/CLKOUT0}]

set_clock_groups -asynchronous -group [get_clocks {clk160MHzPhy0}] -group [get_clocks {clk160MHzPhy1}] 
set_clock_groups -asynchronous -group [get_clocks {clk160MHzPhy0}] -group [get_clocks {clk160MHzPhy2}] 
set_clock_groups -asynchronous -group [get_clocks {clk160MHzPhy0}] -group [get_clocks {clk160MHzPhy3}] 
