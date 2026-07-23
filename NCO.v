`timescale 1ns / 1ps

module NCO (
  input signed [16:0] FCW, //sfix17
  input CLK,
  input signed [16:0] NCO_base, //17'sb00010100011110110
  input EN, 
  output NCO_out
);  
 
  reg signed [16:0] Delay;  // sfix17
  wire signed [31:0] Add_temp;  // sfix32
  wire signed [16:0] Add_out;  // sfix17
  wire signed [31:0] add_base_temp;
  wire signed [16:0] Convert;

  assign add_base_temp = {{15{NCO_base[16]}}, NCO_base} + 
                                         {{15{FCW[16]}}, FCW};

  assign Convert = (!EN) ? 17'sd0 :
      (((add_base_temp[31] == 0) && 
       (add_base_temp[30:16] != 0)) ? 17'sb01111111111111111 :
       ((add_base_temp[31] == 1) && 
       (add_base_temp[30:16] != 15'b111111111111111)) ? 17'sb10000000000000000 :
                                                           $signed(add_base_temp[16:0]));

  assign Add_temp = {{15{Convert[16]}}, Convert} + {{15{Delay[16]}}, Delay};
  assign Add_out =  Add_temp[16:0];

  always @(posedge CLK or negedge EN)
        Delay <= EN ? Add_out : 17'sd0;

  assign NCO_out = Delay[16];

endmodule  
