#-----------------------------------------------------------------------------
# This file is part of the 'ATLAS RD53 ATCA DEV'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'ATLAS RD53 ATCA DEV', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue as pr
import os

top_level = os.path.realpath(__file__).split('software')[0]

pr.addLibraryPath(top_level+'firmware/submodules/atlas-atca-link-agg-fw-lib/python')
pr.addLibraryPath(top_level+'firmware/submodules/atlas-rd53-fw-lib/python')
pr.addLibraryPath(top_level+'firmware/submodules/surf/python')
pr.addLibraryPath(top_level+'firmware/python')
# pr.addLibraryPath(top_level+'software/python')
