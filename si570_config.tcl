# =======================================================================================
#
# Project     : 10G Ethernet (10GBASE-R) Hardware Test By Using System Console for Arria V SoC Kit.
# 
# Description : Si570 Configuration and Register Map Reading Script
#
# Revision Control Information
#
# Author      : Andrey Antonov
# Revision    : #1
# Date        : 2016/06/28
# ======================================================================================
set I2C_CORE_ADDR 0xA100
set SI570_ADDR	0x66

source i2c_config.tcl

proc CLK_CONFIG {} {
	global I2C_CORE_ADDR
	global OPENCORE_I2C_CLOCK
	global OPENCORE_I2C_SPEED
	global SI570_ADDR 
	global I2C_ReadData

	# Configuring Si570
	# Default (NVM settings) frequency is 100 MHz
	# Reconfiguring to 644.53125 MHz

	# Initializing Si570 I2C controller
	i2cinit $I2C_CORE_ADDR $OPENCORE_I2C_CLOCK $OPENCORE_I2C_SPEED
	
	# Recalling initial CLK settings from NVM into RAM
	i2cstart $I2C_CORE_ADDR $SI570_ADDR 0
	i2cwrite $I2C_CORE_ADDR 135 0 
	i2cwrite $I2C_CORE_ADDR 0x01 1

	# Freezing DCO: Setting Freeze DCO bit (4) = 1
	i2cstart $I2C_CORE_ADDR $SI570_ADDR 0
	i2cwrite $I2C_CORE_ADDR 137 0 
	i2cwrite $I2C_CORE_ADDR 0x10 1

	# Writing new register values
	set Si570_regs "0x00 0x42 0xD2 0x17 0xA3 0x83"

	i2cstart $I2C_CORE_ADDR $SI570_ADDR 0
	i2cwrite $I2C_CORE_ADDR 13 0 

	for {set i 0} {$i < 6} {incr i} {
		i2cwrite $I2C_CORE_ADDR [lindex $Si570_regs $i] [expr {$i >= 5}]
	}

	# Unfreezing DCO: Setting Freeze DCO bit (4) = 0
	i2cstart $I2C_CORE_ADDR $SI570_ADDR 0
	i2cwrite $I2C_CORE_ADDR 137 0 
	i2cwrite $I2C_CORE_ADDR 0x00 1
	
	# New frequency applied: writing reg 135 NewFreq (bit 6) = 1 and unfreezing M control word
	i2cstart $I2C_CORE_ADDR $SI570_ADDR 0
	i2cwrite $I2C_CORE_ADDR 135 0 
	i2cwrite $I2C_CORE_ADDR 0x40 1
	
	puts "\n=============================================================================="
	puts "\tSi570 CLKOUT frequency is set to 644.53125 MHz"
	puts "==============================================================================\n"
	
#	set jdpath	[ lindex [ get_service_paths jtag_debug ] 0 ]
#	jtag_debug_reset_system $jdpath
}

proc CLK_GET_REGMAP {filename} {
	global I2C_CORE_ADDR
	global OPENCORE_I2C_CLOCK
	global OPENCORE_I2C_SPEED
	global SI570_ADDR 
	global I2C_ReadData

	# Opening output file
	set fout [open $filename w]
	
	# Initializing Si570 I2C controller
	i2cinit $I2C_CORE_ADDR $OPENCORE_I2C_CLOCK $OPENCORE_I2C_SPEED
	
	# Reading si570  Register Map - total 6 bytes
	i2cstart $I2C_CORE_ADDR $SI570_ADDR 0
	i2cwrite $I2C_CORE_ADDR 13 0
	i2cstart $I2C_CORE_ADDR $SI570_ADDR 1

	for {set i 13} {$i < 19} {incr i} {
		i2cread $I2C_CORE_ADDR [expr {$i >= 18}]
		puts $fout "$i,[format %02X $I2C_ReadData]h"
	}

	puts "\n=============================================================================="
	puts "Si570 Register Map downloaded to $filename"
	puts "==============================================================================\n"

	close $fout
}
