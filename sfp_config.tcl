# =======================================================================================
#
# Project     : 1G Ethernet (1000BASE-X) Hardware Test By Using System Console for Terasic SoCkit and SFP-HSMC board.
# 
# Description : SFP module EEPROM Reading Script
#
# Revision Control Information
#
# Author      : Andrey Antonov
# Revision    : #1
# Date        : 2015/12/28
# ======================================================================================

# Please set your own Avalon-MM Slave Address of the SFP module I2C controller into $SFP_I2C_ADDR 

set I2C_CORE_ADDR $SFP_I2C_ADDR 

# Conventional SFP Memory Base Address - A0h (one bit shifted right)
set SFP_I2C_ADDR1 0x50	

# Enhanced Feature Set SFP Memory Base Address - A2h (one bit shifted right)
set SFP_I2C_ADDR2 0x51

source i2c_config.tcl

proc SFP_GET_REGMAP {filename} {
	global I2C_CORE_ADDR
	global OPENCORE_I2C_CLOCK
	global OPENCORE_I2C_SPEED
	global SFP_I2C_ADDR1 
	global SFP_I2C_ADDR2
	global I2C_ReadData
	# Opening output file
	set fout [open $filename w]

	puts $fout "Conventional SFP Memory (Address A0h):"
	# Reading Register Map

	# Initializing reading via I2C
	i2cinit $I2C_CORE_ADDR $OPENCORE_I2C_CLOCK $OPENCORE_I2C_SPEED
	i2cstart $I2C_CORE_ADDR $SFP_I2C_ADDR1 0
	i2cwrite $I2C_CORE_ADDR 0x0 0
	i2cstart $I2C_CORE_ADDR $SFP_I2C_ADDR1 1

	# Reading Conventional SFP Memory (Address A0h)
	for {set i 0} {$i < 96} {incr i} {
		i2cread $I2C_CORE_ADDR [expr {$i >= 95}]
		puts $fout "$i,[format %02X $I2C_ReadData]h"
	}
		
	puts $fout "\nEnhanced Feature Set Memory (Address A2h):"

	# Initializing reading via I2C
	i2cstart $I2C_CORE_ADDR $SFP_I2C_ADDR2 0
	i2cwrite $I2C_CORE_ADDR 0x0 0
	i2cstart $I2C_CORE_ADDR $SFP_I2C_ADDR2 1

	# Reading Enhanced Feature Set Memory (Address A2h):
	for {set i 0} {$i < 256} {incr i} {
		i2cread $I2C_CORE_ADDR [expr {$i >= 255}]
		puts $fout "$i,[format %02X $I2C_ReadData]h"
	}

	puts "SFP module EEPROM downloaded to $filename"

	close $fout
}