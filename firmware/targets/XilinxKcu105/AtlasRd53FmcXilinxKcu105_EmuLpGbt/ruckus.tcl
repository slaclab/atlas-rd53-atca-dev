# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/lpgbt
loadRuckusTcl $::env(TOP_DIR)/common

# Load local source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -path "$::env(TOP_DIR)/submodules/axi-pcie-core/hardware/XilinxKcu105/xdc/XilinxKcu105App.xdc"
loadConstraints -dir  "$::DIR_PATH/hdl"

# Adding the common Si5345 configuration
add_files -norecurse "$::DIR_PATH/pll-config/AtlasRd53FmcXilinxKcu105_EmuLpGbt.mem"

# Load the simulation testbed
set_property top {LpGbt2EmuLpGbt_LinkingWithGthTb} [get_filesets sim_1]
