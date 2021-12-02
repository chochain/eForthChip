///
/// ForthSuper strtol (or atoi) module
///
/*
 * reference C code
 * 
int atoi(const char *s, size_t base)
{
    int ret = 0, neg = 0;
 REDO:
    switch(*s) {
    case '-': neg = 1;		// fall through.
    case '+': s++;	        break;
    case ' ': s++;          goto REDO;
    }
    char ch;
    int  n;
    while ((ch = *s++) != '\0') {
        if ('0' <= ch && ch <= '9') n = ch - '0';
        else if (ch >= 'a') n = ch - 'a' + 10;
        else if (ch >= 'A') n = ch - 'A' + 10;
        else break;

        if (n >= base) break;

        ret = ret * base + n;
    }
    return (neg) ? -ret : ret;
}
*/
`ifndef FORTHSUPER_ATOI
`define FORTHSUPER_ATOI
typedef enum logic [1:0] { INI, MEM, ACC } atoi_sts;

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
    logic [4:0]            inc;  /// incremental value
    logic                  neg;  /// negative flag
    atoi_sts               _st;  /// next state
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
        INI: _st = en ? (ch == "-" ? MEM : ACC) : INI;    /// look for negative number
        MEM: _st = bsy ? ACC : INI;                       /// one extra memory cycle wait
        ACC: _st = MEM;                                   /// accumulator
        default: _st = INI;
        endcase
    end
    ///
    /// logic for input character range check
    ///
    always_comb begin
        ao  = 1'b0;
        inc = NA;
        case (st)
        INI: if (en && (ch == "-")) ao = 1'b1;            /// handle negative number
        ACC: begin
            ao = 1'b1;                                    /// prefetch next byte
            if ("0" <= ch && ch <= "9") inc = ch - "0";  
            else if (ch >= "a") inc = ch - "W";           /// "a" - 10 = "W"
            else if (ch >= "A") inc = ch - "7";           /// "A" - 10 = "7"
        end
        endcase
    end // always_comb
    
    task step(); begin
        case (st)
        INI: begin
            bsy <= en;
            neg <= (ch == "-");
        end
        ACC: begin
            if (ch && inc < NA)
                vo  <= vo * (hex ? 16 : 10) + inc;
            else begin
                bsy <= 1'b0;
                if (neg) vo <= -vo;
            end
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
