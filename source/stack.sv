///
/// ForthSuper stack (FILO)
///
`ifndef FORTHSUPER_STACK
`define FORTHSUPER_STACK
`include "../source/forthsuper_if.sv"

module stack #(
    parameter DEPTH = 64,
    parameter DSZ   = 32
    ) (
    ss_io           ss_if,         /// 32-bit stack bus
    input  logic    clk,           /// clock
    input  logic    en             /// enable
    );
    localparam SSZ  = $clog2(DEPTH);
    localparam NEG1 = DEPTH - 1;
    logic [DSZ-1:0] v0;
    ///
    /// instance of EBR Single Port Memory
    ///
    pmi_ram_dq #(DEPTH, SSZ, DSZ, "noreg") ss (    /// noreg saves a cycle
        .Data      (ss_if.vi),
        .Address   (ss_if.op == SS_PUSH ? ss_if.sp + 'h1 : ss_if.sp),
        .Clock     (~clk),
        .ClockEn   (en),
        .WE        (ss_if.op == SS_PUSH),
        .Reset     (~en),
        .Q         (v0)
    );
    task ss_update;
        case (ss_if.op)
        SS_PUSH: begin
            ss_if.sp <= ss_if.sp + 'h1;   // write to stack[sp+1]
            ss_if.s0 <= ss_if.vi;         // cached s0
        end
        SS_POP:  begin
            ss_if.sp <= ss_if.sp + NEG1;
            ss_if.s0 <= v0;
        end
        endcase
    endtask: ss_update
    
    always_ff @(negedge clk) begin
        if (en) ss_update;
        ss_if.op <= SS_LOAD;
    end
endmodule: stack

///
/// Pseudo Dual-port stack (using EBR)
///
/*
module stack #(
    parameter DEPTH = 64,
    parameter DSZ   = 32,
    parameter SSZ   = $clog2(DEPTH),
    parameter NEG1  = DEPTH - 1
    ) (
    ss_io           ss_if,           /// 32-bit stack bus
    input  logic    clk,             /// clock
    input  logic    rst,             /// reset
    input  logic    en               /// enable
    );
    logic [SSZ-1:0] sp = 'h0;
    logic [DSZ-1:0] vo;
    pmi_ram_dp #(
       .pmi_wr_addr_depth(DEPTH),
       .pmi_wr_addr_width(SSZ),
       .pmi_wr_data_width(DSZ),
       .pmi_rd_addr_depth(DEPTH),
       .pmi_rd_addr_width(SSZ),
       .pmi_rd_data_width(DSZ),
       .pmi_regmode("noreg")         // "reg"|"noreg"
       //.pmi_resetmode        ( ),  // "async"|"sync"
       //.pmi_init_file        ( ),  // string
       //.pmi_init_file_format ( ),  // "binary"|"hex"
       //.pmi_family           ( )   // "iCE40UP"|"common"
    ) ss (
       .Data      (ss_if.vi),  // value to push
       .WrAddress (sp + 1'b1), // TOS if push
       .RdAddress (sp),        // NOS pointer
       .WrClock   (clk),
       .RdClock   (clk),
       .WrClockEn (1'b1),
       .RdClockEn (1'b1),
       .WE        (ss_if.op == PUSH),
       .Reset     (rst),
       .Q         (vo)
    );
    assign ss_if.s = vo;        // return, 2 cycles later

    always_ff @(posedge clk) begin
        //automatic string op = FS1::Enum2str#(stack_ops)::to_s(ss_if.op);
        $display("%6d: %0s sp=%0d s=%0d ? (vi=%0d : vo=%0d)",
            $time, ss_if.op.name(), sp, $signed(ss_if.s), $signed(ss_if.vi), $signed(vo));
        if (en) begin
            case (ss_if.op)
            PUSH: sp <= sp + 1'b1;
            POP:  sp <= sp + NEG1;
            endcase
        end
    end
endmodule: stack
*/
///
/// Dual-port stack (iCE40UP5K does not have True RAM_DP, so we use LUT-based, expensive)
///
/*
module dstack #(
    parameter DEPTH = 16,
    parameter DSZ   = 32,
    parameter SSZ   = $clog2(DEPTH),
    parameter NEG1  = DEPTH - 1
    ) (
    ss_io           ss_if,           /// 32-bit stack bus
    input  logic    clk,             /// clock
    input  logic    rst,             /// reset
    input  logic    en               /// enable
    );
    logic [SSZ-1:0] sp1, sp = 'h0;   /// sp1 = sp + 1
    logic [DSZ-1:0] ram[DEPTH-1:0];  /// memory block

    always_comb begin
        ss_if.s = ram[sp];           /// fetch first
        sp1     = sp + 1'b1;
    end

    always_ff @(posedge clk) begin
        if (en) begin
            case (ss_if.op)
            PUSH: begin
                ram[sp1] <= ss_if.vi;
                sp       <= sp1;
            end
            POP: sp <= sp + NEG1;
            endcase
        end
    end
endmodule: dstack
*/
`endif // FORTHSUPER_STACK
