#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'Camera link gateway'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'Camera link gateway', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import setupLibPaths
import sys
import argparse
import pyrogue.gui
import common as feb

import time

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

# Add arguments
parser.add_argument(
    "--ip", 
    nargs    ='+',
    required = True,
    help     = "List of IP addresses",
)  

parser.add_argument(
    "--mcs", 
    type     = str,
    required = True,
    help     = "path to mcs file",
)

# Get the arguments
args = parser.parse_args()

#################################################################

# Setup root class
print(args.ip)
top = feb.Top(
    ip       = args.ip,
    pollEn   = False,
    initRead = False,       
)  

#################################################################

for i in range(len(args.ip)):

    # Create useful pointers
    AxiVersion = top.Fpga[i].Core.AxiVersion
    PROM       = top.Fpga[i].Core.AxiMicronN25Q
    
    print ( '###################################################')
    print ( '#                 Old Firmware                    #')
    print ( '###################################################')
    AxiVersion.printStatus()

    # Program the FPGA's PROM
    PROM.LoadMcsFile(args.mcs)

    if(PROM._progDone):
        print('\nReloading FPGA firmware from PROM ....')
        AxiVersion.FpgaReload()
        time.sleep(10)
        print('\nReloading FPGA done')

        print ( '###################################################')
        print ( '#                 New Firmware                    #')
        print ( '###################################################')
        AxiVersion.printStatus()
    else:
        print('Failed to program FPGA')
    
#################################################################

top.stop()
exit()
