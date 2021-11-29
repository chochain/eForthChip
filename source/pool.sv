///
/// ForthSuper Memory Pool
///
`ifndef FORTHSUPER_POOL
`define FORTHSUPER_POOL
`include "comparator.sv"
`include "spram.sv"
enum { 
    NOP  = 'h0, R1 = 'h1, R2 = 'h2, R4 = 'h3,
    FIND = 'h4, W1 = 'h5, W2 = 'h6, W4 = 'h7
} pool_ops;
enum {
    MEM0 = 'h0, LFA0 = 'h1, LFA1 = 'h2, LEN  = 'h3, 
    WORD = 'h4, TIB  = 'h5, CMP  = 'h6
} pool_sts;

module pool #(
    parameter DSZ = 8,
    parameter ASZ = 17
    ) (
    input                  clk, /// clock
    input                  rst, /// reset
    input [2:0]            op,  /// opcode i.e. enum pool_op
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
    logic [ASZ-1:0]        here, ctx;  /// dictionary starting address
    logic [2:0]            _st;
    logic [DSZ-1:0]        _vo;        /// src memory value
    logic [ASZ-1:0]        a, a0, a1;  /// string addresses
    logic [ASZ-1:0]        lfa, pfa;
    cmp_t                  eq;

    spram8_128k mem(.clk, .we, .a, .vi, .vo);
    ///
    /// find - 4-always state machine (Cummings & Chambers)
    ///
    always_ff @(posedge clk) begin // clocked present state
        if (rst) st <= MEM0;       // synchronous reset (TODO: asyn)
        else     st <= _st;        // transition to next state
    end
    
    always_comb begin   // logic for next state (state diagram)
        case (st)
        MEM0: _st = op==FIND ? LFA0 : MEM0;
        LFA0: _st = bsy ? LFA1 : MEM0;                      // fetch low-byte of LFA
        LFA1: _st = LEN;                                    // fetch high-byte of LFA
        LEN:  _st = WORD;                                   // read word length
        WORD: _st = TIB;                                    // read one byte from word 
        TIB:  _st = CMP;                                    // read one byte from TIB
        CMP:  _st = (_vo != vo || a0 == pfa) ? LFA0 : TIB; // compare and check word len
        default: _st = MEM0;
        endcase
    end
    
    always_comb begin   // logic for next output
        we  = op==W1;
        case (st)
        MEM0: begin
            a   = ai;
            a0  = ctx;
            bsy = op==FIND;
        end
        LFA0: begin
            a   = a0;
            a0  = a0 + 1;
        end
        LFA1: begin
            a   = a0;
            a0  = a0 + 1;
        end
        LEN: begin
            lfa = {1'b0, vo, _vo};
            a   = a0;
            a0  = a0 + 1;
        end
        WORD: begin
            pfa= a0 + vo;
            a  = a0;
            a1 = ai;
        end
        TIB: begin
            a  = a1;
            a1 = a1 + 1;
            a0 = a0 + 1;
        end
        CMP: begin
            a  = a0;
            if (_vo != vo || a0 == pfa) begin                // done with current word
                if (_vo == vo || lfa == 'hffff) bsy = 1'b0;  // break on match or no more word
                else a0 = lfa;                               // point to next word
            end
        end
        default: a0 = ctx;          // nop
        endcase
    end
    
    always_ff @(posedge clk) begin  // logic for current output
        if (rst) begin              // synchronous reset (TODO: async)
            ctx <= 'h2b;
        end
        else begin                  // output for next cycle
            hit <= _vo == vo;
            _vo <= vo;
            ao0 <= a0;              // PFA: when !bsy && hit
            ao1 <= a1;
        end            
    end
endmodule // pool
`endif // FORTHSUPER_POOL
