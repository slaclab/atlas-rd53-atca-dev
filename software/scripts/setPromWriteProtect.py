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

##############################################################################################
# Setup the Hardware write protection on the FPGA"s PROM
##############################################################################################
## Note: 
## Status register bits can be read from or written to using READ STATUS REGISTER or
## WRITE STATUS REGISTER commands, respectively. When the status register enable#
## disable bit (bit 7) is set to 1 and W# is driven LOW, the status register non-volatile bits
## become read-only and the WRITE STATUS REGISTER operation will not execute. The
## only way to exit this hardware-protected mode is to drive W# HIGH.
##############################################################################################
## BIT7       = Use WP pin          = '1'    = enabled
## BIT5       = Top#bottom          = '1'    = bottom
## BIT[6,4:2] = BP[3:0]             = "1010" = Sectors 511:0 protected
## BIT1       = Write enable latch  = '0'    = Don't Care (Volatile)
## BIT0       = Write in progress   = '0'    = Don't Care (Volatile)
#define STATUS_REG_CONFIG     0xE8
##############################################################################################

for i in range(len(args.ip)):

    prom = top.Fpga[i].Core.AxiMicronN25Q
    prom.resetFlash()
    time.sleep(0.1)
    prom.setPromStatusReg(0xE8)
    time.sleep(0.1)
    prom.getPromStatusReg()
    time.sleep(0.1)
    if ( prom.getPromStatusReg() != 0xE8 ):
        raise SysTestException( "Failed program FPGA PROM into FSBL hardware-protected mode (0x%x)" % (prom.getPromStatusReg()) )
    
#################################################################

top.stop()
