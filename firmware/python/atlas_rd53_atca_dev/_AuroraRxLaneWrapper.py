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

class AuroraRxLaneWrapper(pr.Device):

    def __init__(self,
            pollInterval = 1,
            **kwargs):
        super().__init__(**kwargs)

        statusCntBitSize = 16

        self.add(pr.RemoteVariable(
            name         = 'LinkUpCnt',
            description  = 'Status counter for link up',
            offset       = 0x00,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'AuroraHdrErrDet',
            description  = 'Increments when the Aurora 2-bit header is not 10 or 01',
            offset       = 0x04,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'GearBoxBitSlipCnt',
            description  = 'Increments whenever there is a gearbox bit slip executed',
            offset       = 0x08,
            bitSize      = statusCntBitSize,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'LinkUp',
            description  = 'link up',
            offset       = 0x0C,
            bitSize      = 1,
            bitOffset    = 0,
            mode         = 'RO',
            pollInterval = pollInterval,
        ))

        self.add(pr.RemoteVariable(
            name         = 'LockingCntCfg',
            description  = 'Sets the number of good 2-bit headers required for locking per delay step sweep',
            offset       = 0x10,
            bitSize      = 24,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'MinEyeWidth',
            description  = 'Sets the min. eye width in the RX IDELAY eye scan',
            offset       = 0x14,
            bitSize      = 8,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'UserRxDelayTap',
            description  = 'Sets the RX IDELAY tap configuration (A.K.A. RxDelayTap) when EnUsrDlyCfg = 0x1',
            offset       = 0x18,
            bitSize      = 9,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'SelectRate',
            description  = 'SelectRate and RD53.SEL_SER_CLK[2:0] must be the same (default of 0x0 = 1.28Gbps)',
            offset       = 0x1C,
            bitSize      = 2,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'EnUsrDlyCfg',
            description  = 'Enables the User to override the automatic RX IDELAY tap configuration (Note: For 7-series FPGAs the 5-bit config is mapped like dlyCfg(8 downto 4) to the most significant bits)',
            offset       = 0x20,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'Polarity',
            description  = 'RX polarity (inverted by default)',
            offset       = 0x24,
            bitSize      = 1,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'RollOverEn',
            description  = 'Rollover enable for status counters',
            offset       = 0xF8,
            bitSize      = 7,
            mode         = 'RW',
        ))

        self.add(pr.RemoteCommand(
            name         = 'CntRst',
            description  = 'Status counter reset',
            offset       = 0xFC,
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
