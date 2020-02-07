##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

# Get variables and procedures
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# # Bypass the debug chipscope generation
# return


# Open the synthesis design
open_run synth_1

#############################################################################################

set ilaName u_ila_mon
CreateDebugCore ${ilaName}
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]
SetDebugCoreClk ${ilaName} {axilClk}

ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/QPLL_LOCK_i[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_buffbypass_rx_done_out}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_buffbypass_rx_reset_in_s}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_reset_rx_done_out}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_reset_tx_done_out}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_userclk_rx_active_out}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/gtwiz_userclk_tx_active_out}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/MGT_RXREADY_o}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/MGT_RXSlide_i}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/MGT_TXREADY_o}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/MGT_TXRESET_i}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/QPLL_RST_o}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/rx_reset_done_all}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/rxValid}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/lpgbtFpga_top_inst/mgt_inst/txValid}

WriteDebugProbes ${ilaName} 

#############################################################################################