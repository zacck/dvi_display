import cocotb
import os 
import random 
import sys
from math import log 
import logging 
from pathlib import Path 
from cocotb.clock import Clock 
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly, with_timeout
from cocotb.runner import get_runner
test_file = os.path.basename(__file__).replace(".py", "")


@cocotb.test()
async def test_dvi_signals(dut):
    """ a cocotb test for the dvi timing signals"""
    dut._log.info("Staring...")
    cocotb.start_soon(Clock(dut.pixel_clk, 10, units="ns").start())
    dut._log.info("Holding reset")
    dut.rst.value = 1
    await ClockCycles(dut.pixel_clk, 4)
    assert dut.frame_count.value == 0 
    assert dut.h_count.value == 0
    assert dut.v_count.value == 0
    dut._log.info("Setting Reset to 0")
    dut.rst.value = 0
    await RisingEdge(dut.new_frame)
    assert dut.v_count.value == dut.ACTIVE_LINES.value - 1 
    assert dut.h_count.value == dut.ACTIVE_H_PIXELS.value
    await ClockCycles(dut.pixel_clk, dut.H_FRONT_PORCH.value + 1)
    assert dut.h_sync.value == 1
    await ClockCycles(dut.pixel_clk, (dut.H_SYNC_WIDTH.value))
    await FallingEdge(dut.pixel_clk)
    assert dut.h_sync.value == 0
    await ClockCycles(dut.pixel_clk, dut.H_BACK_PORCH.value)
    assert dut.h_count.value == 0, "We have just crossed max horizontal we should be at 0"
    await RisingEdge(dut.new_frame)
    await ClockCycles(dut.pixel_clk, (dut.TOTAL_PIXELS.value - dut.ACTIVE_H_PIXELS.value + 1))
    clocks_to_v_sync = dut.TOTAL_PIXELS.value  * dut.V_FRONT_PORCH.value
    await ClockCycles(dut.pixel_clk, clocks_to_v_sync)
    assert dut.v_sync == 1
    await RisingEdge(dut.new_frame)
    await ClockCycles(dut.pixel_clk, (dut.TOTAL_PIXELS.value - dut.ACTIVE_H_PIXELS.value + 1))
    clocks_to_v_sync_end = dut.TOTAL_PIXELS.value  * (dut.V_FRONT_PORCH.value + dut.V_SYNC_WIDTH.value + 1)
    await ClockCycles(dut.pixel_clk, clocks_to_v_sync_end)
    assert dut.v_sync.value == 0
    await RisingEdge(dut.new_frame)
    await ClockCycles(dut.pixel_clk, (dut.TOTAL_PIXELS.value - dut.ACTIVE_H_PIXELS.value + 1))
    clocks_to_end = dut.TOTAL_PIXELS.value  * (dut.TOTAL_LINES.value - dut.ACTIVE_LINES.value)
    await ClockCycles(dut.pixel_clk, clocks_to_end)
    assert dut.v_count.value == 0, "We should be at line  0"
    await ClockCycles(dut.pixel_clk, 3000)


def vsg_runner():
    """ Test DVI signals"""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "verilator")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "video_sig_gen.sv"]
    build_test_args = ["-Wall"]
    parameters = {'ACTIVE_H_PIXELS': 30, 'ACTIVE_LINES': 15, 
                  'H_BACK_PORCH': 3, 'H_SYNC_WIDTH': 2, 'H_FRONT_PORCH': 3, 
                  'V_FRONT_PORCH': 5, 'V_BACK_PORCH': 5, 'FPS': 60, 'V_SYNC_WIDTH': 3}
    sys.path.append(str(proj_path / "sim"))
    hdl_toplevel = "video_sig_gen"
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

if __name__=="__main__":
    vsg_runner()

