///
/// ForthSuper stack (FILO)
///
`ifndef FORTHSUPER_STACK
`define FORTHSUPER_STACK
`include "../source/forthsuper_if.sv"
/*
module stack #(
    parameter DSZ   = 32,         /// data bus size
    parameter DEPTH = 16,
    parameter ISZ   = $clog2(DEPTH) - 1
    ) (
    input  logic           clk,   /// clock
    input  logic           we,    /// 1:push, 0:pop
    input  logic [DSZ-1:0] vi,    /// push value
    output logic           e,     /// empty
    output logic           f,     /// full
    output logic [DSZ-1:0] vo     /// return value (top of stack)
    );    
    reg [ISZ:0]   idx;            /// stack index
    reg [DSZ-1:0] ss[DEPTH-1:0];  /// memory block
    
    always_ff @(posedge clk) begin
        if (we) begin
            ss[idx] <= vi;
            idx     <= idx==(DEPTH - 1) ? idx : idx + 1;
            e       <= 0;
            f       <= idx==(DEPTH - 1);
        end
        else begin
            vo      <= ss[idx - 1];
            idx     <= idx ? idx - 1 : 0;
            e       <= (idx==0);
            f       <= 0;
        end
    end
endmodule // stack
//
// bit-slice
//
module stack2 #(
    parameter DSZ   = 32,
    parameter DEPTH = 16
    ) (
    input wire            clk,
    input wire            we,
    input wire [1:0]      delta,
    input wire [DSZ-1:0]  vi,
    output wire [DSZ-1:0] vo
    );
    localparam BITS = (DSZ * DEPTH) - 1;

    reg [DSZ-1:0] tos, _tos;
    reg [BITS:0]  ss,  _ss;
    wire          mv = delta[0];

    assign _tos = we ? vi : ss[DSZ-1:0];
    assign _ss  = delta[1] ? {16'h55aa, ss[BITS:DSZ]} : {ss[BITS-DSZ:0], tos};

    always @(posedge clk) begin
        if (we | mv)
            tos <= _tos;
        if (mv)
            ss <= _ss;
    end

    assign vo = tos;
endmodule
*/
typedef enum logic [1:0] { PUSH, POP, READ } stack_ops;
module stack3 #(
    parameter DEPTH = 64,
    parameter DSZ   = 32,
    parameter SSZ   = $clog2(DEPTH),
    parameter NEG1  = DEPTH - 1
    ) (
    stk_io                 mb_if, /// 32-bit stack bus
    input  logic           clk,   /// clock
    input  logic           rst,   /// reset
    input  logic           en     /// enable
    );
    logic [SSZ-1:0] idx = NEG1, idx_1;   /// idx_1 = index - 1
    ///
    /// instance of EBR Single Port Memory
    ///
    pmi_ram_dq #(DEPTH, SSZ, DSZ, "noreg") data(    /// noreg saves a cycle
        .Data      (mb_if.vi),
        .Address   (mb_if.op == POP ? idx_1 : idx),
        .Clock     (clk),
        .ClockEn   (1'b1),
        .WE        (mb_if.op == PUSH),
        .Reset     (rst),
        .Q         (mb_if.vo)
    );
    assign idx_1 = idx + NEG1;
    ///
    /// using FF implies a pipedline design
    ///
    always_ff @(posedge clk) begin
        if (en) begin
            case (mb_if.op)
            PUSH: begin
                idx <= idx + NEG1;
                $display("stk.push[%x]=%d", idx, mb_if.vi);
            end                
            POP: begin
                idx <= idx_1;
                $display("stk.pop[%x]=%d", idx_1, mb_if.vo);
            end
            endcase            
        end
    end
endmodule: stack3
`endif // FORTHSUPER_STACK
