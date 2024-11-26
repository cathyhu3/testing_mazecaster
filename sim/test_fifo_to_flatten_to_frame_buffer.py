import cocotb
import os
import sys
from math import log
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly, with_timeout
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner

import random

"""
Inputs:
    input wire pixel_clk_in,
    input wire rst_in,

    // out of the fifo-out
    input wire fifo_tvalid_out;
    input wire [37:0] fifo_tdata_out;
    input wire fifo_tlast_out;

this should write to the frame buffer
"""

@cocotb.test()
async def test_a(dut):
    """cocotb test for fifo_to_flatten_to_frame_buffer"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_pixel_in, 1, units="ns").start())
    dut.rst_in.value = 1
    await ClockCycles(dut.clk_pixel_in,1)
    dut.rst_in.value = 0
    
    for h in range(320):
        line_height = int(h*(180/320))
        wall_type = 1
        map_data = 1
        wallX = 200
        dut.fifo_tdata_out.value = (h << 29) | (line_height << 21) | (wall_type << 20) | (map_data << 16) | wallX
        dut.fifo_tvalid_out.value = 1
        if (h == 319):
            dut.fifo_tlast_out.value = 1
        else:
            dut.fifo_tlast_out.value = 0
        await RisingEdge(dut.transformer_tready)
        
    await RisingEdge(dut.new_frame)

    for h in range(320):
        line_height = int(h*(180/400) + 30)
        wall_type = 1
        map_data = 1
        wallX = 200
        dut.fifo_tdata_out.value = (h << 29) | (line_height << 21) | (wall_type << 20) | (map_data << 16) | wallX
        dut.fifo_tvalid_out.value = 1
        if (h == 319):
            dut.fifo_tlast_out.value = 1
        else:
            dut.fifo_tlast_out.value = 0
        await RisingEdge(dut.transformer_tready)

    await RisingEdge(dut.new_frame)


def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "fifo_to_flatten_to_frame_buffer.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.v"]
    sources += [proj_path / "hdl" / "video_sig_gen.sv"]
    sources += [proj_path / "hdl" / "dda_fifo_wrap.sv"]
    sources += [proj_path / "hdl" / "transformation.sv"]
    sources += [proj_path / "hdl" / "frame_buffer.sv"]
    build_test_args = ["-Wall"]
    # parameters = {"PIXEL_WIDTH": 16,
    #               "FULL_SCREEN_WIDTH": 120,
    #               "FULL_SCREEN_HEIGHT": 80,
    #               "SCREEN_WIDTH": 30,
    #               "SCREEN_HEIGHT": 20}
    sys.path.append(str(proj_path / "sim"/ "model"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="fifo_to_flatten_to_frame_buffer",
        always=True,
        build_args=build_test_args,
        # parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="fifo_to_flatten_to_frame_buffer",
        test_module="test_fifo_to_flatten_to_frame_buffer",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()