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
    MEM0 = 'h0, MEM1 = 'h1, CMP = 'h2, DONE = 'h3
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
    output logic [1:0]     st,  /// state
    output logic           bsy, /// 0:busy, 1:done
    output logic [ASZ-1:0] ao,  /// output address 0:not found
    output logic [ASZ-1:0] ao1
    );
    logic [ASZ-1:0]        here;       /// dictionary starting address
    logic [1:0]            _st;
    logic                  _bsy;
    logic                  _eq;
    logic [DSZ-1:0]        _vo;        /// src memory value
    logic [ASZ-1:0]        a, a0, a1;  /// string addresses
    logic [3:0]            bmsk;
    cmp_t                  eq;

    spram8_128k mem(.clk, .we, .a, .vi, .vo);
    comparator #(8) cmp(.s(1'b0), .a(_vo), .b(vo), .o(eq));
    ///
    /// find - 4-always state machine (Cummings & Chambers)
    ///
    always_ff @(posedge clk, posedge rst) begin // clocked present state
        if (rst) st <= MEM0;
        else begin
            st  <= _st;
            bsy <= _bsy;
        end
    end
    
    always_comb begin   // logic for next state (state diagram)
        case (st)
        MEM0: _st = (op==FIND && _bsy) ? MEM1 : MEM0;
        MEM1: _st = CMP;
        CMP:  _st = eq[0:0] ? (_vo==0 ? DONE : MEM1) : DONE;
        DONE: _st = MEM0;
        endcase
    end
    
    always_comb begin  // logic for next output
        we   = op==W1;
        _eq  = eq[0:0];
        _bsy = 1'b1;
        _vo  = vo;
        case (st)
        MEM0: begin 
            a  = ai;        
            a1 = ai + 1;
            a0 = here;
        end
        MEM1: begin 
            a  = a0;
            a0 = a0 + 1;
        end
        CMP:  begin 
            a  = a1;
            a1 = a1 + 1;
        end
        DONE: _bsy = 1'b0;
        endcase
    end
    
    always_ff @(posedge clk, posedge rst) begin  // logic for current output
        if (rst) begin
            here <= 0;
        end
        else begin
            ao  <= a0; //(_eq && !_bsy) ? a0 : 'h0;
            ao1 <= a1;
        end            
    end
endmodule // pool
`endif // FORTHSUPER_POOL
