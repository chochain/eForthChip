///
/// ForthSuper common interfaces
///
`ifndef FORTHSUPER_FORTHSUPER_IF
`define FORTHSUPER_FORTHSUPER_IF

typedef enum logic [1:0] { NOP = 2'b0, PUSH = 2'b01, POP = 2'b10, PICK = 2'b11 } stack_ops;

interface mb32_io(input logic clk);
    logic        we;
    logic [3:0]  bmsk;
    logic [14:0] ai;
    logic [31:0] vi;
    logic [31:0] vo;
    
    clocking ioDrv @(posedge clk);
        default input #1 output #1;
    endclocking // ioMaster

    modport master(clocking ioDrv, output we, bmsk, ai, vi);
    modport slave(clocking ioDrv, input we, bmsk, ai, vi, output vo);
endinterface: mb32_io

interface mb8_io;
    logic        we;
    logic [16:0] ai;
    logic [7:0]  vi;
    logic [7:0]  vo;
    
    modport master(output we, ai, vi, import put_u8, get_u8);
    modport slave(input we, ai, vi, output vo);

    function void put_u8([16:0] ax, [7:0] vx);
        we = 1'b1;
        ai = ax;
        vi = vx;
    endfunction: put_u8
    
    function void get_u8([16:0] ax);
        we = 1'b0;
        ai = ax;
        // return vo
    endfunction: get_u8
endinterface : mb8_io

interface ss_io();
    stack_ops    op;
    logic [31:0] vi;
    logic [31:0] s;
    
    modport master(input s, output op, vi, import push, pop);
    modport slave(input op, vi, output s);

    function void push(input [31:0] v);
        op  = PUSH;
        vi  = v;
    endfunction: push

    function logic [31:0] pop;
        op   = POP;
        pop  = s;
    endfunction: pop
    
endinterface: ss_io
`endif // FORTHSUPER_FORTHSUPER_IF

