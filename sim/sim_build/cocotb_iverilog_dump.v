module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/cathyhu/Documents/GitHub/testing_mazecaster/sim/sim_build/top_level.fst");
    $dumpvars(0, top_level);
end
endmodule
