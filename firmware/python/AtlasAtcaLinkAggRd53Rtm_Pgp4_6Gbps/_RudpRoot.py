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
import surf.protocols.pgp  as pgp      # firmware/submodules/surf

import pyrogue.protocols

import AtlasAtcaLinkAgg    as linkAgg
import atlas_rd53_atca_dev as common
import rogue
rogue.Version.minVersion('4.7.0')

class RudpRoot(pr.Root):

    def __init__(self,
            ip = '192.168.2.10',
            **kwargs):
        super().__init__(**kwargs)

        ###################################################
        # Create the RUDP connection and map SRP to DEST[0]
        ###################################################
        self._Rudp = pr.protocols.UdpRssiPack(
            host    = ip,
            port    = 8193,
            packVer = 2,
        )
        self.add(self._Rudp)
        self._RudpSrp = self._Rudp.application(0)

        ###########################
        # Connect the SRPv3 streams
        ###########################
        self._srp = rogue.protocols.srp.SrpV3()
        self._RudpSrp == self._srp

        ###################################
        # Add the Core ATCA Link Agg device
        ###################################
        self.add(linkAgg.Core(
            memBase     = self._srp,
        ))

        #####################################
        # Add atlas_rd53_fw_lib.AtlasRd53Core
        #####################################
        for i in range(32):
            self.add(rd53Lib.Ctrl(
                name    = f'Ctrl[{i}]',
                offset  = (0x80000000 + i*0x0001_0000),
                memBase = self._srp,
                expand  = False,
            ))

        #################################
        # Add Firmware Trigger LUT device
        #################################
        self.add(rd53Lib.EmuTimingLut(
            name        = 'EmuTimingLut',
            description = 'firmware/submodules/atlas-rd53-fw-lib/python/AtlasRd53/_EmuTiming.py',
            offset      = (0x80000000 + 1*0x0100_0000),
            memBase     = self._srp,
        ))

        #################################
        # Add Firmware Trigger FSM device
        #################################
        self.add(rd53Lib.EmuTimingFsm(
            name        = 'EmuTimingFsm',
            description = 'firmware/submodules/atlas-rd53-fw-lib/python/AtlasRd53/_EmuTiming.py',
            offset      = (0x80000000 + 2*0x0100_0000),
            memBase     = self._srp,
        ))

        #####################
        # Add I2C GPIO device
        #####################
        for i in range(4):
            for j in range(3):
                index    = (i*3)+j
                baseAddr = 0x80000000 + ((i+4)*0x0100_0000)
                self.add(nxp.Pca9555(
                    name        = f'Gpio[{index}]',
                    offset      = baseAddr + (j*0x400),
                    memBase     = self._srp,
                ))

        #########################
        # Add RX PHY/APP Crossbar
        #########################
        self.add(common.AtlasRd53HsSelectioWrapper(
            name        = f'RxPhyXbar',
            offset      = 0x88000000,
            memBase     = self._srp,
        ))

        #########################
        # Add TX PHY/APP Crossbar
        #########################
        for i in range(4):
            self.add(pgp.Pgp4AxiL(
                name        = f'PgpMon[{i}]',
                offset      = (0x89000000+i*0x0000_2000),
                memBase     = self._srp,
            ))
