# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-atca-link-agg-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/lpgbt
loadRuckusTcl $::env(TOP_DIR)/common

# Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl"
loadConstraints -dir "$::DIR_PATH/hdl"

# Load the simulation testbed
set_property top {LpGbt2EmuLpGbt_LinkingWithoutGthTb} [get_filesets sim_1]

# Adding the common Si5345 configuration
add_files -norecurse "$::DIR_PATH/pll-config/AtlasAtcaLinkAggRd53Rtm_EmuLpGbt.mem"
