# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/lpgbt
loadRuckusTcl $::env(TOP_DIR)/common
loadRuckusTcl $::DIR_PATH/../shared

# Load local source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -path "$::env(TOP_DIR)/submodules/rce-gen3-fw-lib/XilinxZcu102Core/xdc/XilinxZcu102Core.xdc"
loadConstraints -dir  "$::DIR_PATH/hdl"
