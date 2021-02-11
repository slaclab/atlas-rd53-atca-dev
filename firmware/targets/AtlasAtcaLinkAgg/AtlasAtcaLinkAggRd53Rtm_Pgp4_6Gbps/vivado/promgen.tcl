##############################################################################
## This file is part of 'ATLAS ATCA LINK AGG DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ATLAS ATCA LINK AGG DEV', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

# PROM Configurations
set format     "mcs"
set inteface   "SPIx1"
set size       "1024"

# Load bit configuration
set loadbit "up 0x04000000 ${inputFile}"
