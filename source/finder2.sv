///
/// eForth1 - Dictionary Word Finder (Latched)
///
`ifndef EFORTH1_FINDER
`define EFORTH1_FINDER
`include "../source/eforth1_if.sv"        /// iBus32 or iBus8 interfaces
typedef enum logic [2:0] { FD0, MEM, LF0, LF1, LEN, NFA, TIB, CMP } finder_sts;
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
    // debug output        
    output                 finder_sts st, /// state: DEBUG
    output logic [ASZ-1:0] ao0,           /// a0: DEBUG, pfa if found
    output logic [ASZ-1:0] ao1            /// a1: DEBUG
    );
    logic [ASZ-1:0]        lfa;           /// link field address (initial=context address)
    logic [ASZ-1:0]        pfa;           /// parameter field address
    logic [DSZ-1:0]        _vw;           /// previous memory value
    finder_sts             _st;           /// next state
    logic [ASZ-1:0]        a0, a1;        /// string addresses
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
    /// Note: one-hot encoding automatically done by synthesizer
    ///
    always_comb begin
        case (st)
        FD0: _st = en ? MEM : FD0;
        MEM: _st = LF0;
        LF0: _st = bsy ? LF1 : FD0;                        // low-byte of lfa
        LF1: _st = LEN;                                    // high-byte of lfa
        LEN: _st = NFA;                                    // word length
        NFA: _st = TIB;                                    // one byte from nfa
        TIB: _st = CMP;                                    // one byte from tib
        CMP: _st = (_vw == vw && a0 != pfa) ? TIB : LF0;   // compare and check word len
        default: _st = FD0;
        endcase
    end
    ///
    /// logic for next output
    /// Note: moved into always_ff latched
    ///
    always_comb begin
        /* do nothing now, all moved into always_ff */
    end
    ///
    /// register values for state machine input
    ///
    task step;
        case (st)
        FD0: begin                  // memory read/write
            if (en) bsy <= 1'b1;    // turn on busy signal
        end
        MEM: begin                  // start driving memory block
            mb_if.we <= 1'b0;
            mb_if.ai <= lfa;        // fetch low-byte of lfa
            a0       <= lfa + 1'b1;
        end
        LF0: begin
            if (bsy) begin
                mb_if.ai <= a0;     // fetch high-byte of lfa
                a0 <= a0 + 1'b1;
            end
        end
        LF1: begin
            mb_if.ai <= a0;         // fetch nfa lenghth byte
            a0 <= a0 + 1'b1;
        end
        LEN: begin
            lfa <= {1'b0, vw, _vw}; // collect lfa
            mb_if.ai <= a0;         // first char of word name
            a0 <= a0 + 1'b1;
        end       
        NFA: begin
            pfa      <= a0 + vw;    // calc pfa
            mb_if.ai <= aw;         // first char of TIB
            a1 <= aw + 1'b1;
        end        
        TIB: begin
            mb_if.ai <= a0;         // next char of word name
            a0 <= a0 + 1'b1;
        end
        CMP: begin                  // compare bytes from nfa and tib
            if (_vw == vw && a0 != pfa) begin
                mb_if.ai <= a1;     // next char of TIB
                a1 <= a1 + 1'b1;
            end
            else if (_vw != vw && lfa == 'h0ffff) begin
                bsy <= 1'b0;        // word found or dictionary exausted
            end
            else begin
                mb_if.ai <= lfa;    // link to next word
                a0 <= lfa + 1'b1;
            end
        end
        endcase
    endtask: step
    ///
    /// logic for current output (registers)
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            lfa <=  aw;            // initial context/dictionary word address
        end
        else begin
            step();                // prepare state machie input
            /// output
            hit <= (_vw == vw);    // flag @ bsy goes low (found pfa is driven mb_if.ai)
            _vw <= vw;             // keep last memory value
            ao0 <= a0;             // debug nfa address
            ao1 <= a1;             // debug tib address
        end
    end
endmodule: finder
`endif // EFORTH1_FINDER
