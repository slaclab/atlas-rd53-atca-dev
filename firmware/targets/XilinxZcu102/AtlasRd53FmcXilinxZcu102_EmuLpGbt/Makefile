export GEN_BIN_IMAGE = 1
export TIG_PULSE = 1

# Define target output
target: bit

# Define target part
export PRJ_PART = XCZU9EG-FFVB1156-2-E

# Using a non-standard target directory structure, 
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/../../..)

# Use top level makefile
include $(TOP_DIR)/targets/shared_config.mk
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk
