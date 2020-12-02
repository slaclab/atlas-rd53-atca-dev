#-----------------------------------------------------------------------------
# This file is part of the 'ATLAS RD53 ATCA DEV'. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the 'ATLAS RD53 ATCA DEV', including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue             as pr
import RceG3               as rce     # firmware/submodules/rce-gen3-fw-lib
import AtlasRd53           as rd53Lib # firmware/submodules/atlas-rd53-fw-lib
import surf.devices.silabs as silabs  # firmware/submodules/surf
import atlas_rd53_atca_dev as atcaDev

import rogue
import rogue.hardware.axi

rogue.Version.minVersion('4.7.0')

class RceRoot(pr.Root):

    def __init__(self,
            **kwargs):
        super().__init__(**kwargs)

        # Init local variables
        self._Dma    = [[None for elink in range(6+1)] for sfp in range(4)]
        self._Cmd    = [[None for elink in range(6)]   for sfp in range(4)]
        self._CmdAll = [ None for sfp   in range(4)]
        self._Data   = [[None for elink in range(6)]   for sfp in range(4)]

        # Create the mmap interface
        self._RceMemMap = rogue.hardware.axi.AxiMemMap('/dev/rce_memmap')

        # Add RCE version device
        self.add(rce.RceVersion(
            description = 'firmware/submodules/rce-gen3-fw-lib/python/RceG3/_RceVersion.py'
            intOffset   = 0xB0000000, # Internal registers offset (zynq=0x80000000, zynquplus=0xB0000000)
            bsiOffset   = 0xB0010000, # BSI I2C Slave Registers   (zynq=0x84000000, zynquplus=0xB0010000)
            memBase     = self._RceMemMap,
        ))

        # Add Jitter cleaner PLL device
        self.add(silabs.Si5345(
            name        = 'Pll',
            description = 'firmware/submodules/surf/python/surf/devices/silabs/_Si5345.py',
            offset      = (0xB400_0000 + 4*0x0010_0000),
            memBase     = self._RceMemMap,
        ))

        # Add Firmware Trigger LUT device
        self.add(rd53Lib.EmuTimingLut(
            name        = 'EmuTimingLut',
            description = 'firmware/submodules/atlas-rd53-fw-lib/python/AtlasRd53/_EmuTiming.py',
            offset      = (0xB400_0000 + 5*0x0010_0000),
            memBase     = self._RceMemMap,
        ))

        # Add Firmware Trigger FSM device
        self.add(rd53Lib.EmuTimingFsm(
            name        = 'EmuTimingFsm',
            description = 'firmware/submodules/atlas-rd53-fw-lib/python/AtlasRd53/_EmuTiming.py',
            offset      = (0xB400_0000 + 6*0x0010_0000),
            memBase     = self._RceMemMap,
        ))

        # Add SMA TX clock device
        self.add(atcaDev.SmaTxClkout(
            name        = 'SmaTxClkout',
            offset      = (0xB400_0000 + 7*0x0010_0000),
            memBase     = self._RceMemMap,
        ))

        # Loop through the SFP links
        for sfp in range(4):

            # Create DMA[sfp].DEST[6]
            self._dma[sfp][6] = rogue.hardware.axi.AxiStreamDma(f'/dev/axi_stream_dma_{sfp}',6,True)

            # Connect DMA[sfp].DEST[elink] --> CMDAll[sfp] (same CMD on all elinks)
            self._dma[sfp][6] >> self._CmdAll[sfp]

            # Loop through the elinks
            for elink in range(6):

                # Create DMA[sfp].DEST[elink]
                self._dma[sfp][elink] = rogue.hardware.axi.AxiStreamDma(f'/dev/axi_stream_dma_{sfp}',elink,True)

                # Connect DMA[sfp].DEST[elink] --> CMD[sfp][elink]
                self._dma[sfp][elink] >> self._Cmd[sfp][elink]

                # Connect Data[sfp][elink] --> DMA[sfp].DEST[elink]
                self._Data[sfp][elink] >> self._dma[sfp][elink]

                # Add the general purpose RD53 monitor
                self.add(rd53Lib.Ctrl(
                    description = 'firmware/submodules/atlas-rd53-fw-lib/python/AtlasRd53/_Ctrl.py',
                    offset      = (0xB400_0000 + sfp*0x0010_0000 + elink*0x0001_0000),
                    memBase     = self._RceMemMap,
                ))
