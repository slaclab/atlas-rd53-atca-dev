######################################################################################
# If REMOVE_UNUSED_CODE = 0, all source code is kept after importing to Vivado project
# If REMOVE_UNUSED_CODE = 1, all unused source code is removed from Vivado project
######################################################################################
export REMOVE_UNUSED_CODE = 0

# Define target output
target: bit

# Define target part
export PRJ_PART = XCKU040-FFVA1156-2-E

# Using a non-standard target directory structure,
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../../..)

# Use top level makefile
include $(TOP_DIR)/targets/shared_config.mk
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
