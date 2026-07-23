`timescale 1ns / 1ps

module DCO #(
    parameter real D_MUX = 0.053 
)(
    input [2:0] Code,
    input EN,        
    output DCO_out   
);

//DELAY = 0.053 ns, N_start = 18:      
// S = 7'b0000000 => T = 1.908 ns, freq = 523.56 MHz
// S = 7'b0000001 => T = 2.120 ns, freq = 471.70 MHz
// S = 7'b0000011 => T = 2.332 ns, freq = 428.83 MHz
// S = 7'b0000111 => T = 2.544 ns, freq = 393.70 MHz
// S = 7'b0001111 => T = 2.756 ns, freq = 362.87 MHz
// S = 7'b0011111 => T = 2.968 ns, freq = 336.86 MHz
// S = 7'b0111111 => T = 3.180 ns, freq = 314.47 MHz
// S = 7'b1111111 => T = 3.392 ns, freq = 294.82 MHz

wire [29:0] m;

reg [6:0] S;

//unsigned dco
always @(negedge DCO_out or negedge EN) begin
    case (Code)
        3'b000: S <= 7'b1111111; 
        3'b001: S <= 7'b0111111; 
        3'b010: S <= 7'b0011111; 
        3'b011: S <= 7'b0001111; 
        3'b100: S <= 7'b0000111;
        3'b101: S <= 7'b0000011;
        3'b110: S <= 7'b0000001;
        3'b111: S <= 7'b0000000;
        default: S <= 7'b0000000;
    endcase
end

//Input delay 
assign #(D_MUX) in = ~(DCO_out & EN);
assign #(D_MUX) m[0] = EN ? in : 0;

genvar i;
generate
for(i = 1; i < 8; i = i + 1) begin
assign #(D_MUX) m[i] = EN ? m[i-1] : 0;
end
endgenerate

//Delay stages
genvar j; 
generate for(j = 8; j < 15; j = j + 1) begin 
assign #(D_MUX) m[j] = (S[j-8] ? m[j-1] : m[29-j]) & EN; 
end 
endgenerate

assign #(D_MUX) m[15] = EN ? m[14] : 0;

genvar k; 
generate for(k = 16; k < 23; k = k + 1) begin 
assign #(D_MUX) m[k] = (S[22-k] ? m[k-1] : m[29-k]) & EN; 
end 
endgenerate

//Output delay line
genvar l;
generate
for(l = 23; l < 30; l = l + 1) begin
assign #(D_MUX) m[l] = EN ? m[l-1] : 0;
end
endgenerate

assign #(D_MUX) DCO_out = EN ? m[29] : 0;

endmodule
