synth:
	vivado -nolog -nojournal -mode batch -source build.tcl

flash:
	vivado -nolog -nojournal -mode batch -source program_flash.tcl
