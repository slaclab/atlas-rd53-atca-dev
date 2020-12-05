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

# Open the synthesis design
open_run synth_1

#############################################################################################

set ilaName u_ila_downlink
CreateDebugCore ${ilaName}
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]
SetDebugCoreClk ${ilaName} {U_EMU_LP_GBT/donwlinkClk}

ConfigProbe ${ilaName} {U_EMU_LP_GBT/downlinkUserData[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/downlinkData[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/downlinkEcData[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/downlinkIcData[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/downlinkReady}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/downlinkRst}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/downlinkClkEn}

WriteDebugProbes ${ilaName}

#############################################################################################

set ilaName u_ila_uplink
CreateDebugCore ${ilaName}
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]
SetDebugCoreClk ${ilaName} {U_EMU_LP_GBT/uplinkClk}

ConfigProbe ${ilaName} {U_EMU_LP_GBT/uplinkUserData[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/uplinkEcData[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/uplinkIcData[*]}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/uplinkReady}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/uplinkRst}
ConfigProbe ${ilaName} {U_EMU_LP_GBT/uplinkClkEn}

WriteDebugProbes ${ilaName}

#############################################################################################
