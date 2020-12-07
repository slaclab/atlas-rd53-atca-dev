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

class SmaTxClkout(pr.Device):
    def __init__(self,
            **kwargs):
        super().__init__(**kwargs)

        self.add(pr.RemoteVariable(
            name         = 'TxPattern',
            offset       = 0x0,
            bitSize      = 16,
            mode         = 'RW',
        ))
