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

class AtlasRd53EmuLpGbtLaneReg(pr.Device):

    def __init__(self,
            NUM_ELINK_G  = 4,
            pollInterval = 1,
            **kwargs):
        super().__init__(**kwargs)

        statusCntBitSize = 16

        self.addRemoteVariables(
            name         = 'Rd53LinkUpCnt',
            offset       = 0x0,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            number       = NUM_ELINK_G,
            stride       = 4,
            pollInterval = 1,
        )

        self.add(pr.RemoteVariable(
            name         = 'LpGbtDownLinkUpCnt',
            offset       = 0x4*NUM_ELINK_G+0x00,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'LpGbtUpLinkUpCnt',
            offset       = 0x4*NUM_ELINK_G+0x04,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'Rd53LinkUp',
            offset       = 0x400,
            bitSize      = NUM_ELINK_G,
            bitOffset    = 0,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'LpGbtDownLinkUp',
            offset       = 0x400,
            bitSize      = 1,
            bitOffset    = NUM_ELINK_G+0,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'LpGbtUpLinkUp',
            offset       = 0x400,
            bitSize      = 1,
            bitOffset    = NUM_ELINK_G+1,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'InvCmd',
            description  = 'Invert the serial CMD bit',
            offset       = 0x800,
            bitSize      = NUM_ELINK_G,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'DlyCmd',
            description  = '0x1: add 3.125 ns delay on the CMD output (used to deskew the CMD from discrete re-timing flip-flop IC)',
            offset       = 0x804,
            bitSize      = NUM_ELINK_G,
            mode         = 'RW',
            units        = '3.125 ns',
        ))

        self.add(pr.RemoteVariable(
            name         = 'wdtRstEn',
            offset       = 0x808,
            bitSize      = 2,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UpLinkFecMode',
            offset       = 0x80C,
            bitSize      = 1,
            mode         = 'RW',
            enum        = {
                0x0: 'FEC5',
                0x1: 'FEC12',
            },
        ))

        self.add(pr.RemoteVariable(
            name         = 'BitOrderCmd4b',
            description  = 'Used to control the inbound bit ordering into the 4:1 gearbox: 0x0=LSB shifted first, 0x1=MSB shifted first',
            offset       = 0x810,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'BitOrderData32b',
            description  = 'Used to control the outbound bit ordering out of the 8:32 gearbox: 0x0=LSB shifted first, 0x1=MSB shifted first',
            offset       = 0x818,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'InvData',
            description  = 'Used to invert the data if there is a polarity swap at the connector',
            offset       = 0x81C,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UpLinkFecDisable',
            offset       = 0x820,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UpLinkInterleaverBypass',
            offset       = 0x824,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UpLinkScramblerBypass',
            offset       = 0x828,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UpLinkLinkDownPattern',
            description  = 'Sets the linkdown pattern on the 8bit bus before the 8:32 gearbox',
            offset       = 0x82C,
            bitSize      = 8,
            mode         = 'RW',
        ))

        self.addRemoteVariables(
            name         = 'UpLinkTxDummyFec12',
            offset       = 0x830,
            bitSize      = 10,
            mode         = 'RW',
            number       = 2,
            stride       = 4,
        )

        self.addRemoteVariables(
            name         = 'UpLinkTxDummyFec5',
            offset       = 0x838,
            bitSize      = 6,
            mode         = 'RW',
            number       = 2,
            stride       = 4,
        )

        self.add(pr.RemoteVariable(
            name         = 'UpLinkDebugMode',
            offset       = 0x840,
            description  = 'Enable bitmask to override the 8:32 gearbox input with UpLinkDebugPattern',
            bitSize      = 7,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UplinkEcData',
            offset       = 0x850,
            bitSize      = 2,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UplinkIcData',
            offset       = 0x854,
            bitSize      = 2,
            mode         = 'RW',
        ))

        self.addRemoteVariables(
            name         = 'UpLinkDebugPatternA',
            description  = 'When UpLinkDebugMode[elink]=0x1 then 8:32 gearbox output toggles between UpLinkDebugPatternA[elink] & UpLinkDebugPatternB[elink]',
            offset       = 0x900,
            bitSize      = 32,
            mode         = 'RW',
            number       = 7,
            stride       = 4,
        )

        self.addRemoteVariables(
            name         = 'UpLinkDebugPatternB',
            description  = 'When UpLinkDebugMode[elink]=0x1 then 8:32 gearbox output toggles between UpLinkDebugPatternA[elink] & UpLinkDebugPatternB[elink]',
            offset       = 0x920,
            bitSize      = 32,
            mode         = 'RW',
            number       = 7,
            stride       = 4,
        )

        self.add(pr.RemoteCommand(
            name         = 'DownlinkRst',
            offset       = 0xFF0,
            bitSize      = 1,
            bitOffset    = 0,
            function     = lambda cmd: cmd.post(1),
            hidden       = False,
        ))

        self.add(pr.RemoteCommand(
            name         = 'UplinkRst',
            offset       = 0xFF4,
            bitSize      = 1,
            bitOffset    = 0,
            function     = lambda cmd: cmd.post(1),
            hidden       = False,
        ))

        self.add(pr.RemoteVariable(
            name         = 'RollOverEn',
            description  = 'Rollover enable for status counters',
            offset       = 0xFF8,
            bitSize      = 7,
            mode         = 'RW',
        ))

        self.add(pr.RemoteCommand(
            name         = 'CntRst',
            description  = 'Status counter reset',
            offset       = 0xFFC,
            bitSize      = 1,
            function     = lambda cmd: cmd.post(1),
            hidden       = False,
        ))

    def hardReset(self):
        self.CntRst()

    def softReset(self):
        self.CntRst()

    def countReset(self):
        self.CntRst()
