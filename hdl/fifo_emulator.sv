/*
fifo emulated as an unpacked array
*/
module fifo_emulator #(
                        parameter DEPTH = 144,
                        parameter DATA_WIDTH = 256
                    ) 
                    (
                        input wire clk_pixel,
                        input wire rst_in,

                        // from sender
                        input wire sender_valid_in,
                        input wire sender_last_in,
                        input wire [DATA_WIDTH-1:0] sender_data_in,
                        // to sender from fifo (ready to receive data from sender)
                        output logic fifo_ready_out,

                        // from receiver (receiver is ready)
                        input wire receiver_ready_in,
                        // to receiver (fifo data is valid)
                        output logic receiver_valid_out,
                        output logic [DATA_WIDTH-1:0] receiver_data_out,
                        output logic receiver_last_out
                    );
    
    assign receiver_valid_out = 1;      // fifo data is always valid
    assign fifo_ready_out = 1;          // fifo always ready to receive data

    logic [DATA_WIDTH:0] fifo [DEPTH-1:0];

    logic [$clog2(DEPTH)-1:0] write_pointer;
    logic [$clog2(DEPTH)-1:0] read_pointer;

    always_ff @(posedge clk_pixel) begin
        if (rst_in) begin
            write_pointer <= 0;
            read_pointer <= 0;
        end else begin
            if (sender_valid_in) begin
                fifo[write_pointer] <= {sender_data_in, sender_last_in};
                write_pointer <= (write_pointer < DEPTH) ? write_pointer + 1 : 0;
            end
            if (receiver_ready_in) begin
                receiver_data_out <= fifo[read_pointer][DATA_WIDTH:1];
                receiver_last_out <= fifo[read_pointer][0];
                read_pointer <= (write_pointer < DEPTH) ? read_pointer + 1 : 0;
            end
        end
    end

endmodule