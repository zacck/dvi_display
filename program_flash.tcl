set mode "JTAG"
set device_name xc7a35t_0
#set cfgmem_part_name
set outputDir obj

open_hw_manager
if {[current_hw_server] == ""} {
	connect_hw_server
}
open_hw_target

set hw_device [lindex [get_hw_devices $device_name] 0]

if {$mode == "JTAG"} {
	
	set bit_file [glob $outputDir/final.bit]
	set_property PROGRAM.FILE [lindex $bit_file 0] [get_hw_devices $device_name]
	current_hw_device [get_hw_devices $device_name]
	refresh_hw_device -update_hw_probes false $hw_device
	program_hw_devices [get_hw_devices $device_name]
	refresh_hw_device $hw_device
	
} elseif {$mode == "QSPI"} {
	set bin_file [glob $outputDir/final.bin]

	create_hw_cfgmem -hw_device $hw_device [lindex [get_cfgmem_parts {mx25l3233f-spi-x1_x2_x4}] 0]
	
	set hw_cfgmem [get_property PROGRAM.HW_CFGMEM $hw_device]
	
	set_property PROGRAM.BLANK_CHECK 0 $hw_cfgmem
	set_property PROGRAM.ERASE 1 $hw_cfgmem
	set_property PROGRAM.CFG_PROGRAM 1 $hw_cfgmem
	set_property PROGRAM.VERIFY 1 $hw_cfgmem
	set_property PROGRAM.CHECKSUM 0 $hw_cfgmem
	
	refresh_hw_device $hw_device
	
	set_property PROGRAM.ADDRESS_RANGE  {use_file} $hw_cfgmem
	set_property PROGRAM.FILES $bin_file $hw_cfgmem
	set_property PROGRAM.PRM_FILE {} $hw_cfgmem
	set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} $hw_cfgmem
	set_property PROGRAM.BLANK_CHECK 0 $hw_cfgmem
	set_property PROGRAM.ERASE 1 $hw_cfgmem
	set_property PROGRAM.CFG_PROGRAM 1 $hw_cfgmem
	set_property PROGRAM.VERIFY 1 $hw_cfgmem
	set_property PROGRAM.CHECKSUM 0 $hw_cfgmem
	
	set cfgmem_part [get_property CFGMEM_PART $hw_cfgmem]
	set mem_type [get_property MEM_TYPE $cfgmem_part]
	set hw_cfgmem_type [get_property PROGRAM.HW_CFGMEM_TYPE $hw_device]
	if {![string equal $hw_cfgmem_type $mem_type]}  {
		create_hw_bitstream -hw_device $hw_device [get_property PROGRAM.HW_CFGMEM_BITFILE $hw_device]
		program_hw_devices $hw_device
	};
	program_hw_cfgmem -hw_cfgmem $hw_cfgmem

}

close_hw_manager
