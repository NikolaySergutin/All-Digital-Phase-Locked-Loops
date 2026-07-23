`timescale 1ns / 1ps

// +/- 1 in the end
module TDC(
    input  wire UP,
    input  wire DOWN,
    input  wire CLK,
    input  wire EN,
    output wire signed [15:0] TDC_out,
    output reg                TDC_valid
);

    reg signed [6:0] acc;
    reg signed [6:0] acc_latched;
    reg signed [1:0] last_dir;   // +1 = UP, -1 = DOWN

    wire up_active   = UP & ~DOWN;
    wire down_active = DOWN & ~UP;
    wire measuring   = up_active | down_active;
    wire idle        = ~(UP | DOWN);

    // Saturating ADD (7 bits)
    function signed [6:0] sat_add;
        input signed [6:0] a;
        input signed [6:0] b;
        reg   signed [7:0] sum_ext;
        begin
            sum_ext = {a[6], a} + {b[6], b};

            if (sum_ext > 8'sb0_1111111)
                sat_add = 7'sd63;
            else if (sum_ext < 8'sb1_0000000)
                sat_add = -7'sd64;
            else
                sat_add = sum_ext[6:0];
        end
    endfunction

    // Scaling with saturation (SHIFT=9)
    function signed [15:0] scale_sat;
        input signed [6:0] x;
        reg   signed [15:0] tmp;
        reg   signed [15:0] maxp, minn;
        integer i;
        begin
            tmp  = {{9{x[6]}}, x};

            maxp = 16'sh7FFF;
            minn = 16'sh8000;

            for (i = 0; i < 9; i = i + 1) begin
                if (tmp > (maxp >>> 1))
                    tmp = maxp;
                else if (tmp < (minn >>> 1))
                    tmp = minn;
                else
                    tmp = tmp <<< 1;
            end

            scale_sat = tmp;
        end
    endfunction

    assign TDC_out = TDC_valid ? scale_sat(acc_latched) : 16'sd0;

    // Main logic
    always @(posedge CLK or negedge EN) begin
        if (!EN) begin
            acc         <= 7'sd0;
            acc_latched <= 7'sd0;
            TDC_valid   <= 1'b0;
            last_dir    <= 2'sd0;

        end else begin

            if (measuring) begin
                last_dir <= up_active ? 2'sd1 : -2'sd1;
                acc      <= sat_add(acc, last_dir);
                TDC_valid <= 1'b0;

            end else if (idle) begin

                acc_latched <= sat_add(acc, last_dir);

                TDC_valid   <= |acc;
                acc         <= 7'sd0;
                last_dir    <= 2'sd0;

            end else begin
                TDC_valid <= 1'b0;
            end
        end
    end

endmodule






