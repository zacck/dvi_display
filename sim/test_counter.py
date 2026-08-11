import cocotb 
import os
import random 
import sys 
import logging
from pathlib import Path 
from cocotb.triggers import Timer 
from cocotb.utils import get_sim_time as gst 
from cocotb.runner import get_runner


# get the name of current file for the runner
test_file = os.path.basename(__file__).replace(".py","")

async def generate_clock(clock_wire):
    while True:
        clock_wire.value = 0;
        await Timer(5, units="ns")
        clock_wire.value = 1
        await Timer(5, units="ns")


@cocotb.test()
async def first_test(dut):
    """ First cocotb test? """
    await cocotb.start( generate_clock(dut.clk)) # launch clock 
    dut.rst.value = 1
    dut.period.value = 3
    await Timer(5, "ns")
    await Timer(5, "ns")
    dut.rst.value = 0 # release reset counter should start now 
    assert dut.count.value == 0
    count = dut.count.value
    dut._log.info(f"Checking count @ {gst('ns')} ns: count: {count}")
    await Timer(5, "ns")
    await Timer(5, "ns")
    count = dut.count.value
    dut._log.info(f"Checking count @ {gst('ns')} ns: count: {count}")
    await Timer(5, "ns")
    await Timer(5, "ns")
    count = dut.count.value
    dut._log.info(f"Checking count @ {gst('ns')} ns: count: {count}")
    dut.rst.value = 1
    dut.period.value = 3
    await Timer(5, "ns")
    await Timer(5, "ns")
    dut.rst.value = 0 # release reset counter should start now 
    #add to end of first_test run a bit longer for waves
    await Timer(100, "ns")
    dut.period.value = 15
    await Timer(1000, "ns")


def counter_runner():
    """ Simulate the counter using the python runner """
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "verilator")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "counter.sv"]
    hdl_toplevel = "counter"
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
            sources = sources, 
            hdl_toplevel = hdl_toplevel, 
            always=True,
            build_args=build_test_args, 
            parameters=parameters, 
            timescale=('1ns','1ps'),
            waves=True
    )
    run_test_args =  []
    runner.test(
            hdl_toplevel=hdl_toplevel,
            test_module=test_file,
            test_args=run_test_args,
            waves=True
    )

if __name__ == "__main__":
    counter_runner()

