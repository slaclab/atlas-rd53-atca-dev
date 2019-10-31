##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property PACKAGE_PIN G8 [get_ports { gtRefClk320P }]
set_property PACKAGE_PIN G7 [get_ports { gtRefClk320N }]

set_property PACKAGE_PIN L27 [get_ports { userClk156P }]
set_property PACKAGE_PIN L28 [get_ports { userClk156N }]

create_clock -name gtRefClk320P -period 3.118 [get_ports {gtRefClk320P} ]
create_clock -name userClk156P  -period 6.400 [get_ports {userClk156P} ]

set_clock_groups -asynchronous \
   -group [get_clocks -include_generated_clocks {gtRefClk320P}] \
   -group [get_clocks -include_generated_clocks {userClk156P}] \
   -group [get_clocks {clk200}] \  
   -group [get_clocks {clk125}]
