///
/// ForthSuper common interfaces
///
`ifndef FORTHSUPER_FORTHSUPER_IF
`define FORTHSUPER_FORTHSUPER_IF

typedef enum logic [1:0] { NOP = 2'b0, PUSH = 2'b01, POP = 2'b10, PICK = 2'b11 } stack_ops;

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
    parameter DSZ=32,
    parameter SSZ=6);
    stack_ops    op;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] s0;
    logic [SSZ-1:0] sp = 0;

    modport master(input s0, output op, vi, import push, pop);
    modport slave(input op, vi, output sp, s0);

    function void push(input [DSZ-1:0] v);
        op  = PUSH;
        vi  = v;
        sp  = sp + 1;
        s0  = v;
    endfunction: push

    function logic [DSZ-1:0] pop;
        op   = POP;
        sp   = sp - 1;
        pop  = s0;
    endfunction: pop

endinterface: ss_io
`endif // FORTHSUPER_FORTHSUPER_IF
