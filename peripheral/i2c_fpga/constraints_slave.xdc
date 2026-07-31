###############################################################################
# I2C Slave Constraints
###############################################################################

# Allow SCL to use general routing (required because SCL is used as a clock)
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of_objects [get_ports scl]]

###############################################################################
# I2C Interface
###############################################################################

# SCL
set_property PACKAGE_PIN T6 [get_ports scl]
set_property IOSTANDARD LVCMOS33 [get_ports scl]
set_property PULLTYPE PULLUP [get_ports scl]

# SDA
set_property IOSTANDARD LVCMOS33 [get_ports sda]
set_property PULLTYPE PULLUP [get_ports sda]

set_property PACKAGE_PIN T5 [get_ports sda]
