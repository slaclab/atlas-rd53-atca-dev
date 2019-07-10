#!/usr/bin/env python3
##############################################################################
## This file is part of 'ATLAS ALTIROC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS ALTIROC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

import rogue
import rogue.hardware.axi
import rogue.utilities.fileio

import pyrogue
import pyrogue as pr
import pyrogue.protocols
import pyrogue.utilities.fileio
import pyrogue.interfaces.simulation

import common
import time
import click

class Top(pr.Root):
    def __init__(   self,       
            name        = 'Top',
            description = 'Container for FEB FPGA',
            ip          = ['10.0.0.1'],
            pollEn      = True,
            initRead    = True,
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        # Cache the parameters
        self.ip          = ip
        self.numEthDev   = len(ip)  if (ip[0] != 'simulation') else 1
        self._timeout    = 1.0      if (ip[0] != 'simulation') else 100.0 
        self._pollEn     = pollEn   if (ip[0] != 'simulation') else False
        self._initRead   = initRead if (ip[0] != 'simulation') else False      
                
        # Create arrays to be filled
        self.rudp       = [None for i in range(self.numEthDev)]
        self.srpStream  = [None for i in range(self.numEthDev)]
        self.memMap     = [None for i in range(self.numEthDev)]
        
        # Loop through the devices
        for i in range(self.numEthDev):
        
            ######################################################################
            if (self.ip[0] == 'simulation'):
                self.srpStream[i]  = rogue.interfaces.stream.TcpClient('localhost',9000)
                self.dataStream[i] = rogue.interfaces.stream.TcpClient('localhost',9002)  
            else:
                self.rudp[i]       = pr.protocols.UdpRssiPack(host=ip[i],port=8193,packVer=2,jumbo=False)        
                self.srpStream[i]  = self.rudp[i].application(0)
                
            ######################################################################
            
            # Connect the SRPv3 to PGPv3.VC[0]
            self.memMap[i] = rogue.protocols.srp.SrpV3()                
            pr.streamConnectBiDir( self.memMap[i], self.srpStream[i] )             
                
            ######################################################################
            
            # Add devices
            self.add(common.Fpga( 
                name        = f'Fpga[{i}]', 
                memBase     = self.memMap[i], 
                offset      = 0x00000000, 
            ))
        
        ######################################################################
        
        # Start the system
        self.start(
            pollEn   = self._pollEn,
            initRead = self._initRead,
            timeout  = self._timeout,
        )        
