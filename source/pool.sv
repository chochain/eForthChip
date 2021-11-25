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
    MEM0 = 'h0, MEM1 = 'h1, WAIT = 'h2, CMP = 'h3 
} pool_sts;

module pool #(
    parameter DSZ = 32,
    parameter ASZ = 16
    ) (
    input                  clk, /// clock
    input                  rst, /// reset
    input [2:0]            op, /// opcode i.e. enum pool_op
    input [ASZ-1:0]        ai, /// input address
    input [DSZ-1:0]        vi, /// input data
    output logic [1:0]     st, /// state
    output logic           ok, /// 0:not found, 1:found
    output logic [ASZ-1:0] ao, /// output address,
    output logic [DSZ-1:0] vo  /// output data
    );
    logic [ASZ-1:0]        here;       /// dictionary starting address
    logic [ASZ-1:0]        a, a0, a1;  /// string addresses
    logic [DSZ-1:0]        vo0;
    logic                  we;
    logic [3:0]            bmsk;
    cmp_t                  eq;

    spram64k   mem(.clk, .we, .bmsk, .a, .vi, .vo);
    comparator #(32) cmp(.s(1'b0), .a(vo0), .b(vo), .o(eq));
    ///
    /// find - state machine
    ///
    task find(); begin
       case (st)
       MEM0: begin
            if (ai && a1) begin     // idle if a1 == 0
                a  <= a0;           // setup address 0
                a0 <= a0 + 4;
                st <= MEM1;
                ok <= 1'b0;
            end
       end
       MEM1: begin
            a  <= a1;               // setup address 1
            a1 <= a1 + 4;
            st <= WAIT;
            ok <= 1'b0;
       end
       WAIT: begin
            vo0 <= vo;              // fetch str0
            ok  <= 1'b0;
       end
       CMP: begin                  
            if (eq[0:0]) a1 <= 'h0; // idle if a1==0
            ok <= eq[0:0];
            st <= MEM0;
       end
       endcase
    end            
    endtask
    
    always_comb begin
        case (op) 
        NOP:    bmsk = 4'b0000;
        R1: W1: bmsk = 4'b0001;
        R2: W2: bmsk = 4'b0011;
        R4: W4: bmsk = 4'b1111;
        FIND:   bmsk = 4'b1111;
        endcase
        we = op > 'h4;
    end
    
    always_ff @(posedge clk, negedge rst) begin
        if (!rst) begin
            here <= 0;
            a0   <= here;
            a1   <= ai;
            st   <= MEM0;
        end 
        else if (op=='h0) find();
    end
endmodule // pool
`endif // FORTHSUPER_POOL
