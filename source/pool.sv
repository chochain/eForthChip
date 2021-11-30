///
/// ForthSuper Memory Pool
///
`ifndef FORTHSUPER_POOL
`define FORTHSUPER_POOL
`include "spram.sv"
///
/// forced one-hot encoding => 316 LUTs (7 lines into 5 MUXs)
///
//typedef enum logic [2:0] { R1, W1, FIND } pool_ops;
//typedef enum logic [6:0] { MEM, LF0, LF1, LEN, NFA, TIB, CMP } pool_sts;
///
/// automatic one-hot encoding => 261 LUTs (4 lines into 6 MUXs)
///
typedef enum logic [1:0] { R1, W1, FIND } pool_ops;
typedef enum logic [2:0] { MEM, LF0, LF1, LEN, NFA, TIB, CMP } pool_sts;

module pool #(
    parameter DSZ = 8,
    parameter ASZ = 17
    ) (
    input                  clk, /// clock
    input                  rst, /// reset
    pool_ops               op,  /// opcode i.e. enum pool_op
    input [ASZ-1:0]        ai,  /// input address
    input [DSZ-1:0]        vi,  /// input data
    output [DSZ-1:0]       vo,  /// output data (for memory read)
    output logic           we,
    output logic           bsy, /// 0:busy, 1:done
    output logic           hit, /// 0:missed, 1:found
    output pool_sts        st,  /// state: DEBUG
    output logic [ASZ-1:0] ao0, /// a0: DEBUG, pfa if found
    output logic [ASZ-1:0] ao1  /// a1: DEBUG
    );
    logic [ASZ-1:0]        here, ctx;  /// dictionary, context address
    logic [ASZ-1:0]        lfa, pfa;   /// link, parameter field address
    logic [DSZ-1:0]        _vo;        /// previous memory value
    pool_sts               _st;        /// next state
    logic [ASZ-1:0]        ma, a0, a1; /// string addresses

    spram8_128k mem(.clk, .we, .a(ma), .vi, .vo);
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (rst) st <= MEM;
        else     st <= _st;
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        MEM: _st = op==FIND ? LF0 : MEM;
        LF0: _st = bsy ? LF1 : MEM;                       // fetch low-byte of lfa
        LF1: _st = LEN;                                    // fetch high-byte of lfa
        LEN: _st = NFA;                                    // read word length
        NFA: _st = TIB;                                    // read one byte from nfa
        TIB: _st = CMP;                                    // read one byte from tib
        CMP: _st = (_vo != vo || a0 == pfa) ? LF0 : TIB;   // compare and check word len
        default: _st = MEM;
        endcase
    end
    ///
    /// logic for memory access
    /// Note: one-hot encoding automatically done by synthesizer
    ///
    always_comb begin
        we = op==W1;
        case (st)
        MEM: ma = ai;               // memory read/write
        LF0: ma = a0;               // fetch low-byte of lfa
        LF1: ma = a0;               // fetch high-byte of lfa
        LEN: ma = a0;               // fetch nfa length
        NFA: ma = a0;               // read from nfa
        TIB: ma = a1;               // read from tib
        CMP: ma = a0;               // read next nfa, loop back to TIB
        default: ma = ai;           // nop
        endcase
    end
    ///
    /// register values for state machine input
    ///
    task step(); begin
        case (st)
        MEM: begin                  // memory read/write
            a0  <= ctx;             // low-byte of lfa
            bsy <= op==FIND;        // turn on busy signal
        end
        LF0: a0 <= a0 + 1'b1;       // high-byte of lfa
        LF1: a0 <= a0 + 1'b1;       // nfa length byte
        LEN: begin                  // fetch nfa length
            lfa <= {1'b0, vo, _vo}; // collect lfa
            a0  <= a0 + 1'b1;       // first byte of nfa
        end       
        NFA: begin                  // read from nfa
            pfa <= a0 + vo;         // calc pfa
            a1  <= ai;              // first byte of tib
        end        
        TIB: a0 <= a0 + 1'b1;       // next byte of nfa
        CMP: begin                  // compare bytes from nfa and tib
            if (_vo != vo || a0 == pfa) begin                 // done with current word?
                if (_vo == vo || lfa == 'h0ffff) bsy <= 1'b0; // break on match or no more word
                else a0 <= lfa;                                // link to next word
            end
            else a1  <= a1 + 1'b1;  // ready for next tib (here vs TIB: timing look nicer)
        end    
        endcase
    end
    endtask
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (rst) begin
            ctx <=  'h2b;           // TODO: hard code for now
        end
        else begin
            step();                // prepare state machie input
            /// output
            hit <= (_vo == vo);    // memory matched
            _vo <= vo;             // keep last memory value
            ao0 <= a0;             // pfa: when !bsy && hit
            ao1 <= a1;             // debug output
        end
    end
endmodule // pool
`endif // FORTHSUPER_POOL
