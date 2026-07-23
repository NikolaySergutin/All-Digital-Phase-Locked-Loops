`timescale 1ns / 1ps

//Programmable Numerically Controlled Charge Pump
module PNCP #(
    parameter CODE_WIDTH = 6
)(
    input  UP, DOWN,
    input  [CODE_WIDTH-1:0] CODE,
    input  EN,
    output signed [15:0] PNCH_out
);

    localparam PAD = 16 - (1 + CODE_WIDTH);

    wire sign = DOWN & ~UP;  // 1 - minus, 0 - plus

    assign PNCH_out =
        (~EN || (UP == DOWN)) ? 16'sd0 :
        {sign, CODE, {PAD{1'b0}}};

endmodule
