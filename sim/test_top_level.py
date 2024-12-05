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
    input wire clk_pixel,                  //crystal reference clock
    input wire [3:0] btn,                   // buttons for move control and rotation
    input wire [15:0] sw,                   // switches
"""

@cocotb.test()
async def test_a(dut):
    """cocotb test for top_level"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.clk_pixel, 1, units="ns").start())
    dut.sys_rst.value = 1
    await ClockCycles(dut.clk_pixel,1)
    dut.sys_rst.value = 0

    # await ClockCycles(dut.clk_pixel,100000)
    await RisingEdge(dut.new_frame)
    await RisingEdge(dut.new_frame)
    await RisingEdge(dut.new_frame)



    


def is_runner():
    """Image Sprite Tester."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "top_level.sv"]
    sources += [proj_path / "hdl" / "xilinx_single_port_ram_read_first.v"]
    sources += [proj_path / "hdl" / "video_sig_gen.sv"]
    sources += [proj_path / "hdl" / "dda_fifo_wrap.sv"]
    sources += [proj_path / "hdl" / "transformation.sv"]
    sources += [proj_path / "hdl" / "frame_buffer.sv"]
    sources += [proj_path / "hdl" / "ray_calculations.sv"]
    sources += [proj_path / "hdl" / "controller.sv"]
    sources += [proj_path / "hdl" / "dda_fsm.sv"]
    sources += [proj_path / "hdl" / "dda.sv"]
    sources += [proj_path / "hdl" / "fifo_emulator.sv"]
    sources += [proj_path / "hdl" / "divider.sv"]
    sources += [proj_path / "hdl" / "debouncer.sv"]
    sources += [proj_path / "hdl" / "divu.sv"]
    sources += [proj_path / "hdl" / "evt_counter.sv"]
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
        hdl_toplevel="top_level",
        always=True,
        build_args=build_test_args,
        # parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="top_level",
        test_module="test_top_level",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    is_runner()