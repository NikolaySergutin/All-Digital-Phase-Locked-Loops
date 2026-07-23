`timescale 1ns / 1ps

module Frac_N_ADPLL_DCO #(
    parameter DIV_WIDTH = 6
)(
    input REF_rsvd, 
    input [DIV_WIDTH-1:0] MUL_VAL,
    input [1:0] FRAC_bits, 
    input EN, 
    output PLL_out
);

  wire PFD_UP, PFD_DOWN;
  wire signed [15:0] TDC_out;
  wire TDC_valid;
  wire [15:0] LF_out;  //unsigned to DCO
  wire FREQ_DIV_out;

  parameter DSM_WIDTH = 22; //32 max
  wire signed [2:0] MASH_11_OUT;
  wire signed [DIV_WIDTH-1:0] N4div = MUL_VAL + MASH_11_OUT;
  wire [DSM_WIDTH-1:0] FRAC_IN = {FRAC_bits, {(DSM_WIDTH-2){1'b0}}};
  

  PFD u_PFD (
      .F0(REF_rsvd),
      .F1(FREQ_DIV_out),
      .EN(EN),
      .UP(PFD_UP),
      .DOWN(PFD_DOWN)
  );


  TDC u_TDC (    
      .UP(PFD_UP),
      .DOWN(PFD_DOWN),
      .CLK(PLL_out), 
      .EN(EN),
      .TDC_out(TDC_out),
      .TDC_valid(TDC_valid)
  );


  LF_to_DCO u_LF (
      .LF_in(TDC_out),  
      .CLK(FREQ_DIV_out),
      .TDC_EN(TDC_valid), 
      .EN(EN),  
      .LF_out(LF_out)
  );
  
  DCO #(.D_MUX(0.053)) u_DCO (
      .Code(LF_out[15:13]),
      .EN(EN),
      .DCO_out(PLL_out)
  );

  FREQ_DIV #(.DIV_WIDTH(DIV_WIDTH)) u_DIV (
      .CLK_in(PLL_out),
      .EN(EN),
      .DIV_VAL(N4div),
      .DIV_out(FREQ_DIV_out)
  );

  MASH_11 #(
        .WIDTH(DSM_WIDTH)
    ) MASH_uut (
        .FRAC_IN  (FRAC_IN),
        .CLK      (FREQ_DIV_out),
        .EN       (EN),
        .MASH_11_OUT(MASH_11_OUT)
   );

endmodule  
