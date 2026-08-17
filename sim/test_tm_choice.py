import cocotb
import os
import random 
import sys 
from math import log 
import logging
from pathlib import Path 
from cocotb.clock import Clock 
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge
from cocotb.runner import get_runner
test_file = os.path.basename(__file__).replace(".py", "")

@cocotb.test()
async def test_tm_choice_one(dut):
    """Is out tm choice correct"""
    dut._log.info("Starting...")
    await Timer(5, "ns")
    dut._log.info("Starting Option 1")
    dut.din.value = 0x01
    await Timer(5, "ns")
    assert dut.q_m.value == 0x1FF
    await Timer(5, "ns")
    dut._log.info("Starting Option 2")
    dut.din.value = 0xFE
    await Timer(5, "ns")
    assert dut.q_m.value == 0x00
    dut._log.info("Starting Option 2")
    dut.din.value = 0x0F
    await Timer(5, "ns")
    assert dut.q_m.value == 0x105
   

   
def tm_choice_runner(): 
    """ Simulate the tm_choice """
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "verilator")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "tm_choice.sv"]
    hdl_toplevel = "tm_choice"
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path  / "sim"))
    runner = get_runner(sim)
    runner.build(
            sources=sources,
            hdl_toplevel=hdl_toplevel,
            always=True, 
            build_args=build_test_args, 
            parameters=parameters, 
            timescale=('1ns', '1ps'),
            waves=True
    )
    run_test_args=[]
    runner.test(
            hdl_toplevel=hdl_toplevel, 
            test_module=test_file,
            test_args=run_test_args, 
            waves=True
    )


if __name__ == "__main__":
    tm_choice_runner()
