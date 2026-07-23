`timescale 1ns / 1ps

module Frac_N_ADPLL_DCO_tb;

  integer dco_edge_cnt;
  reg EN;
  reg REF_rsvd;
  wire PLL_out;

  integer fd;               // file descriptor

  // Instantiate PLL_MODEL
  Frac_N_ADPLL_DCO #(.DIV_WIDTH(6)) Frac_N_ADPLL_DCO_uut (
    .REF_rsvd(REF_rsvd),
    .MUL_VAL(40),
    .FRAC_bits(2'b01),
    .EN(EN),  
    .PLL_out(PLL_out)
  );

  always #50 REF_rsvd = ~REF_rsvd;

  always @(posedge PLL_out) begin
      dco_edge_cnt <= dco_edge_cnt + 1;
  end
  
  always @(posedge REF_rsvd) begin
    if (!EN) begin
        dco_edge_cnt = 0;
    end else begin
        $fwrite(fd, "%0t,%d\n", $time, dco_edge_cnt * 10);
        $display("TIME=%0t ns | N_PLL_OUT = %0d", $time, dco_edge_cnt * 10);
        dco_edge_cnt = 0;
    end
  end

  initial begin
    EN = 0; REF_rsvd = 0; 
    fd = $fopen("Frac_N_ADPLL_DCO_freq_log.txt", "w");
    if (fd == 0) begin
        $display("ERROR: cannot open file!");
        $finish;
    end
    $fwrite(fd, "TIME(ns),FREQ(Hz)\n");
    $fwrite(fd, "%0t,%d\n", 0, 0);

    #200;
    EN = 1;
     
    #8000000;  //finish file 
    $fclose(fd);
    $display("Frac_N_ADPLL_DCO_freq_log.txt saved.");
  end

endmodule


module Int_N_ADPLL_NCO_PNCP_tb;

  integer dco_edge_cnt;
  reg CLK;
  reg EN;
  reg REF_rsvd;
  wire PLL_out;

  integer fd;               // file descriptor

  // Instantiate PLL_MODEL
  Int_N_ADPLL_NCO_PNCP #(.DIV_WIDTH(6)) Int_N_ADPLL_NCO_PNCP_uut (
    .REF_rsvd(REF_rsvd),
    .MUL_VAL(40),
    .EN(EN),  
    .CLK(CLK),
    .PLL_out(PLL_out)
  );

  //For DIVCLK you can change Power or Kdco (ADPLL)
  //Powers to 1 GGz DCO model: 
  //1 - no
  //2 - no
  //3 - yes, but with big delay => no
  //4 - yes (MAX_NORMAL_DIVCLK = POW - 1 = 3, MIN_NORMAL_DIVCLK = 1)
  //5 - yes (MAX_NORMAL_DIVCLK = POW - 1 = 4, MIN_NORMAL_DIVCLK = 1)
  //6 - yes (MAX_NORMAL_DIVCLK = POW - 1 = 5, MIN_NORMAL_DIVCLK = 2)
  //7 - yes (MAX_NORMAL_DIVCLK = POW - 1 = 6, MIN_NORMAL_DIVCLK = 4)
  //8 - yes (MAX_NORMAL_DIVCLK = 16, MIN_NORMAL_DIVCLK = 7)
  //9 - yes (MIN_NORMAL_DIVCLK = 15, MAX_NORMAL_DIVCLK = 64)
  //10 - yes (DIVCLK = 65 - working) ...

  always #125 REF_rsvd = ~REF_rsvd; //4 MGz 
  always #0.5 CLK = ~CLK; //1 GGz

  always @(posedge PLL_out) begin
      dco_edge_cnt <= dco_edge_cnt + 1;
  end
  
  always @(posedge REF_rsvd) begin
    if (!EN) begin
        dco_edge_cnt = 0;
    end else begin
        $fwrite(fd, "%0t,%d\n", $time, dco_edge_cnt * 4);
        $display("TIME=%0t ns | N_PLL_OUT = %0d", $time, dco_edge_cnt * 4);
        dco_edge_cnt = 0;
    end
  end

  initial begin
    EN = 0; REF_rsvd = 0; CLK = 0; //dco_edge_cnt = 0;
    fd = $fopen("Int_N_ADPLL_NCO_PNCP_freq_log.txt", "w");
    if (fd == 0) begin
        $display("ERROR: cannot open file!");
        $finish;
    end
    $fwrite(fd, "TIME(ns),FREQ(Hz)\n");
    $fwrite(fd, "%0t,%d\n", 0, 0);

    #200;
    EN = 1;
     
    #8000000;  //finish file 
    $fclose(fd);
    $display("Int_N_ADPLL_NCO_PNCP_freq_log.txt saved.");
  end

endmodule



