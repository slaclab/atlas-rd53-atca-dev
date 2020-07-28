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

class AtlasRd53HsSelectioWrapper(pr.Device):

    def __init__(self,
            **kwargs):
        super().__init__(**kwargs)

        remapEnum = [[] for _ in range(128)]
        for i in range(128):
            if (i<96):
                remapEnum[i] = f'Ch{i}'
            else:
                remapEnum[i] = f'Disabled{i}'

        for i in range(128):
            self.add(pr.RemoteVariable(
                name         = f'PhyToApp[{i}]',
                description  = 'Sets the APP lane output based on PHY input index',
                offset       = 4*i,
                bitSize      = 7,
                bitOffset    = 0,
                mode         = 'RW',
                enum         = dict(zip(range(128), remapEnum)),
            ))
        for i in range(128):
            self.add(pr.RemoteVariable(
                name         = f'AppToPhy[{i}]',
                description  = 'Sets the PHY lane output based on APP input index',
                offset       = 4*i,
                bitSize      = 7,
                bitOffset    = 7,
                mode         = 'RW',
                enum         = dict(zip(range(128), remapEnum)),
            ))
