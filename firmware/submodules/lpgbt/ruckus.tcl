# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load Source Code
loadSource -dir "$::DIR_PATH/lpgbt-fpga"
loadSource -dir "$::DIR_PATH/lpgbt-fpga/downlink"
loadSource -dir "$::DIR_PATH/lpgbt-fpga/uplink"
loadSource -dir "$::DIR_PATH/lpgbt-emul"
