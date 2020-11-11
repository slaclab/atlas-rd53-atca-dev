# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/lpgbt
loadRuckusTcl $::env(TOP_DIR)/common

# Load local source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -path "$::env(TOP_DIR)/submodules/rce-gen3-fw-lib/XilinxZcu102Core/xdc/XilinxZcu102Core.xdc"
loadConstraints -dir  "$::DIR_PATH/hdl"

# Load the simulation testbed
set_property top {LpGbt2EmuLpGbt_LinkingWithGthTb} [get_filesets sim_1]
# set_property top {AtlasRd53HsSelectioWrapperTb} [get_filesets sim_1]

# Remove out of scope .XDC files
remove_files [get_files xlx_ku_mgt_ip_10g24_example_top.xdc]
remove_files [get_files xlx_ku_mgt_ip_10g24.xdc]

set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
