///
/// ForthSuper - Dictionary Word Finder
///
`ifndef FORTHSUPER_FINDER
`define FORTHSUPER_FINDER
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces

`define DIC_NEXT  a0 <= a0 + 1'b1
`define TIB_NEXT  a1 <= a1 + 1'b1

typedef enum logic [2:0] { FD0, SPC, LF0, LF1, LEN, NFA, CMP } finder_sts;
module finder #(
    parameter DSZ = 8,                    /// 8-bit data path
    parameter ASZ = 17                    /// 128K address path
    ) (
    mb8_io                 mb_if,         /// generic master to drive memory block
    input                  clk,           /// clock
    input                  en,            /// enable
    input [ASZ-1:0]        aw,            /// address of word to find (or intial context)
    input [DSZ-1:0]        vw,            /// value fetched from memory block
    output logic           bsy,           /// 0:busy, 1:done
    output logic           hit,           /// 0:missed, 1:found
    output logic [ASZ-1:0] tib            /// next byte of tib address
    );
    logic [ASZ-1:0]        lfa;           /// link field address (initial=context address)
    logic [DSZ-1:0]        v0;            /// previous memory value
    logic [ASZ-1:0]        a0, a1;        /// dic, tib pointers
    logic [ASZ-1:0]        ax;            /// a0 address + len
    logic                  eq;            /// char pointer within word length
    finder_sts             _st, st;       /// next state
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) st <= FD0;
        else     st <= _st;
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        eq = (v0 == vw);                             // chars match input vs word
        case (st)
        FD0: _st = en ? LF0 : FD0;
        SPC: _st = LF0;                              // skip TIB space
        LF0: _st = bsy && v0                         // fetch low-byte of lfa
                   ? (v0 == " " ? SPC : LF1) : FD0;
        LF1: _st = LEN;                              // fetch high-byte of lfa
        LEN: _st = NFA;                              // read word length
        NFA: _st = CMP;                              // read one byte from nfa
        CMP: _st = (eq && a0 <= ax) ? NFA : LF0;     // fetch next chars if match
        default: _st = FD0;
        endcase
    end
    ///
    /// logic for memory access
    /// Note: one-hot encoding automatically done by synthesizer
    ///
    always_comb begin
        mb_if.we = 1'b0;
        case (st)
        FD0: mb_if.ai = aw;        // memory read/write
        SPC: mb_if.ai = a1;        // skip TIB space
        LF0: mb_if.ai = a0;        // fetch low-byte of lfa
        LF1: mb_if.ai = a0;        // fetch high-byte of lfa
        LEN: mb_if.ai = a0;        // fetch nfa length
        NFA: mb_if.ai = a0;        // read from nfa
        CMP: mb_if.ai = a1;        // read next nfa, loop back to TIB
        default: mb_if.ai = aw;
        endcase
    end
    ///
    /// register values for state machine input
    ///
    task step;
        $display(
            "%06t> finder.%s[%02x] tib[%2x],dic[%04x]",
            $time, st.name, vw, a1, a0);
        case (st)
        FD0: begin                  // memory read/write
            a0  <= lfa;             // low-byte of lfa
            a1  <= aw;              // setup tib address
            tib <= aw;
            bsy <= en && vw;        // turn on busy signal
        end
        SPC: tib <= a1;             // blank char, advance TIB
        LF0: begin
            if (v0 == " ") `TIB_NEXT; // space, skip
            else `DIC_NEXT;           // high-byte of lfa
        end
        LF1: begin
            `DIC_NEXT;              // nfa length byte
            lfa <= {1'b0, vw, v0};  // construct new lfa
        end
        LEN: begin                  // fetch nfa length
            `DIC_NEXT;              // first byte of nfa
            ax <= a0 + vw;          // calc a0 + len (string stop)
        end
        NFA: `DIC_NEXT;             // next byte of nfa
        CMP: begin                  // compare bytes from nfa and tib
            if (vw == 0) bsy <= 1'b0;                  // input buffer empty
            else if (eq && a0 <= ax) `TIB_NEXT;        // next char TIB input
            else if (eq || lfa == 'h0ffff) begin       // all chars matched or dictionary exhaused
                bsy <= 1'b0;                           // break on match or no more word
                tib <= a1 + eq;                        // move tib cursor to next input (or not)
                hit <= eq;                             // word found in dictionary
                $display(
                    "\t=>%s, next tib[%02x],a0[%04x]",
                    eq ? "HIT" : "MISS", a1 + eq, a0);
            end
            else begin
                a0 <= lfa;          // link to next dictionary word
                a1 <= tib;          // reset TIB input pointer
                $display("\t=> next word tib[%2x],lfa[%04x]", tib, lfa);
            end
        end
        endcase
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        v0 <= vw;                  // keep last memory value
        if (!en) begin
            lfa <=  aw;            // reset context address (dictionary word address)
            hit <= 1'b0;
        end
        else step();               // prepare state machie input
    end
endmodule: finder
`endif // FORTHSUPER_FINDER
