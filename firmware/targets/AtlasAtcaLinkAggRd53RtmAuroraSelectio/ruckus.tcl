# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-atca-link-agg-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/xvc-udp-debug-bridge
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib

# Load local source Code and constraints
loadSource -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/hdl"

set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
