`timescale 1ns / 1ps

module PFD(
    input F0, F1, EN,
    output reg UP, DOWN
);

wire CDN = ~(UP & DOWN) & EN;

    always @(posedge F0 or negedge CDN) begin
	if (CDN == 0) UP <= 0;
        else UP <= 1;
    end

    always @(posedge F1 or negedge CDN) begin
	if (CDN == 0) DOWN <= 0;
        else DOWN <= 1;
    end

endmodule


