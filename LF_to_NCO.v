`timescale 1 ns / 1 ps

module LF_to_NCO (
    input signed [15:0] LF_in,   // int16 
    input CLK, TDC_EN, EN,       
    output signed [16:0] LF_out   //signed to NCO
);

    wire signed [15:0] KP_out;     // P = In 
    wire signed [15:0] KI_out;     // I = In >> 7 
    wire signed [15:0] integral_add_out;
    reg signed [15:0] integral_reg;
    wire signed [31:0] integral_add_temp;
    wire signed [31:0] LF_add_temp;

    // P-term - fast reaction
    assign KP_out = (LF_in <<< 2) + (LF_in <<< 1); //LF_in * 6;

    // I-term (scaled) - reaction for long mistake
    assign KI_out = LF_in >>> 5;

    // Integrator register - I-memory to post I-value
    always @(posedge CLK or negedge EN or TDC_EN)
    if (!EN)
        integral_reg <= 16'sd0;
    else if (TDC_EN)
        integral_reg <= integral_add_out;
    else
        integral_reg <= integral_reg;

    // Integrator accumulation - new I-value
    assign integral_add_temp =
        {{16{KI_out[15]}}, KI_out} +
        {{16{integral_reg[15]}}, integral_reg};

    //saturation - protection
    assign integral_add_out =
        ( integral_add_temp[31] == 1'b0 &&
          integral_add_temp[30:15] != 16'b0 ) ?
            16'sh7FFF :
        ( integral_add_temp[31] == 1'b1 &&
          integral_add_temp[30:15] != 16'hFFFF ) ?
            16'sh8000 :
            integral_add_temp[15:0];

    // P + I
    assign LF_add_temp =
        {{16{KP_out[15]}}, KP_out} +
        {{16{integral_add_out[15]}}, integral_add_out};

assign LF_out = LF_add_temp[16:0]; // -65536 ... +65535 - signed to NCO

endmodule

