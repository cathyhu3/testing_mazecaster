module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/cathyhu/Documents/GitHub/testing_mazecaster/sim/sim_build/frame_buffer_testing.fst");
    $dumpvars(0, frame_buffer_testing);
end
endmodule
