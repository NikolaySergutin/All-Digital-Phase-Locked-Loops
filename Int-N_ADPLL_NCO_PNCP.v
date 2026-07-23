`timescale 1ns / 1ps

module Int_N_ADPLL_NCO_PNCP #(
    parameter DIV_WIDTH = 6
)(
    input REF_rsvd, 
    input [DIV_WIDTH-1:0] MUL_VAL,
    input EN, CLK,
    output PLL_out
);

  wire PFD_UP, PFD_DOWN;
  wire signed [15:0] PNCH_out;
  wire signed [16:0] LF_out;  //signed to NCO
  wire FREQ_DIV_out;
  

  PFD u_PFD (
      .F0(REF_rsvd),
      .F1(FREQ_DIV_out),
      .EN(EN),
      .UP(PFD_UP),
      .DOWN(PFD_DOWN)
  );

  //Only with NCO without MASH
  PNCP #(.CODE_WIDTH(DIV_WIDTH)) u_PNCP (
      .UP(PFD_UP),
      .DOWN(PFD_DOWN),
      .CODE(MUL_VAL),
      .EN(EN),
      .PNCH_out(PNCH_out)
  );


  LF_to_NCO u_LF (
      .LF_in(PNCH_out),  
      .CLK(FREQ_DIV_out),
      .TDC_EN(1), 
      .EN(EN),  
      .LF_out(LF_out)
  );


  NCO u_NCO (
      .FCW(LF_out),
      .CLK(CLK),
      .NCO_base(17'sb00010100100000100), //middle_freg/2
      //.NCO_base(17'sb00000000011000110), //middle_freg/2
      .EN(EN),
      .NCO_out(PLL_out)
  );


  FREQ_DIV #(.DIV_WIDTH(DIV_WIDTH)) u_DIV (
      .CLK_in(PLL_out),
      .EN(EN),
      .DIV_VAL(MUL_VAL),
      .DIV_out(FREQ_DIV_out)
  );

endmodule  
