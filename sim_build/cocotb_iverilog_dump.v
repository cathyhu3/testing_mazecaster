module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/cathyhu/Documents/GitHub/testing_mazecaster/sim_build/fifo_to_flatten_to_frame_buffer.fst");
    $dumpvars(0, fifo_to_flatten_to_frame_buffer);
end
endmodule
