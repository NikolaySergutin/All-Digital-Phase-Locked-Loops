`timescale 1ns / 1ps

module FREQ_DIV #(
    parameter DIV_WIDTH = 6
)(
    input CLK_in, EN,
    input signed [DIV_WIDTH-1:0] DIV_VAL,
    output reg  DIV_out
);

    reg [DIV_WIDTH-1:0] counter;

    wire [DIV_WIDTH-1:0] high_phase_len = DIV_VAL >> 1;
    wire [DIV_WIDTH-1:0] low_phase_len  = DIV_VAL - high_phase_len;
    //counter bits == high_phase_len bits == low_phase_len bits == div_val bits

    always @(posedge CLK_in or negedge EN) begin
        if (!EN) begin
            DIV_out <= 1'b0;  
            counter <= 2'd2; 
        end else begin
            if (counter == 1) begin            
                counter <= (DIV_out ? low_phase_len : high_phase_len);
                DIV_out <= ~DIV_out;
            end else counter <= counter - 1;
        end
    end

endmodule
