# =======================================================================================
#
# Project     : 1G Ethernet (1000BASE-X) Hardware Test By Using System Console for Terasic SoCkit and SFP-HSMC board.
# 
# Description : I2C Configuration script
#
# Revision Control Information
#
# Author      : Andrey Antonov
# Revision    : #1
# Date        : 2015/12/28
# ======================================================================================
	global claimMaster
	
	set OPENCORES_I2C_CR_STA_MSK             0x80
	set OPENCORES_I2C_CR_STO_MSK             0x40
	set OPENCORES_I2C_CR_RD_MSK              0x20
	set OPENCORES_I2C_CR_WR_MSK              0x10
	set OPENCORES_I2C_CR_NACK_MSK            0x8
	set OPENCORES_I2C_CR_IACK_MSK            0x1
	set OPENCORES_I2C_SR_RXNACK_MSK          0x80
	set OPENCORES_I2C_SR_BUSY_MSK            0x40
	set OPENCORES_I2C_SR_AL_MSK            0x20
	set OPENCORES_I2C_SR_TIP_MSK           0x2
	set OPENCORES_I2C_SR_IF_MSK            0x1
	set OPENCORE_I2C_CLOCK					50000000
   set OPENCORE_I2C_SPEED 				400000

	proc i2cinit {base clk speed} {
		global claimMaster 
		set masterPath	[ lindex [ get_service_paths master ] 0 ]
		set claimMaster [claim_service master $masterPath ""]
		
		set prescale [expr {($clk / ( 5 * $speed) ) - 1}]
		set slave_add [expr {0x02 * 4 + $base}]
		master_write_32 $claimMaster $slave_add 0x0
		set slave_add [expr {0x00 * 4 + $base}]
		set bit [expr {0xff & $prescale}]
		master_write_32 $claimMaster $slave_add $bit
		set bit [expr {0xff & ($prescale >> 8)}]
		set slave_add [expr {0x01 * 4 + $base}]
		master_write_32 $claimMaster $slave_add $bit
		set slave_add [expr {0x02 * 4 + $base}]
		master_write_32 $claimMaster $slave_add 0x80
	}

	proc i2cstart {base add read} {
		global claimMaster 
		global OPENCORES_I2C_CR_STA_MSK
		global OPENCORES_I2C_CR_WR_MSK
		global OPENCORES_I2C_SR_TIP_MSK
		global OPENCORES_I2C_SR_RXNACK_MSK
		set i2c_add [expr {[expr {$add << 1}] + [expr {0x1 & $read}]}]
		set slave_add [expr {0x03 * 4 + $base}]
		master_write_32 $claimMaster $slave_add $i2c_add
		set slave_add [expr {0x04 * 4 + $base}]
		set bit [expr {$OPENCORES_I2C_CR_STA_MSK | $OPENCORES_I2C_CR_WR_MSK}]
		master_write_32 $claimMaster $slave_add $bit
		while { [expr { [master_read_32 $claimMaster $slave_add 0x1] & $OPENCORES_I2C_SR_TIP_MSK }] } {}
		set I2C_ACK [expr {[master_read_32 $claimMaster $slave_add 0x1] & $OPENCORES_I2C_SR_RXNACK_MSK}]
	}

	proc i2cwrite {base data last} {
		global claimMaster 
		global OPENCORES_I2C_CR_STO_MSK
		global OPENCORES_I2C_CR_WR_MSK
		global OPENCORES_I2C_SR_TIP_MSK
		global OPENCORES_I2C_SR_RXNACK_MSK
		set slave_add [expr {0x03 * 4 + $base}]
		master_write_32 $claimMaster $slave_add $data
		set slave_add [expr {0x04 * 4 + $base}]
		if {$last} {
			set bit [expr {$OPENCORES_I2C_CR_STO_MSK | $OPENCORES_I2C_CR_WR_MSK}]
			master_write_32 $claimMaster $slave_add $bit
		} else {
			master_write_32 $claimMaster $slave_add $OPENCORES_I2C_CR_WR_MSK
		}
		while { [expr { [master_read_32 $claimMaster $slave_add 0x1] & $OPENCORES_I2C_SR_TIP_MSK }] } {}
		set I2C_ACK [expr {[master_read_32 $claimMaster $slave_add 0x1] & $OPENCORES_I2C_SR_RXNACK_MSK}]
	}

	proc i2cread {base last} {
		global claimMaster 
		global OPENCORES_I2C_CR_STO_MSK
		global OPENCORES_I2C_CR_RD_MSK
		global OPENCORES_I2C_SR_TIP_MSK
		global OPENCORES_I2C_CR_NACK_MSK
		global I2C_ReadData
		set slave_add [expr {0x04 * 4 + $base} ]
		if {$last} {
			set bit [expr {$OPENCORES_I2C_CR_STO_MSK | $OPENCORES_I2C_CR_RD_MSK | $OPENCORES_I2C_CR_NACK_MSK } ]
			master_write_32 $claimMaster $slave_add $bit
		} else {
			master_write_32 $claimMaster $slave_add $OPENCORES_I2C_CR_RD_MSK
		}
		while { [expr { [master_read_32 $claimMaster $slave_add 0x1] & $OPENCORES_I2C_SR_TIP_MSK }] } {}
		set slave_add [expr {0x03 * 4 + $base}]
		set I2C_ReadData [expr {[master_read_32 $claimMaster $slave_add 0x1]}]
	}