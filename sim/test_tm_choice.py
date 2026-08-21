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
from random import getrandbits
test_file = os.path.basename(__file__).replace(".py", "")

async def drive_and_assert(dut, video_byte):
    print(f"Driving for {video_byte:b}")
    ones = video_byte.bit_count()
    zeros = 8 - ones

    result = 0

    # set bit 0 of result to bit 0 of video byte
    zeroeth = (video_byte & (1 << 0)) >> 0
    result = ((zeroeth << 0) | result)

    i = 1
    if((ones > 4) or (ones == 4 and not(video_byte & 1))):
        while i < 9:
            if(i == 8):
                result = ((0 << i) | result)
            else:
                rith_min_1 = (result & (1 << (i - 1))) >> i - 1
                vith = (video_byte & ( 1 << i)) >> i
                res = ~(rith_min_1 ^ vith)
                res = res &1
                result = ((res << i) | result)
            i +=1
    else:
        while i < 9:
            if(i == 8):
                result = ((1 << i) | result)
            else:
                rith_min_1 = (result & (1 << (i - 1))) >> i - 1
                vith = (video_byte & ( 1 << i)) >> i
                res = (rith_min_1 ^ vith) 
                res = res &1
                result = ((res << i) | result)
            i +=1


    dut.din.value = video_byte
    await Timer(5, "ns")
    assert dut.q_m.value == result





@cocotb.test()
async def test_tm_choice_one(dut):
    """Is our tm choice correct"""
    dut._log.info("Starting...")
    await Timer(5, "ns")
    dut._log.info("Starting Option 1")
    dut.din.value = 0x01
    await Timer(5, "ns")
    assert dut.q_m.value == 0x1FF
    await Timer(5, "ns")
    await drive_and_assert(dut, 0x01)
    dut._log.info("Starting Option 2")
    dut.din.value = 0xFE
    await Timer(5, "ns")
    assert dut.q_m.value == 0x00
    await drive_and_assert(dut, 0xFE)
    dut._log.info("Starting Option 3")
    dut.din.value = 0x0F
    await Timer(5, "ns")
    assert dut.q_m.value == 0x105
    dut._log.info("Starting Option 4")
    dut.din.value = 0x6A
    await Timer(5, "ns")
    assert dut.q_m.value == 0x8C
    await drive_and_assert(dut, 0x0F)
    for u in range(1000):
     await drive_and_assert(dut, getrandbits(8))



   
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
