# =======================================================================================
#
# Description : Si5338 Register Map Reading Script
#
# Revision Control Information
#
# Author      : Andrey Antonov
# Revision    : #1
# Date        : 2015/12/28
# Description : Initial release. Allows to set user defined integer division factor. Uses Fvco = 2500 MHz, But SoCKit uses 2600 MHz instead, so the output clock wasn't correct
# Revision    : #2
# Date        : 2016/07/29
# Description : Fixed division factor to get only 156.25 MHz from Fvco = 2600 MHz.
# Revision    : #3
# Date        : 2017/03/30
# Description : Configurable division factor for selected clock output. Fvco is fixed, because of high complexity of VCO control.
# ======================================================================================

# Please set your own Avalon-MM Slave Address of the SFP module I2C controller into $SI5338_I2C_ADDR 
set I2C_CORE_ADDR $SI5338_I2C_ADDR
 
set SI5338_ADDR 0x70

source i2c_config.tcl

# Fclkout = Fvco / MS, Fvco = (Fin / P1) * MSn = 2600 MHz
# MS = a + b / c

# MS - MultiSynth

# clkout - number of selected clock output (0-3)
# 0 - CLKOUT0, 1 - CLKOUT1, 2 - CLKOUT2, 3 - CLKOUT3 

proc CLK_CONFIG {clkout a b c} {

	global I2C_CORE_ADDR
	global OPENCORE_I2C_CLOCK
	global OPENCORE_I2C_SPEED
	global SI5338_ADDR 

	if {[lsearch {0 1 2 3} $clkout] < 0} {
		puts "Please use (0-3) as first argument to select CLKOUT0-CLKOUT3\n"
		return
	}
	
# MSx (for CLKOUTx) consists of 3 parts:
# MSx_P1 = floor((a * c + b) * 128 / c - 512)
# MSx_P2 = (b * 128) % c
# MSx_P3 = c
	
# MS0 regs: 53-62
# MS1 regs: 64-73
# MS2 regs: 75-84
# MS3 regs: 86-95
# MSn regs: 97-106

# MS0 Register Map (for other MSx register maps simply increment base address by 11)
# MS0_P1[17:0] = 55[1:0] 54[7:0] 53[7:0]
# MS0_P2[29:0] = 58[7:0] 57[7:0] 56[7:0] 55[7:2]
# MS0_P3[29:0] = 62[5:0] 61[7:0] 60[7:0] 59[7:0]

# For more details please see Si5338 register map in Si5338-RM.pdf

	set MS_base [expr 53 + $clkout * 11]
	set MSx_P1 [expr int(($a * $c + $b) * 128 / $c - 512)]
	set MSx_P2 [expr int(($b * 128) % $c)]
	set MSx_P3 [expr int($c)]
	

	
# Initializing Si5338 I2C controller
	i2cinit $I2C_CORE_ADDR $OPENCORE_I2C_CLOCK $OPENCORE_I2C_SPEED	
	i2cstart $I2C_CORE_ADDR $SI5338_ADDR 0
	
# Selecting clock output: setting MS base address
	i2cwrite $I2C_CORE_ADDR $MS_base 0
	
	i2cwrite $I2C_CORE_ADDR [expr $MSx_P1 & 0xFF]  0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P1 >> 8) & 0xFF] 0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P2 << 2) & 0xFC | ($MSx_P1 >> 16) & 0x03] 0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P2 >> 5) & 0xFF] 0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P2 >> 13) & 0xFF] 0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P2 >> 21) & 0xFF] 0
	i2cwrite $I2C_CORE_ADDR [expr $MSx_P3 & 0xFF]  0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P3 >> 8) & 0xFF] 0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P3 >> 16) & 0xFF] 0
	i2cwrite $I2C_CORE_ADDR [expr ($MSx_P3 >> 24) & 0x3F] 1
	
	set Fvco 2600.00
		
	puts "\n=============================================================================="
	puts "Si5338 CLKOUT${clkout} frequency is set to [expr $Fvco / (double($a) + double($b) / double($c)) ]MHz"
	puts "==============================================================================\n"
}

proc CLK_GET_REGMAP {filename} {
	global I2C_CORE_ADDR
	global OPENCORE_I2C_CLOCK
	global OPENCORE_I2C_SPEED
	global SI5338_ADDR 
	global I2C_ReadData

	# Opening output file
	set fout [open $filename w]
	
	# Initializing Si5338 I2C controller
	i2cinit $I2C_CORE_ADDR $OPENCORE_I2C_CLOCK $OPENCORE_I2C_SPEED
	
	# Reading si5338  Register Map - total 256 bytes
	i2cstart $I2C_CORE_ADDR $SI5338_ADDR 0
	i2cwrite $I2C_CORE_ADDR 0x0 0
	i2cstart $I2C_CORE_ADDR $SI5338_ADDR 1

	for {set i 0} {$i < 256} {incr i} {
		i2cread $I2C_CORE_ADDR [expr {$i >= 255}]
		puts $fout "$i,[format %02X ${I2C_ReadData}]h"
	}

	puts "\n=============================================================================="
	puts "Si5338 Register Map downloaded to $filename"
	puts "==============================================================================\n"

	close $fout
}
