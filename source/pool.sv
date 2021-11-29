///
/// ForthSuper Memory Pool
///
`ifndef FORTHSUPER_POOL
`define FORTHSUPER_POOL
`include "spram.sv"
enum { R1, W1, FIND } pool_ops;
enum { MEM0, LFA0, LFA1, LEN, NFA, TIB, CMP } pool_sts;

module pool #(
    parameter DSZ = 8,
    parameter ASZ = 17
    ) (
    input                  clk, /// clock
    input                  rst, /// reset
    input [1:0]            op,  /// opcode i.e. enum pool_op
    input [ASZ-1:0]        ai,  /// input address
    input [DSZ-1:0]        vi,  /// input data
    output [DSZ-1:0]       vo,  /// output data (for memory read)
    output logic           we,
    output logic [2:0]     st,  /// state
    output logic           bsy, /// 0:busy, 1:done
    output logic           hit, /// 1:found
    output logic [ASZ-1:0] ao0, /// output address 0:not found, a0: for debugging now
    output logic [ASZ-1:0] ao1  /// a1 for debugging
    );
    logic [ASZ-1:0]        here, ctx;  /// dictionary, context address
    logic [ASZ-1:0]        lfa, pfa;   /// link, parameter field address
    logic [2:0]            _st;        /// next state
    logic [DSZ-1:0]        vo0;        /// previous memory value
    logic [ASZ-1:0]        a, a0, a1;  /// string addresses
    logic _bsy;

    spram8_128k mem(.clk, .we, .a, .vi, .vo);
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (rst) st <= MEM0;
        else     st  <= _st;           // transition to next state
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        MEM0: _st = op==FIND ? LFA0 : MEM0;
        LFA0: _st = _bsy ? LFA1 : MEM0;                     // fetch low-byte of lfa
        LFA1: _st = LEN;                                    // fetch high-byte of lfa
        LEN:  _st = NFA;                                    // read word length
        NFA:  _st = TIB;                                    // read one byte from nfa
        TIB:  _st = CMP;                                    // read one byte from tib
        CMP:  _st = (vo0 != vo || a0 == pfa) ? LFA0 : TIB;  // compare and check word len
        default: _st = MEM0;
        endcase
    end
    ///
    /// logic for next output
    ///
    always_comb begin
        we  = op==W1;
        case (st)
        MEM0: begin                 // memory read/write
            a   = ai;
            a0  = ctx;
            _bsy= op==FIND;
        end
        LFA0: begin                 // fetch low-byte of lfa
            a   = a0;
            a0  = a0 + 1'b1;
        end
        LFA1: begin                 // fetch high-byte of lfa
            a   = a0;
            a0  = a0 + 1'b1;
        end
        LEN: begin                  // fetch nfa length
            lfa = {1'b0, vo, vo0};
            a   = a0;
            a0  = a0 + 1'b1;
        end
        NFA: begin                  // read from nfa
            pfa = a0 + vo;
            a   = a0;
            a1  = ai;
        end
        TIB: begin                  // read from tib
            a   = a1;
            a1  = a1 + 1'b1;
            a0  = a0 + 1'b1;
        end
        CMP: begin                  // compare bytes from nfa and tib
            a  = a0;                // prefetch next nfa
            if (vo0 != vo || a0 == pfa) begin                // done with current word?
                if (vo0 == vo || lfa == 'h0ffff) _bsy = 1'b0; // break on match or no more word
                else a0 = lfa;                                // link to next word
            end
        end
        default: a0 = ctx;          // nop
        endcase
    end
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (rst) begin
            ctx <= 'h2b;            // TODO: hard code for now
        end
        else begin                  // output for next cycle
            hit <= (vo0 == vo);
            bsy <= _bsy;
            vo0 <= vo;
            ao0 <= a0;              // pfa: when !bsy && hit
            ao1 <= a1;              // debug output
        end            
    end
endmodule // pool
`endif // FORTHSUPER_POOL
