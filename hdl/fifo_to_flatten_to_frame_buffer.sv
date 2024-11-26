`default_nettype none // prevents system from inferring an undeclared logic (good practice)
 
/*
testbench:
- input data into the dda-out fifo every few clock cycles

signals to be watched:
    FIFO:
        - fifo_tdata_out
    transformation:
        - ray_address_out
        - ray_pixel_out
        - ray_last_pixel_out
    frame_buffer:
        - switch
        - rgb_out
*/

module fifo_to_flatten_to_frame_buffer(
    input wire clk_pixel_in,
    input wire rst_in,
    input wire fifo_tvalid_out,
    input wire [37:0] fifo_tdata_out,
    input wire fifo_tlast_out
    );

    // VIDEO SIGNAL GENERATION
    logic [10:0] hcount_video; //hcount of system!
    logic [9:0] vcount_video; //vcount of system!
    logic hor_sync; //horizontal sync signal
    logic vert_sync; //vertical sync signal
    logic active_draw; //active draw! 1 when in drawing region.0 in blanking/sync
    logic new_frame; //one cycle active indicator of new frame of info!
    logic last_screen_pixel;
    logic [5:0] frame_count; //0 to 59 then rollover frame counter

    // VIDEO SIGN GEN
    video_sig_gen mvg(
        .pixel_clk_in(clk_pixel_in),
        .rst_in(rst_in),
        .hcount_out(hcount_video),
        .vcount_out(vcount_video),
        .vs_out(vert_sync),
        .hs_out(hor_sync),
        .ad_out(active_draw),
        .nf_out(new_frame),
        .very_last_pixel_out(last_screen_pixel),
        .fc_out(frame_count));

    // fifo-out signal to transformer
    // logic fifo_prog_empty;
    // transformer signal to fifo-out
    logic transformer_tready;

    // dda_fifo_wrap #(
    //     .DEPTH(256), //2^8 = 256 - ~320
    //     .DATA_WIDTH(40), // *multiple of 8 9 (hcount) + 8 (line height) + 1 (wall type) + 4 (map data) + 16 (wallX) = 38 bits = [37:0]
    //     .PROGFULL_DEPTH(12)
    // ) dda_fifo_out ( // read data output from traffic
    //     .sender_rst(sys_rst),
    //     .sender_clk(clk_pixel),
    //     .sender_axis_tvalid(dda_fsm_out_tvalid), // in - data on the sender_axis_tdata signal is valid and can be written into the FIFO
    //     .sender_axis_tready(dda_fsm_out_tready), // out - FIFO is ready to accept data from the sender
    //     .sender_axis_tdata({2'b00, dda_fsm_out_tdata}), // in - actual data being written into the FIFO
    //     .sender_axis_tlast(dda_fsm_out_tlast), // in - last piece of data in a frame or packet being sent to the FIFO
    //     .sender_axis_prog_full(),
    //     .receiver_clk(clk_pixel),
    //     .receiver_axis_tvalid(fifo_tvalid_out),
    //     .receiver_axis_tready(transformer_tready),
    //     .receiver_axis_tdata(fifo_tdata_out),
    //     .receiver_axis_tlast(fifo_tlast_out),
    //     .receiver_axis_prog_empty()); // unused

    // //TODO: INSERT TRANSFORMATION MODULE
    logic [15:0] ray_address_out;
    logic [15:0] ray_pixel_out;
    logic ray_last_pixel_out;

    // assign ray_last_pixel_out = 1;

    transformation flattening_module (
        .pixel_clk_in(clk_pixel_in),
        .rst_in(rst_in),
        .dda_fifo_tvalid_in(fifo_tvalid_out),
        .dda_fifo_tdata_in(fifo_tdata_out[37:0]),
        .dda_fifo_tlast_in(fifo_tlast_out),
        .transformer_tready_out(transformer_tready),
        .ray_address_out(ray_address_out),
        .ray_pixel_out(ray_pixel_out),
        .ray_last_pixel_out(ray_last_pixel_out)
    );

    // // PIXEL VALUE WRITING
    logic [23:0] rgb_out; // from the frame buffer

    frame_buffer frame_buffer_module (
        .pixel_clk_in(clk_pixel_in),
        .rst_in(rst_in),
        .hcount_in(hcount_video),
        .vcount_in(vcount_video),
        .ray_address_in(ray_address_out),
        .ray_pixel_in(ray_pixel_out),
        .ray_last_pixel_in(ray_last_pixel_out),
        .video_last_pixel_in(last_screen_pixel),
        .rgb_out(rgb_out) // should I create a valid signal so that 
    );

    // PIXEL VALUE DISPLAY ON SCREEN
    logic [7:0] red_screen, green_screen, blue_screen; //red green and blue pixel values for output
    assign red_screen = rgb_out[23:16];
    assign green_screen = rgb_out[15:8];  
    assign blue_screen = rgb_out[7:0];

    // logic [9:0] tmds_10b [0:2]; //output of each TMDS encoder! (an array of 3 elements that are 10 bits each)
    // logic tmds_signal [2:0]; //output of each TMDS serializer!

    // // three tmds_encoders (blue, green, red)
    // tmds_encoder tmds_red(
    //   .clk_in(clk_pixel),
    //   .rst_in(sys_rst),
    //   .data_in(red_screen),
    //   .control_in(2'b0),
    //   .ve_in(active_draw),
    //   .tmds_out(tmds_10b[2]));

    // tmds_encoder tmds_green(
    //   .clk_in(clk_pixel),
    //   .rst_in(sys_rst),
    //   .data_in(green_screen),
    //   .control_in(2'b0),
    //   .ve_in(active_draw),
    //   .tmds_out(tmds_10b[1]));

    // tmds_encoder tmds_blue(
    //   .clk_in(clk_pixel),
    //   .rst_in(sys_rst),
    //   .data_in(blue_screen),
    //   .control_in({vert_sync, hor_sync}),
    //   .ve_in(active_draw),
    //   .tmds_out(tmds_10b[0]));

    // // three tmds_serializers (blue, green, red):
    // tmds_serializer red_ser(
    //     .clk_pixel_in(clk_pixel),
    //     .clk_5x_in(clk_5x),
    //     .rst_in(sys_rst),
    //     .tmds_in(tmds_10b[2]),
    //     .tmds_out(tmds_signal[2]));

    // tmds_serializer green_ser(
    //     .clk_pixel_in(clk_pixel),
    //     .clk_5x_in(clk_5x),
    //     .rst_in(sys_rst),
    //     .tmds_in(tmds_10b[1]),
    //     .tmds_out(tmds_signal[1]));

    // tmds_serializer blue_ser(
    //     .clk_pixel_in(clk_pixel),
    //     .clk_5x_in(clk_5x),
    //     .rst_in(sys_rst),
    //     .tmds_in(tmds_10b[0]),
    //     .tmds_out(tmds_signal[0]));

    // OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
    // OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
    // OBUFDS OBUFDS_red  (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
    // OBUFDS OBUFDS_clock(.I(clk_pixel), .O(hdmi_clk_p), .OB(hdmi_clk_n));

endmodule
`default_nettype wire