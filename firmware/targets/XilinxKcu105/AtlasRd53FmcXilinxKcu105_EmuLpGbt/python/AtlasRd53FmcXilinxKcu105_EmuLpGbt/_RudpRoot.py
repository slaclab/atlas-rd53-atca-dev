#!/usr/bin/env python3
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
import AtlasRd53           as rd53Lib # firmware/submodules/atlas-rd53-fw-lib
import surf.axi            as axi     # firmware/submodules/surf
import surf.devices.silabs as silabs  # firmware/submodules/surf
import surf.devices.nxp    as nxp     # firmware/submodules/surf
import surf.devices.ti     as ti      # firmware/submodules/surf

import rogue
import rogue.hardware.axi

rogue.Version.minVersion('4.7.0') 

class RudpRoot(pr.Root):

    def __init__(self,
            ip = '192.168.2.10',
            **kwargs):
        super().__init__(**kwargs)
        
        # Create the RUDP connection and map SRP to DEST[0]
        self._Rudp = pr.protocols.UdpRssiPack(
            host    = ip,
            port    = 8192,
            packVer = 2,
        )          
        self._RudpSrp = self.rudpSrp.application(0)
                
        # Connect the SRPv3 streams
        self._srp = rogue.protocols.srp.SrpV3()
        self._RudpSrp == self._srp
        
        # Add the AxiVersion device
        self.add(axi.AxiVersion(
            description = 'firmware/submodules/surf/python/surf/axi/_AxiVersion.py', 
            offset      = (0*0x0001_0000), 
            memBase     = self._srp,
        ))         
        
        # Add Jitter cleaner PLL device
        self.add(silabs.Si5345(      
            name        = 'Pll[0]', 
            description = 'firmware/submodules/surf/python/surf/devices/silabs/_Si5345.py: FMC_HPC', 
            offset      = (1*0x0001_0000), 
            memBase     = self._srp,
        ))          
        
        self.add(silabs.Si5345(      
            name        = 'Pll[1]', 
            description = 'firmware/submodules/surf/python/surf/devices/silabs/_Si5345.py: FMC_LPC', 
            offset      = (2*0x0001_0000), 
            memBase     = self._srp,
        ))                  
        
        # Add I2C GPIO device
        self.add(nxp.Pca9506(      
            name        = 'Gpio', 
            description = 'firmware/submodules/surf/python/surf/devices/nxp/_Pca9506.py', 
            offset      = (3*0x0001_0000 + 0*0x0000_0400), 
            memBase     = self._srp,
        ))          
        
        # Add LMK61E2 device
        self.add(ti.Lmk61e2(      
            name        = 'Lmk', 
            description = 'firmware/submodules/surf/python/surf/devices/ti/_Lmk61e2.py', 
            offset      = (4*0x0001_0000 + 1*0x0000_0400), 
            memBase     = self._srp,
        ))           
