
#______________________________________________________________________________
# write : 32-bit data with 24-bit addresses
#______________________________________________________________________________
 proc reg_write {base offset wdata} {
    global port_id
    set port_id [lindex [get_service_paths master] 0];
    open_service master $port_id;
	
    set address [format "%#x" [expr $base + $offset]]; 
    master_write_32 $port_id $address $wdata;
    close_service master $port_id;
    }

#______________________________________________________________________________
# read : 32-bit data with 24-bit addresses
#______________________________________________________________________________
 proc reg_read {base offset} {
    global port_id
    set port_id [lindex [get_service_paths master] 0];
    open_service master $port_id;

    set address [format "%#x" [expr $base + $offset]]; 
    set rdata [master_read_32 $port_id $address 1] 
    return $rdata
    }

