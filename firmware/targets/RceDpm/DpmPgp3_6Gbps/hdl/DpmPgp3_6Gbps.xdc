##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'ATLAS RD53 FMC DEV', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

create_clock -name locRefClk -period 4.0 [get_ports locRefClkP]

set_clock_groups -asynchronous \
    -group [get_clocks -include_generated_clocks sysClk200] \
    -group [get_clocks -include_generated_clocks sysClk125] \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins -hier -filter {name=~*gt0_Pgp3Gtx7Ip6G_i*gtxe2_i*TXOUTCLK}]] \
    -group [get_clocks -include_generated_clocks -of_objects [get_pins -hier -filter {name=~*gt0_Pgp3Gtx7Ip6G_i*gtxe2_i*RXOUTCLK}]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3]] -group [get_clocks -of_objects [get_pins {GEN_LANE[*].U_Pgp/U_PgpLane/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3Gtx7IpWrapper/U_RX_PLL/PllGen.U_Pll/CLKOUT1}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3]] -group [get_clocks -of_objects [get_pins {GEN_LANE[*].U_Pgp/U_PgpLane/REAL_PGP.GEN_LANE[1].U_Pgp/U_Pgp3Gtx7IpWrapper/U_RX_PLL/PllGen.U_Pll/CLKOUT1}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3]] -group [get_clocks -of_objects [get_pins {GEN_LANE[*].U_Pgp/U_PgpLane/REAL_PGP.GEN_LANE[2].U_Pgp/U_Pgp3Gtx7IpWrapper/U_RX_PLL/PllGen.U_Pll/CLKOUT1}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3]] -group [get_clocks -of_objects [get_pins {GEN_LANE[*].U_Pgp/U_PgpLane/REAL_PGP.GEN_LANE[3].U_Pgp/U_Pgp3Gtx7IpWrapper/U_RX_PLL/PllGen.U_Pll/CLKOUT1}]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT0]] -group [get_clocks -of_objects [get_pins {GEN_LANE[*].U_Pgp/U_PgpLane/REAL_PGP.U_TX_PLL/PllGen.U_Pll/CLKOUT1}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_DpmCore/U_RceG3Top/U_RceG3Clocks/U_MMCM/MmcmGen.U_Mmcm/CLKOUT3]] -group [get_clocks -of_objects [get_pins {GEN_LANE[*].U_Pgp/U_PgpLane/REAL_PGP.U_TX_PLL/PllGen.U_Pll/CLKOUT1}]]
