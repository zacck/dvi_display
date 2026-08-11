## Template Project for TCL Flow with Vivado and Basys 3

This decouples on from the Vivado GUI flow, and saves some time during build and flashing.

Note:
1. Your top level module will need to be labelled top_level, this can always be changed
2. Built for the Artix-7 on the Basys3  can be changed 

Structure

### Directories
- hdl: All HDL files go here 
- obj: This is output for the builds 
- sim: our simulation, C++ and Python files go here 
- xdc: Constraints file(s) goes here 


### Files 
- build.tcl: TCL script to build a bitfile from our source 
- program_flash.tcl: TCL script to program our bitfile to the device 
- sim/test_counter.py :  A cocotb test script for a simple module this, really just shows setup
- hdl/counter.sv : A simple counter module to exercise the test module
