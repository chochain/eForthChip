///
/// ForthSuper common interfaces
///
`ifndef FORTHSUPER_FORTHSUPER_IF
`define FORTHSUPER_FORTHSUPER_IF

typedef enum logic [1:0] {
    SS_LOAD = 2'b0, SS_PUSH = 2'b01, SS_POP = 2'b10, SS_ALU = 2'b11 
} sop_e;

interface mb32_io #(
    parameter ASZ=15,
    parameter DSZ=32
    )(input logic clk);
    logic        we;
    logic [3:0]  bmsk;
    logic [ASZ-1:0] ai;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;

    clocking ioDrv @(posedge clk);
        default input #1 output #1;
    endclocking // ioMaster

    modport master(clocking ioDrv, output we, bmsk, ai, vi);
    modport slave(clocking ioDrv, input we, bmsk, ai, vi, output vo);
endinterface: mb32_io

interface mb8_io #(
    parameter ASZ=17,
    parameter DSZ=8);
    logic we;
    logic [ASZ-1:0] ai;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;

    modport master(output we, ai, vi, import put_u8, get_u8);
    modport slave(input we, ai, vi, output vo);

    function void put_u8([ASZ-1:0] ax, [DSZ-1:0] vx);
        we = 1'b1;
        ai = ax;
        vi = vx;
    endfunction: put_u8

    function void get_u8([ASZ-1:0] ax);
        we = 1'b0;
        ai = ax;
        // return vo
    endfunction: get_u8
endinterface : mb8_io

interface ss_io #(
    parameter DEPTH = 64,
    parameter DSZ   = 32);
    localparam SSZ  = $clog2(DEPTH);
    localparam NEG1 = DEPTH - 1;
    sop_e           op;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] s0, tos = -1;
    logic [SSZ-1:0] sp = 0;

    modport master(output op, vi, import load, push, pop, alu);
    modport slave(input op, vi, output sp, s0, tos);

    function void load(input [DSZ-1:0] v);
        op  <= SS_LOAD;
        tos <= v;          // update tos
        $display(
            "%6t> ss_if.load(%0d) => tos:ss[%2x]<%0d,%0d>", 
            $time, v, ss_if.sp, ss_if.tos, ss_if.s0);
    endfunction: load
    
    function void push(input [DSZ-1:0] v);
        op  <= SS_PUSH;
        vi  <= tos;        // push tos onto stack[sp+1]
        s0  <= tos;
        sp  <= sp + 'h1;
        tos <= v;
        $display(
            "%6t> ss_if.push(%0d) => tos:ss[%2x]<%0d,%0d>", 
            $time, v, ss_if.sp, ss_if.tos, ss_if.s0);
    endfunction: push

    function logic [DSZ-1:0] pop;
        op  <= SS_POP;
        pop <= tos;
        sp  <= sp + NEG1;  // pop s0 from stack[sp]
        tos <= s0;
        $display(
            "%6t> ss_if.pop <= tos:ss[%2x]<%0d,%0d>", 
            $time, ss_if.sp, ss_if.tos, ss_if.s0);
    endfunction: pop

    function alu(input [DSZ-1:0] v);
        op  <= SS_LOAD;
        sp  <= sp + NEG1;  // pop s0 from stack[sp]
        tos <= v;
        $display(
            "%6t> ss_if.alu(%0d) => tos:ss[%2x]<%0d,%0d>", 
            $time, v, ss_if.sp, ss_if.tos, ss_if.s0);
    endfunction: alu
endinterface: ss_io
`endif // FORTHSUPER_FORTHSUPER_IF
