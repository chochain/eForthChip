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
`include "../source/forthsuper_if.sv"
typedef enum logic [1:0] { AI0, GET, ACC } atoi_sts;
module atoi #(
    parameter DSZ = 32              /// return 32-bit integer
    ) (
    input                  clk,     /// clock
    input                  en,      /// enable
    input                  hex,     /// 0:decimal, 1:hex
    input [7:0]            ch,      /// input charcter
    output logic           bsy,     /// 1:busy, 0:done
    output logic           af,      /// address advance flag (a = a + 1)
    output logic [DSZ-1:0] vo       /// resultant value
    );
    localparam NA = 5'b10000;       /// not avilable
    logic [4:0]            inc;     /// incremental value
    logic                  neg;     /// negative flag
    atoi_sts               _st, st; /// next and current states
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) st <= AI0;
        else     st <= _st;
    end // always_ff
    ///
    /// logic for next state (state diagram)
    /// Note: two cycle per digit. TODO: one cycle per digit
    ///
    always_comb begin
        case (st)
        AI0: _st = en ? (ch == "-" ? GET : ACC) : AI0;    /// look for negative number
        GET: _st = bsy ? ACC : AI0;                       /// one extra memory cycle wait
        ACC: _st = GET;                                   /// accumulator
        default: _st = AI0;
        endcase
    end // always_comb
    ///
    /// next output logic - character range check
    ///
    always_comb begin
        af  = 1'b0;
        inc = NA;
        case (st)
        AI0: if (en && (ch == "-")) af = 1'b1;            /// handle negative number
        ACC: begin
            af = 1'b1;                                    /// prefetch next byte
            if ("0" <= ch && ch <= "9") inc = ch - "0";  
            else if (ch >= "a") inc = ch - "W";           /// "a" - 10 = "W"
            else if (ch >= "A") inc = ch - "7";           /// "A" - 10 = "7"
            else af = 1'b0;
        end
        endcase
    end // always_comb
    
    task step;
        case (st)
        AI0: begin
            bsy <= en;
            neg <= (ch == "-");
        end
        ACC: begin
            if (ch && inc < NA) begin
                bsy <= 1'b1;
                vo  <= vo * (hex ? 16 : 10) + inc;
                $display("t%0d: atoi(%c) vo = %0d * %0d + %0d", $time, ch, vo, hex ? 16 : 10, inc);
            end
            else begin
                bsy <= 1'b0;
                if (neg) vo <= -vo;
                $display("t%0d: atoi done. result vo = %0d", $time, vo);
            end
        end
        endcase // case (st)
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            vo  <= 'h0;
            neg <= 1'b0;
        end
        else step();
    end
endmodule: atoi
///
/// bus master wrapper for atoi module
///
module atoier #(
    parameter ASZ = 17,
    parameter DSZ = 32            /// return 32-bit integer
    ) (
    mb8_io                 mb_if, /// memory bus driver
    input                  clk,   /// clock
    input                  en,    /// enable
    input                  hex,   /// 0:decimal, 1:hex
    input [ASZ-1:0]        tib,   /// input char starting address
    input [7:0]            ch,    /// character fetched from memory
    output logic           bsy,   /// 1:busy, 0:done
    output logic [DSZ-1:0] vo     /// resultant value
    );
    logic af;                     /// address advance flag (a = a + 1)
    
    atoi #(DSZ) a2i(.*);

    always_ff @(posedge clk) begin
        if (!en) mb_if.ai <= tib;
        else begin
            mb_if.ai <= mb_if.ai + af;   // two cycles per digit. TODO: one cycle
            //$display("atoi.ai=%x + %x", mb_if.ai, af);
        end
    end // always_ff
endmodule: atoier
`endif // FORTHSUPER_ATOI
