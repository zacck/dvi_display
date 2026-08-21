import cocotb 
from cocotb.triggers import Timer 
import os 
from pathlib import Path 
import sys 
from cocotb.clock import Clock
from cocotb.triggers  import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly, with_timeout, First, Join
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner
import random
from random import getrandbits 
test_file = os.path.basename(__file__).replace(".py","")


async def reset(rst, clk):
    """Helper function to issue a reset signal"""
    rst.value = 1
    await ClockCycles(clk,3)
    rst.value = 0
    await ClockCycles(clk,2)


async def drive_data(dut,video_byte,control_bits, ve_bit,some_tally):
    """ Clock cycle latency input"""
    print(f"Driving ve:{video_byte:b}, cb:{control_bits:b}, ve:{ve_bit}, tally:{some_tally}")
    ones = video_byte.bit_count()
    zeros = 8 - ones

    result = 0
    q_m = 0

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
                q_m = result
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
                q_m = result
            i +=1


    await Timer(5, "ns")
    
    count = some_tally
    next_count = 0

    q_m_ones = q_m.bit_count()
    q_m_zeros = 8 - q_m_ones

    q_m_out = 0
    j = 7

    if(not ve_bit):
        next_count = 0
        match control_bits:
            case 0b00:
                q_m_out = 0b1101010100
            case 0b01:
                q_m_out = 0b0010101011
            case 0b10: 
                q_m_out = 0b0101010100
            case 0b11:
                q_m_out = 0b1010101011
     
    elif(count == 0 or q_m_ones == q_m_zeros):
        # set bit 0 of result to bit 0 of video byte
        tenth = (result & (1 << 8)) >> 8
        tenth = (~tenth)&1
        q_m_out = ((tenth << 9) | q_m_out)
        ninth = (result & (1 << 8)) >> 8
        q_m_out = ((ninth << 8) | q_m_out)

        if(ninth == 1):
            while not(j < 0):
                q_m_i = (result & (1 << j)) >> j
                q_m_out = ((q_m_i << j) | q_m_out)
                j -=1

            next_count = count + (q_m_zeros - q_m_ones) 
            
        else:
            while not(j < 0):
                q_m_i = (result & (1 << j )) >> j 
                int_q = (~q_m_i)&1
                q_m_out = ((int_q << j) | q_m_out)
                j -= 1

            next_count =  count + (q_m_ones - q_m_zeros)
    else:
        if(((count > 0) and (q_m_ones > q_m_zeros)) or ((count < 0) and (q_m_zeros  > q_m_ones))):
            # set bit 0 of result to bit 0 of video byte
            q_m_out = ((1 << 9) | q_m_out)
            ninth = (result & (1 << 8)) >> 8
            q_m_out = ((ninth << 8) | q_m_out)

            while not(j < 0):
                q_m_i = (result & (1 <<  j)) >> j
                q_m_i = (~q_m_i)&1
                q_m_out = ((q_m_i << j) | q_m_out)
                j -=1


            next_count = count + (2 * ninth) + (q_m_zeros - q_m_ones)


        else:
            # set bit 0 of result to bit 0 of video byte
            q_m_out = ((0 << 9) | q_m_out)
            ninth = (result & (1 << 8)) >> 8
            q_m_out = ((ninth << 8) | q_m_out)

            while not(j < 0):
                q_m_i = (result & (1 << j)) >> j
                q_m_out = ((q_m_i << j) | q_m_out)
                j -= 1

            next_count= count - (2 * ~ninth) + (q_m_ones - q_m_zeros)
   
    dut.tally.value = count
    dut.video_data.value = video_byte
    dut.control.value = control_bits
    dut.video_enable.value = ve_bit
    await ClockCycles(dut.clk, 1)
    await FallingEdge(dut.clk)
    assert dut.tmds.value == q_m_out, f"tmds for qm: {q_m} vb:{video_byte}, tally:{count}, ve:{ve_bit}, cont:{control_bits}"
    #assert dut.tally.value == next_count, "Right count should be calculated for next clock"





@cocotb.test()
async def test_tmds(dut):
    cocotb.start_soon(Clock(dut.clk, 10, units="ns").start())
    dut.video_data.value = 0 
    dut.control.value = 0 
    dut.video_enable.value = 0
    await reset(dut.rst, dut.clk)
    await drive_data(dut, 111, 0b01, 1, 9)
    await drive_data(dut, 111, 0b01, 1, -9)
    await drive_data(dut, 111, 0b01, 1, 0)
    for i in range(100):
        await drive_data(dut, getrandbits(8), getrandbits(2), getrandbits(1), random.randint(-10, 10))


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
