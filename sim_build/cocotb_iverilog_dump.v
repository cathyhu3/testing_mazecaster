module cocotb_iverilog_dump();
initial begin
    $dumpfile("/Users/cathyhu/Documents/GitHub/testing_mazecaster/sim_build/textures.fst");
    $dumpvars(0, textures);
end
endmodule
