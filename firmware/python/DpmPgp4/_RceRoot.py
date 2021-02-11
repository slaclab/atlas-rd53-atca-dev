#-----------------------------------------------------------------------------
# This file is part of the 'ATLAS RD53 ATCA DEV'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'ATLAS RD53 ATCA DEV', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue          as pr
import RceG3            as rce  # firmware/submodules/rce-gen3-fw-lib
import surf.devices.pgp as pgp  # firmware/submodules/surf

import rogue
import rogue.hardware.axi

rogue.Version.minVersion('5.1.2')

class RceRoot(pr.Root):

    def __init__(self,
            **kwargs):
        super().__init__(**kwargs)

        # Init local variables
        self._Dma    = [[None for vc in range(16)] for sfp in range(2)]

        # Create the mmap interface
        self._RceMemMap = rogue.hardware.axi.AxiMemMap('/dev/rce_memmap')

        # Add RCE version device
        self.add(rce.RceVersion(
            description = 'firmware/submodules/rce-gen3-fw-lib/python/RceG3/_RceVersion.py'
            intOffset   = 0x80000000, # Internal registers offset (zynq=0x80000000, zynquplus=0xB0000000)
            bsiOffset   = 0x84000000, # BSI I2C Slave Registers   (zynq=0x84000000, zynquplus=0xB0010000)
            memBase     = self._RceMemMap,
        ))

        # Add the PGP Monitors
        for sfp in range(2):
            self.add(pgp.Pgp4AxiL(
                name    = f'PgpMon[{sfp}]',
                offset  = (0xA000_0000 + sfp*0x0100_0000),
                memBase = self._RceMemMap,
            ))
