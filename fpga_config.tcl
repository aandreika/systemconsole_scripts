#FPGA configuring procedure 

proc FPGA_CONFIG {sof_file} {

	set device_index 0 ; #Device index for target
	set device [lindex [get_service_paths device] $device_index]
	
	# Creating path to .sof file
	set sof_path [file join [file dir [pwd]] output_files $sof_file]
	
	# Refreshing USB connections 
	refresh_connections
	
	# Downloading .sof file into FPGA
	device_download_sof $device $sof_path
	
	puts "\n=============================================================================="
	puts "The FPGA device $device is configured with $sof_path\n"
	puts "=============================================================================="

}
  
  