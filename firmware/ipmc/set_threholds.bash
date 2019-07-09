#!/usr/bin/env bash

###############
# Definitions #
###############
# Output string formats used with 'printf'
STR_FORMAT="%-64s"
STR_TABLE_FORMAT="%-20s %-10s %-30s"

########################
# Function definitions #
########################

# Usage message
usage() {
    echo "usage: $0 -s|--shelfmanager shelfmanager_name -n|--slot slot_number [-h|--help]"
    echo "    -s|--shelfmanager shelfmaneger_name      : name of the crate's shelfmanager"
    echo "    -n|--slot         slot_number            : logical slot number"
    echo "    -h|--help                                : show this message"
    echo
    exit
}

# Send ipmitool command with the passed argument
setIpmiCommand() {
    RET=$(eval ipmitool -I lan -H $SHELFMANAGER -t $IPMB -b 0 -A NONE $1 2> /dev/null)

    # Verify IPMI errors
    if [ "$?" -ne 0 ]; then
        printf "ERROR! ($RET)\n"
    else
        printf "Done\n"
    fi

    sleep 1
}

# Set the sensor thresholds.
#  Argument:
#    $1 : Sensor name (double quotes are added to support names with spaces)
#    $2 : Level ("upper", or "lower")
#    $3 : Limits (lower: "lnr lcr lnc", upper "unc ucr unr")
setSensorThreshold() {
    printf "$STR_TABLE_FORMAT... " "$1" "$2" "$3"
    setIpmiCommand "sensor thresh \"$1\" $2 $3"
}

#############
# Main body #
#############

# Verify inputs arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--shelfmanager)
    SHELFMANAGER="$2"
    shift
    ;;
    -n|--slot)
    SLOT="$2"
    shift
    ;;
    -h|--help)
    usage
    ;;
    *)
    echo
    echo "Unknown option"
    usage
    ;;
esac
shift
done

echo

# Verify mandatory parameters
if [ -z "$SHELFMANAGER" ]; then
    echo "Shelfmanager not defined!"
    usage
fi

if [ -z "$SLOT" ]; then
    echo "Slot number not defined!"
    usage
fi

# Check connection with shelfmanager. Exit on error
printf "$STR_FORMAT" "Checking connection with the shelfmanager..."
if ! ping -c 2 $SHELFMANAGER &> /dev/null ; then
    printf "Shelfmanager unreachable!\n"
    exit
else
    printf "Connection OK!\n"
fi

# Calculate IPMB address based on slot number
IPMB=$(expr 0128 + 2 \* $SLOT)

# Set thresholds
echo
echo "Setting thresholds:"
printf "$STR_TABLE_FORMAT\n" "Sensor" "Level" "Limits"
printf "========================================================\n"
## Temperature
setSensorThreshold "BoardTemp:FPGA"   "upper"  "55       75       85"
setSensorThreshold "JunctionTemp:FPG" "upper"  "70       100      125"
# setSensorThreshold "BoardTemp:AMC0"   "upper"  "55       75       85"
## Current
# setSensorThreshold "AMC 0 +12V Cur"   "upper"  "2.048    2.304    2.560"
setSensorThreshold "FPGA +12V Cur"    "upper"  "10.000    11.000    12.000"
# setSensorThreshold "RTM +12V Cur"     "upper"  "2.048    2.256    2.512"
## Voltage
# setSensorThreshold "AMC 0 +12V ADIN"  "lower"  "10.816   11.008   11.520"
# setSensorThreshold "AMC 0 +12V ADIN"  "upper"  "12.608   13.248   13.504"
setSensorThreshold "FPGA +12V ADIN"   "lower"  "10.816   11.008   11.520"
setSensorThreshold "FPGA +12V ADIN"   "upper"  "12.608   13.248   13.504"
# setSensorThreshold "RTM +12V ADIN"    "lower"  "10.816   11.008   11.520"
# setSensorThreshold "RTM +12V ADIN"    "upper"  "12.608   13.248   13.504"

# Print sensor table
echo
echo "Final sensor list"
echo "=================="
ipmitool -I lan -H $SHELFMANAGER -t $IPMB -b 0 -A NONE sensor list all