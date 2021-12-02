///
/// ForthSuper strtol (or atoi) module
///
`ifndef FORTHSUPER_ATOI
`define FORTHSUPER_ATOI
`include "comparator.sv"
typedef enum logic [2:0] { INI, SGN, NEG, DC0, DC9, HX0, SUM, RET } atoi_sts;

module atoi #(
    parameter DSZ = 32,
    parameter ASZ = 17
    ) (
    input                  clk, /// clock
    input                  rst, /// reset
    input                  en,  /// enable
    input                  hex, /// 0:decimal, 1:hex
    input [7:0]            ch,  /// input charcter
    output atoi_sts        st,  /// DEBUG: state
    output logic           bsy, /// 1:busy, 0:done
    output logic           ao,  /// advance address
    output logic [DSZ-1:0] vo   /// output value (for memory read)
    );
    localparam NA = 5'b10000;    /// not avilable
    atoi_sts               _st;  /// next state
    logic [7:0]            cx;   ///char to match
    logic [4:0]            inc;
    logic                  neg;
    cmp_t                  cv;

    comparator  cmp(.s(1'b0), .a(ch), .b(cx), .o(cv));
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (rst) st <= INI;
        else     st <= _st;
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        INI: _st = en ? SGN : INI;
        SGN: _st = cv.eq ? NEG : DC0;
        NEG: _st = DC0;                             // wait for one extra memory cycle
        DC0: _st = cv.lt ? SUM : DC9;               // if (ch < '0') quit
        DC9: _st = cv.le ? SUM : (hex ? HX0 : RET); 
        HX0: _st = SUM;
        SUM: _st = (inc!=NA || cv.ge) ? DC0 : RET;  // if 
        RET: _st = INI;
        default: _st = INI;
        endcase
    end
    ///
    /// logic for input character range check
    ///
    always_comb begin
        cx = "0";
        ao = 'h0;
        case (st)
        SGN: begin cx = "-"; ao = cv.eq; end  // if (ch == '-') advance address by 1
        DC0: cx = "0";
        DC9: begin cx = "9"; ao = 1'b1;  end  // ch <= '9', prefetch next char
        HX0: cx = "a";                        // ch >= 'a'
        SUM: cx = "A";
        endcase
    end
    
    task step(); begin
        case (st)
        INI: bsy <= en;
        SGN: neg <= cv.eq;
        DC0: inc <= NA;
        DC9: if (cv.le) inc <= ch - "0";
        HX0: inc <= ch - (cv.ge ? "W" : "7"); // "a" - 10 = "W", "A" - 10 = "7"
        SUM: if (ch) begin
            vo <= vo * (hex ? 16 : 10) + (inc<NA ? inc : 1'b0);
        end
        RET: begin
            bsy <= 1'b0;
            vo  <= neg ? -vo : vo;
        end
        endcase // case (st)
    end
    endtask
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (rst) begin
            vo  <= 'h0;
            neg <= 1'b0;
        end
        else step();
    end
endmodule // atoi
`endif // FORTHSUPER_ATOI
