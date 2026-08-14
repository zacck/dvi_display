import cocotb 
from cocotb.triggers import Timer 
import os 
from pathlib import Path 
import sys 
from cocotb.clock import Clock
from cocotb.triggers  import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly, with_timeout, First, Join
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner 
from random import getrandbits 
test_file = os.path.basename(__file__).replace(".py","")


async def reset(rst, clk):
    """Helper function to issue a reset signal"""
    rst.value = 1
    await ClockCycles(clk,3)
    rst.value = 0
    await ClockCycles(clk,2)


async def drive_data(dut,data_byte,control_bits, ve_bit):
    """ Clock cycle latency input"""
    dut.video_data.value = data_byte
    dut.control.value = control_bits
    dut.video_enable.value = ve_bit
    await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_tmds(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.video_data.value = 0 
    dut.control.value = 0 
    dut.video_enable.value = 0
    await reset(dut.rst, dut.clk)
    await drive_data(dut, 0x01, 0b00, 1)
    await drive_data(dut, 0x55, 0b00, 1)
    await drive_data(dut, 0x00, 0b01, 0)
    await drive_data(dut, 0x00, 0b11, 0)
    for i in range(100):
        await drive_data(dut, getrandbits(8), getrandbits(2), getrandbits(1))


def test_tmds_runner():
    """Run the encoder test"""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "verilator")
    proj_path = Path(__file__).resolve().parent.parent
    sources = [proj_path / "hdl" / "tmds_encoder.sv", proj_path / "hdl" /"tm_choice.sv"]
    build_test_args = ["-Wall"]
    parameters = {}
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    hdl_toplevel = "tmds_encoder"
    runner.build(
            sources=sources, 
            hdl_toplevel=hdl_toplevel,
            always=True,
            build_args=build_test_args,
            parameters=parameters, 
            timescale=('1ns', '1ps'), 
            waves=True
    )
    run_test_args = [] 
    runner.test(
            hdl_toplevel=hdl_toplevel,
            test_module=test_file, 
            test_args=run_test_args, 
            waves=True
    )


if __name__ == "__main__":
    test_tmds_runner()
