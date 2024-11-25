module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/cathyhu/Documents/GitHub/testing_mazecaster/sim_build/video_sig_gen.fst");
    $dumpvars(0, video_sig_gen);
end
endmodule
