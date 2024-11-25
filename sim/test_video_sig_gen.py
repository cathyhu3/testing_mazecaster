import cocotb
import os
import random
import sys
from math import log
import logging
from pathlib import Path
from cocotb.clock import Clock
from cocotb.triggers import Timer, ClockCycles, RisingEdge, FallingEdge, ReadOnly,with_timeout
from cocotb.utils import get_sim_time as gst
from cocotb.runner import get_runner

@cocotb.test()
async def test_a(dut):
    """cocotb test for video_sig_genn receiveter"""
    dut._log.info("Starting...")
    cocotb.start_soon(Clock(dut.pixel_clk_in, 10, units="ns").start())
    # cocotb.start_soon(test_video_sig_genter(dut))
    dut._log.info("Holding reset...")
    dut.rst_in.value = 1 
    dut._log.info(f"reset value: {dut.rst_in}")
    await ClockCycles(dut.pixel_clk_in, 5)
    dut.rst_in.value = 0
    # await ClockCycles(dut.pixel_clk_in, 1000)
    # await RisingEdge(dut.vs_out)
    await ClockCycles(dut.pixel_clk_in, 1000)
    await ClockCycles(dut.pixel_clk_in, 1000)
    # await RisingEdge(dut.vs_out)
    # await RisingEdge(dut.vs_out)
    # await RisingEdge(dut.nf_out)
    # await RisingEdge(dut.nf_out)
    # await RisingEdge(dut.nf_out)
    # await RisingEdge(dut.nf_out)

def video_sig_gen_runner():
    """Simulate the counter using the Python runner."""
    hdl_toplevel_lang = os.getenv("HDL_TOPLEVEL_LANG", "verilog")
    sim = os.getenv("SIM", "icarus")
    proj_path = Path(__file__).resolve().parent.parent
    sys.path.append(str(proj_path / "sim" / "model"))
    sources = [proj_path / "hdl" / "video_sig_gen.sv"]
    build_test_args = ["-Wall"]
    parameters = {'ACTIVE_H_PIXELS': 20,
                "H_FRONT_PORCH": 4,
                "H_SYNC_WIDTH": 2,
                "H_BACK_PORCH": 4,
                "ACTIVE_LINES": 10,
                "V_FRONT_PORCH": 2,
                "V_SYNC_WIDTH": 1,
                "V_BACK_PORCH": 2,
                "FPS": 3} #!!!change these to do different versions
    sys.path.append(str(proj_path / "sim"))
    runner = get_runner(sim)
    runner.build(
        sources=sources,
        hdl_toplevel="video_sig_gen",
        always=True,
        build_args=build_test_args,
        parameters=parameters,
        timescale = ('1ns','1ps'),
        waves=True
    )
    run_test_args = []
    runner.test(
        hdl_toplevel="video_sig_gen",
        test_module="test_video_sig_gen",
        test_args=run_test_args,
        waves=True
    )

if __name__ == "__main__":
    video_sig_gen_runner()