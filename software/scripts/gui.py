#-----------------------------------------------------------------------------
# This file is part of the 'ATLAS RD53 ATCA DEV'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'ATLAS RD53 ATCA DEV', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import sys
import argparse

import setupLibPaths

import pyrogue.gui
import pyrogue.pydm
import rogue

import AtlasRd53FmcXilinxKcu105_EmuLpGbt

#################################################################

# Set the argument parser
parser = argparse.ArgumentParser()

# Convert str to bool
argBool = lambda s: s.lower() in ['true', 't', 'yes', '1']

# Add arguments
parser.add_argument(
    "--ip", 
    type     = str,
    required = True,
    # default  = '192.168.2.10',
    help     = "FPGA IP Address",
)  

parser.add_argument(
    "--platform", 
    type     = str,
    required = False,
    default  = 'LinkAgg',
    help     = "LinkAgg or Kcu105",
)  

# Get the arguments
args = parser.parse_args()

#################################################################

# Select the hardware type
if args.platform == 'kcu1500':
    myRoot = AtlasRd53FmcXilinxKcu105_EmuLpGbt.RudpRoot
else:
    myRoot = AtlasRd53FmcXilinxKcu105_EmuLpGbt.RudpRoot

#################################################################

with myRoot(ip=args.ip) as root:

    pyrogue.pydm.runPyDM(root=root)
    
#################################################################
