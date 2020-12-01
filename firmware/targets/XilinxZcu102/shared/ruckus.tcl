# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load local Source Code and constraints
loadSource      -dir "$::DIR_PATH/rtl"
loadIpCore      -dir "$::DIR_PATH/ip"

# Load the simulation testbed
set_property top {LpGbt2EmuLpGbt_LinkingWithGthTb} [get_filesets sim_1]
# set_property top {AtlasRd53HsSelectioWrapperTb} [get_filesets sim_1]

# Remove out of scope .XDC files
remove_files [get_files xlx_ku_mgt_ip_10g24_emu_example_top.xdc]
remove_files [get_files xlx_ku_mgt_ip_10g24_emu.xdc]

# Remove out of scope .XDC files
remove_files [get_files xlx_ku_mgt_ip_10g24_example_top.xdc]
remove_files [get_files xlx_ku_mgt_ip_10g24.xdc]

set_property strategy Performance_ExplorePostRoutePhysOpt [get_runs impl_1]
