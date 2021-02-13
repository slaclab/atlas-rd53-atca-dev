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

import AtlasAtcaLinkAggRd53Rtm_EmuLpGbt
import AtlasAtcaLinkAggRd53Rtm_Pgp4_6Gbps
import AtlasRd53FmcXilinxDevBoard_EmuLpGbt

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
    help     = "FPGA IP Address",
)

parser.add_argument(
    "--remoteDevice",
    type     = str,
    required = False,
    default  = 'LinkAgg',
    help     = "LinkAggLpGBt or LinkAggPgp or Kcu105 or Zcu102",
)

parser.add_argument(
    "--guiType",
    type     = str,
    required = False,
    default  = 'PyDM',
    help     = "Sets the GUI type (PyDM or PyQt)",
)

parser.add_argument(
    "--pollEn",
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable auto-polling",
)

parser.add_argument(
    "--initRead",
    type     = argBool,
    required = False,
    default  = True,
    help     = "Enable read all variables at start",
)

# Get the arguments
args = parser.parse_args()

#################################################################

# Select the hardware type
if args.remoteDevice == 'LinkAggLpGBt':
    myRoot = AtlasAtcaLinkAggRd53Rtm_EmuLpGbt.RudpRoot

elif args.remoteDevice == 'LinkAggPgp':
    myRoot = AtlasAtcaLinkAggRd53Rtm_Pgp4_6Gbps.RudpRoot

elif args.remoteDevice == 'Kcu105':
    myRoot = AtlasRd53FmcXilinxDevBoard_EmuLpGbt.RudpRoot

elif args.remoteDevice == 'Zcu102':
    myRoot = AtlasRd53FmcXilinxDevBoard_EmuLpGbt.RudpRoot

else:
    raise ValueError("Invalid Remote Device (%s)" % (args.remoteDevice) )

#################################################################

with myRoot(
        ip       =args.ip,
        pollEn   = args.pollEn,
        initRead = args.initRead,
    ) as root:

    ######################
    # Development PyDM GUI
    ######################
    if (args.guiType == 'PyDM'):

        pyrogue.pydm.runPyDM(
            root  = root,
            sizeX = 800,
            sizeY = 800,
        )

    #################
    # Legacy PyQT GUI
    #################
    elif (args.guiType == 'PyQt'):

        # Create GUI
        appTop = pyrogue.gui.application(sys.argv)
        guiTop = pyrogue.gui.GuiTop()
        guiTop.addTree(root)
        guiTop.resize(800, 1000)

        # Run gui
        appTop.exec_()
        root.stop()

    ####################
    # Undefined GUI type
    ####################
    else:
        raise ValueError("Invalid GUI type (%s)" % (args.guiType) )

#################################################################
