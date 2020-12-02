##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ATLAS RD53 FMC DEV', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports {fmcHpc1LaP[0] fmcHpc1LaN[0]}]; # PLL_CLK_IN[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports {fmcHpc1LaP[1] fmcHpc1LaN[1]}]; # PLL_CLK_IN[1]
set_property -dict { IOSTANDARD LVDS }                [get_ports {fmcHpc1LaP[2] fmcHpc1LaN[2]}]; # PLL_CLK_OUT

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpc1LaP[5] fmcHpc1LaN[5]}]; #  CMD[0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[6] fmcHpc1LaN[6]}];   # DATA[0][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[7] fmcHpc1LaN[7]}];   # DATA[0][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[8] fmcHpc1LaN[8]}];   # DATA[0][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[9] fmcHpc1LaN[9]}];   # DATA[0][3]

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpc1LaP[10] fmcHpc1LaN[10]}]; #  CMD[1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[11] fmcHpc1LaN[11]}]; # DATA[1][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[12] fmcHpc1LaN[12]}]; # DATA[1][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[13] fmcHpc1LaN[13]}]; # DATA[1][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[14] fmcHpc1LaN[14]}]; # DATA[1][3]

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpc1LaP[15] fmcHpc1LaN[15]}]; #  CMD[2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[16] fmcHpc1LaN[16]}]; # DATA[2][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[17] fmcHpc1LaN[17]}]; # DATA[2][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[18] fmcHpc1LaN[18]}]; # DATA[2][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[19] fmcHpc1LaN[19]}]; # DATA[2][3]

set_property -dict { IOSTANDARD LVDS } [get_ports {fmcHpc1LaP[20] fmcHpc1LaN[20]}]; #  CMD[3]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[21] fmcHpc1LaN[21]}]; # DATA[3][0]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[22] fmcHpc1LaN[22]}]; # DATA[3][1]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[23] fmcHpc1LaN[23]}]; # DATA[3][2]
set_property -dict { IOSTANDARD LVDS DIFF_TERM_ADV TERM_100 DQS_BIAS TRUE EQUALIZATION EQ_LEVEL0 } [get_ports {fmcHpc1LaP[24] fmcHpc1LaN[24]}]; # DATA[3][3]

set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { fmcHpc1LaP[26] fmcHpc1LaN[26] }]; # TLU_INT
set_property -dict { IOSTANDARD LVDS DIFF_TERM TRUE } [get_ports { fmcHpc1LaP[27] fmcHpc1LaN[27] }]; # TLU_RST

set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc1LaP[28] fmcHpc1LaN[28] }]; # TLU_BSY
set_property -dict { IOSTANDARD LVDS } [get_ports { fmcHpc1LaP[29] fmcHpc1LaN[29] }]; # TLU_TRG_CLK

##############################################################################

set_property PACKAGE_PIN G27 [get_ports { gtRecClk320P }]; # FMC_HPC1_GBTCLK0_M2C_C_P
set_property PACKAGE_PIN G28 [get_ports { gtRecClk320N }]; # FMC_HPC1_GBTCLK0_M2C_C_N

set_property PACKAGE_PIN G8  [get_ports { gtRefClk320P }]; # FMC_HPC0_GBTCLK0_M2C_C_P
set_property PACKAGE_PIN G7  [get_ports { gtRefClk320N }]; # FMC_HPC0_GBTCLK0_M2C_C_N

####################
# Timing Constraints
####################

create_clock -name gtRefClk320P -period 3.118 [get_ports {gtRefClk320P}]
create_clock -name fmcHpc1LaP0  -period 6.237 [get_ports {fmcHpc1LaP[0]}]
create_clock -name fmcHpc1LaP1  -period 6.237 [get_ports {fmcHpc1LaP[1]}]
create_clock -name gtRecClk320P -period 3.118 [get_ports {gtRecClk320P}]
create_clock -name sysClk300P   -period 3.333 [get_ports {sysClk300P}]

create_generated_clock -name clk640MHz [get_pins {U_FmcMapping/U_Selectio/U_Selectio/GEN_REAL.U_PLL/CLKOUT0}]
create_generated_clock -name clk160MHz [get_pins {U_FmcMapping/U_Selectio/U_Selectio/U_Bufg160/O}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_FmcMapping/U_Selectio/U_Selectio/U_Bufg160/O]] -group [get_clocks gtRecClk320P]

set_property CLOCK_DELAY_GROUP RD53_CLK_GRP [get_nets {U_FmcMapping/U_Selectio/U_Selectio/clk160MHz[*]}] [get_nets {U_FmcMapping/U_Selectio/U_Selectio/clk640MHz[*]}]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_FmcMapping/U_Selectio/U_Selectio/U_Bufg160/O]] -group [get_clocks sfpClk156P]
set_clock_groups -asynchronous -group [get_clocks sysClk300P] -group [get_clocks sfpClk156P]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_SmaTxClkout/U_GTH/inst/gen_gtwizard_gthe4_top.sma_tx_clkout_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_FmcMapping/U_Selectio/U_Selectio/U_Bufg160/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_SmaTxClkout/U_GTH/inst/gen_gtwizard_gthe4_top.sma_tx_clkout_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLK}]] -group [get_clocks -of_objects [get_pins U_FmcMapping/U_Selectio/U_Selectio/U_Bufg160/O]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_SmaTxClkout/U_GTH/inst/gen_gtwizard_gthe4_top.sma_tx_clkout_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[1].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_FmcMapping/U_Selectio/U_Selectio/U_Bufg160/O]]
