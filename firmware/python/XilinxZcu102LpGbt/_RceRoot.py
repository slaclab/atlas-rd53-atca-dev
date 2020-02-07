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

import rogue
import rogue.hardware.axi

rogue.Version.minVersion('4.7.0') 

class RceRoot(pr.Root):

    def __init__(self,
            **kwargs):
        super().__init__(**kwargs)
        
        # Init local variables
        self._Dma  = [[None for elink in range(6)] for sfp in range(4)]
        self._Cmd  = [[None for elink in range(6)] for sfp in range(4)]
        self._Data = [[None for elink in range(6)] for sfp in range(4)]
        
        # Create the mmap interface
        self._RceMemMap = rogue.hardware.axi.AxiMemMap('/dev/rce_memmap')
        
        # Add RCE version device
        self.add(rce.RceVersion( 
            description = 'firmware/submodules/rce-gen3-fw-lib/python/RceG3/_RceVersion.py'
            memBase     = self._RceMemMap,
        ))

        # Add Jitter cleaner PLL device
        self.add(silabs.Si5345(      
            name        = 'Pll', 
            description = 'firmware/submodules/surf/python/surf/devices/silabs/_Si5345.py', 
            offset      = (0xB400_0000 + 6*0x0010_0000), 
            memBase     = self._RceMemMap,
        ))  

        # Loop through the SFP links
        for sfp in range(4):
        
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
