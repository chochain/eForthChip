///
/// eForth1 strtol (or atoi) module
///
/*
 * reference C code
 *
int atoi(const char *s, size_t base)
{
    int ret = 0, neg = 0;
 REDO:
    switch(*s) {
    case '-': neg = 1;      // fall through.
    case '+': s++;          break;
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
`ifndef EFORTH1_ATOI
`define EFORTH1_ATOI
`include "../source/eforth1_if.sv"

typedef enum logic { AI0, ACC } atoi_sts;
module atoi #(
    parameter DSZ = 32              /// return 32-bit integer
    ) (
    input                  clk,     /// clock
    input                  en,      /// enable
    input                  hex,     /// 0:decimal, 1:hex
    input [7:0]            ch,      /// input charcter
    output logic           bsy,     /// 1:busy, 0:done
    output logic [DSZ-1:0] vo       /// resultant value
    );
    logic [3:0]            inc;           /// incremental value
    logic                  neg, max, ok;  /// negative and range check flag
    atoi_sts               _st, st;       /// next and current states
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
    assign ok = ch && ~max;
    
    always_comb begin
        case (st)
        AI0: _st = en ? ACC : AI0;
        ACC: _st = ok ? ACC : AI0;   /// accumulator
        default: _st = AI0;
        endcase
    end // always_comb
    ///
    /// next output logic - character range check
    ///
    always_comb begin
        max = 1'b0;
        if (ch inside {["0":"9"]})  inc = {ch - "0"}[3:0];  /// "0" ~ "9"
        else if (hex && ch >= "a")  inc = {ch - "W"}[3:0];  /// "a" ~ "f", "a" - 10 = "W"
        else if (hex && ch >= "A")  inc = {ch - "7"}[3:0];  /// "A" ~ "F", "A" - 10 = "7"
        else                        max = 1'b1;
    end // always_comb
    
    task ADDUP;
        if (hex) vo <= vo << 4 + inc;
        else     vo <= (vo << 3) + (vo << 1) + inc;
    endtask: ADDUP

    task step;
        if (hex) $display(
            "%6t> atoi.%s[%c] %cvo = (%0x)+%0x",
            $time, st.name, ch, neg ? "-" : " ", vo, inc);
        else     $display(
            "%6t> atoi.%s[%c] %cvo = (%0d)+%0d",
            $time, st.name, ch, neg ? "-" : " ", vo, inc);
        case (st)
        AI0: begin
            if (en) begin
                bsy <= 1'b1;
                if (ch == "-") neg <= 1'b1;
                else if (ok) ADDUP();
            end
        end
        ACC: begin
            if (ok && bsy) ADDUP();
            else begin
                bsy <= 1'b0;
                if (neg) begin
                    vo  <= -vo;
                    neg <= 1'b0;
                end
                $display("\t=> atoi done.");
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
    atoi #(DSZ) a2i(.*);

    always_ff @(posedge clk) begin
        mb_if.ai <= en ? mb_if.ai + 1'b1 : tib;
    end // always_ff
endmodule: atoier
`endif // EFORTH1_ATOI
