///
/// ForthSuper - Dictionary Word Finder
///
`ifndef FORTHSUPER_FINDER
`define FORTHSUPER_FINDER
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces
typedef enum logic [2:0] { MEM, LF0, LF1, LEN, NFA, TIB, CMP } finder_sts;
module finder #(
    parameter DSZ = 8,                    /// 8-bit data path
    parameter ASZ = 17                    /// 128K address path
    ) (
    interface              mb_if,         /// generic master to drive memory block
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
        if (!en) st <= MEM;
        else     st <= _st;
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        MEM: _st = en ? LF0 : MEM;
        LF0: _st = bsy ? LF1 : MEM;                        // fetch low-byte of lfa
        LF1: _st = LEN;                                    // fetch high-byte of lfa
        LEN: _st = NFA;                                    // read word length
        NFA: _st = TIB;                                    // read one byte from nfa
        TIB: _st = CMP;                                    // read one byte from tib
        CMP: _st = (_vw != vw || a0 == pfa) ? LF0 : TIB;   // compare and check word len
        default: _st = MEM;
        endcase
    end
    ///
    /// logic for memory access
    /// Note: one-hot encoding automatically done by synthesizer
    ///
    always_comb begin
        mb_if.we = 1'b0;
        case (st)
        MEM: mb_if.ai = aw;        // memory read/write
        LF0: mb_if.ai = a0;        // fetch low-byte of lfa
        LF1: mb_if.ai = a0;        // fetch high-byte of lfa
        LEN: mb_if.ai = a0;        // fetch nfa length
        NFA: mb_if.ai = a0;        // read from nfa
        TIB: mb_if.ai = a1;        // read from tib
        CMP: mb_if.ai = a0;        // read next nfa, loop back to TIB
        default: mb_if.ai = aw;
        endcase
    end
    ///
    /// register values for state machine input
    ///
    task step;
        case (st)
        MEM: begin                  // memory read/write
            a0  <= lfa;             // low-byte of lfa
            bsy <= en;              // turn on busy signal
        end
        LF0: a0 <= a0 + 1'b1;       // high-byte of lfa
        LF1: a0 <= a0 + 1'b1;       // nfa length byte
        LEN: begin                  // fetch nfa length
            lfa <= {1'b0, vw, _vw}; // collect lfa
            a0  <= a0 + 1'b1;       // first byte of nfa
        end       
        NFA: begin                  // read from nfa
            pfa <= a0 + vw;         // calc pfa
            a1  <= aw;              // first byte of tib
        end        
        TIB: a0 <= a0 + 1'b1;       // next byte of nfa
        CMP: begin                  // compare bytes from nfa and tib
            if (_vw != vw || a0 == pfa) begin                 // done with current word?
                if (_vw == vw || lfa == 'h0ffff) bsy <= 1'b0; // break on match or no more word
                else a0 <= lfa;                               // link to next word
            end
            else a1  <= a1 + 1'b1;  // ready for next tib (here vs TIB: timing look nicer)
        end    
        endcase
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            lfa <=  aw;            // initial context (dictionary word address)
        end
        else begin
            step();                // prepare state machie input
            /// output
            hit <= (_vw == vw);    // memory matched
            _vw <= vw;             // keep last memory value
            ao0 <= a0;             // pfa: when !bsy && hit
            ao1 <= a1;             // debug output
        end
    end
endmodule: finder
`endif // FORTHSUPER_FINDER
