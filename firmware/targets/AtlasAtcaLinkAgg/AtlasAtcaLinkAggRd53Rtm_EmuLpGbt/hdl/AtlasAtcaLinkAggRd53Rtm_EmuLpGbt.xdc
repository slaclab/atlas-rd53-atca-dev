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

create_clock -name smaClkP       -period 6.237 [get_ports {smaClkP}]
create_clock -name pllToFpgaClkP -period 6.237 [get_ports {pllToFpgaClkP}]

set_clock_groups -asynchronous -group [get_clocks fabEthRefClkP] -group [get_clocks pllToFpgaClkP]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_Core/U_ClkRst/GEN_REAL.U_PLL/CLKOUT0]] -group [get_clocks pllToFpgaClkP]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_App/U_Selectio/U_Bufg160/O]] -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/U_rx_wordclk/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/U_rx_wordclk/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/xlx_ku_mgt_std_i/inst/gen_gtwizard_gthe4_top.xlx_ku_mgt_ip_10g24_emu_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/U_rx_wordclk/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/xlx_ku_mgt_std_i/inst/gen_gtwizard_gthe4_top.xlx_ku_mgt_ip_10g24_emu_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/xlx_ku_mgt_std_i/inst/gen_gtwizard_gthe4_top.xlx_ku_mgt_ip_10g24_emu_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins {U_App/GEN_SFP[*].U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]]
