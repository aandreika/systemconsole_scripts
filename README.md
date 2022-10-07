The repo contains some useful Intel FPGA (Altera) System Console Tcl scripts.
- basic.tcl -- some basic functions to read and write Avalon-MM slaves
- fpga_config.tcl -- FPGA configuration function only
- i2c_config.tcl -- OpenCores I2C IP-core configuration and usage
- sfp_config.tcl -- SFP-module EEPROM readout function
- si5338_config.tcl -- SiLabs Si5338 any-frequency clock generator configuration script. With some modifications might also be used to manage Si534x
- si570_config.tcl -- SiLabs Si570 I2C configurable XO configuration script. Configurates to the hardcoded frequency 644.53125 MHz, but could be modified easily

These scripts were written to support my 1G/10G Ethernet reference design projects based on the Arrow SoCKit board (1G) and Arria V ST DevKit (10G).
