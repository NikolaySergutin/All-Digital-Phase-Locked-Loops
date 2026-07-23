`timescale 1ns / 1ps

module MASH_11 #(
    parameter WIDTH = 16  
)(
    input [WIDTH-1:0]  FRAC_IN,
    input CLK, EN,
    output reg signed [2:0] MASH_11_OUT   // -1,0,+1,+2
);

    // Outputs of two MASH_1 stages
    wire mash1_out1;
    wire mash1_out2;

    // Quantization error from stage 1
    wire [WIDTH-1:0] quant_error_1;

    // Delayed versions
    reg mash1_out1_z1;
    reg mash1_out2_z1;

    // Stage 1
    MASH_1 #(.WIDTH(WIDTH)) u_m1 (
        .FRAC_IN     (FRAC_IN),
        .CLK         (CLK),
        .EN          (EN),
        .MASH_1_OUT  (mash1_out1),
        .QUANT_ERROR (quant_error_1)
    );

    // Stage 2
    MASH_1 #(.WIDTH(WIDTH)) u_m2 (
        .FRAC_IN     (quant_error_1),
        .CLK         (CLK),
        .EN          (EN),
        .MASH_1_OUT  (mash1_out2),
        .QUANT_ERROR ()              // not used
    );

    // Noise shaping: y = y1(z^-1) + y2 - y2(z^-1)
    always @(posedge CLK or EN) begin
    if (!EN) begin
        mash1_out1_z1 <= 0;
        mash1_out2_z1 <= 0;
        MASH_11_OUT   <= 0;
    end else begin
        mash1_out1_z1 <= mash1_out1;
        mash1_out2_z1 <= mash1_out2;
        MASH_11_OUT   <= mash1_out1_z1 + mash1_out2 - mash1_out2_z1;
    end
end

endmodule


module MASH_1 #(
    parameter WIDTH = 16  
)(
    input [WIDTH-1:0] FRAC_IN,   
    input CLK, EN,
    output reg MASH_1_OUT,    // (0 = N, 1 = N+1)
    output reg [WIDTH-1:0] QUANT_ERROR
);
    reg [WIDTH:0] acc; 

    always @(posedge CLK or EN) begin
        if (!EN) begin
            acc         <= 0;
            MASH_1_OUT    <= 0;
            QUANT_ERROR <= 0;
        end else begin
            acc = acc + FRAC_IN;

            if (acc[WIDTH]) begin
                acc      = acc - (1 << WIDTH);
                MASH_1_OUT <= 1'b1;   // N+1
            end else begin
                MASH_1_OUT <= 1'b0;   // N
            end
            QUANT_ERROR <= acc[WIDTH-1:0];
        end
    end

endmodule
