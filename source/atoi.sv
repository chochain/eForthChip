///
/// ForthSuper strtol (or atoi) module
///
`ifndef FORTHSUPER_ATOI
`define FORTHSUPER_ATOI
`include "comparator.sv"
typedef enum logic [2:0] { INI, SGN, BSE, CHR, HX0, HX1, DEC, RST } atoi_sts;

module atoi #(
    parameter DSZ = 32,
    parameter ASZ = 17
    ) (
    input                  clk, /// clock
    input                  rst, /// reset
    input                  en,  /// enable
    input [ASZ-1:0]        ai, /// input address
    input [7:0]            ch,
    output atoi_sts        st, /// state: DEBUG
    output logic           bsy, /// 0:busy, 1:done
    output logic [ASZ-1:0] ao, /// endptr
    output logic [DSZ-1:0] vo    /// DEBUG: output data (for memory read)
    );
    atoi_sts               _st;  /// next state
    logic [7:0]            _ch;  /// char fetch and char to match
    logic [3:0]            inc;
    logic                  neg;
    logic                  hex;
    cmp_t                  cv;

    comparator  cmp(.s(1'b0), .a(ch), .b(_ch), .o(cv));
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
        SGN: _st = BSE;
        BSE: _st = CHR;
        CHR: _st = ch ? (cv.ge ? DEC : HX0) : RST;
        HX0: _st = cv.ge ? DEC : HX1;
        HX1: _st = cv.lt ? RST : DEC;
        DEC: _st = cv.gt ? RST : CHR;
        RST: _st = INI;
        default: _st = INI;
        endcase
    end
    ///
    /// logic for memory access
    ///
    always_comb begin
        _ch = "x";
        case (st)
        SGN: _ch = "-";    // ch == '-'
        BSE: _ch = "$";    // ch == '$'
        CHR: _ch = "a";    // ch >= 'a'
        HX0: _ch = "A";    // ch >= 'A'
        HX1: _ch = "0";    // ch <  '0'
        DEC: _ch = "9";    // ch <= '9'
        endcase
    end
    
    task step(); begin
        case (st)
        INI: bsy <= en;
        SGN: begin
            if (cv.eq) begin
                neg <= 1'b1;
                ao  <= ao + 1'b1;
            end
        end
        BSE: begin
            if (cv.eq) begin
                hex <= 1'b1;
                ao  <= ao + 1'b1;
            end
        end
        CHR: begin
            inc <= cv.ge ? ch - "a" + 10 : 1'b0;
            ao  <= ao + 1'b1;
        end
        HX0: inc <= cv.ge ? ch - "A" + 10 : 1'b0;
        DEC: begin
            vo <= (hex ? vo<<4 : (vo << 3) + (vo << 1))
                   + (inc ? inc : ch - "0");
        end
        RST: begin
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
            ao  <= ai;
            vo  <= 'h0;
            hex <= 1'b0;
            neg <= 1'b0;
        end
        else step();
    end
endmodule // atoi
`endif // FORTHSUPER_ATOI
