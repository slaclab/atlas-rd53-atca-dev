# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-atca-link-agg-fw-lib
loadRuckusTcl $::env(TOP_DIR)/submodules/xvc-udp-debug-bridge

# Load local source Code and constraints
loadSource -dir       "$::DIR_PATH/hdl"
loadConstraints -dir  "$::DIR_PATH/hdl"

if { [llength [get_ips ibert_ultrascale_gty_10Gbps]] == 0 } {
   create_ip -name ibert_ultrascale_gty -vendor xilinx.com -library ip -version 1.3 -module_name ibert_ultrascale_gty_10Gbps
   set_property -dict [list CONFIG.C_SYSCLK_FREQUENCY {156.25} CONFIG.C_SYSCLK_IO_PIN_LOC_N {UNASSIGNED} CONFIG.C_SYSCLK_IO_PIN_LOC_P {UNASSIGNED} CONFIG.C_SYSCLK_IS_DIFF {0} CONFIG.C_SYSCLK_MODE_EXTERNAL {0} CONFIG.C_SYSCLOCK_SOURCE_INT {QUAD130_0} CONFIG.C_RXOUTCLK_GT_LOCATION {QUAD130_0} CONFIG.C_REFCLK_SOURCE_QUAD_3 {MGTREFCLK0_130} CONFIG.C_REFCLK_SOURCE_QUAD_2 {None} CONFIG.C_PROTOCOL_QUAD3 {Custom_1_/_10.3125_Gbps} CONFIG.C_PROTOCOL_QUAD2 {None} CONFIG.C_GT_CORRECT {true} CONFIG.C_PROTOCOL_REFCLK_FREQUENCY_1 {156.25} CONFIG.C_PROTOCOL_MAXLINERATE_1 {10.3125}] [get_ips ibert_ultrascale_gty_10Gbps]
}
