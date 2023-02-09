///
/// ForthSuper common interfaces
///
`ifndef FORTHSUPER_FORTHSUPER_IF
`define FORTHSUPER_FORTHSUPER_IF

typedef enum logic [1:0] {
    SS_LOAD = 2'b0, SS_PUSH = 2'b01, SS_POP = 2'b10, SS_PICK = 2'b11 
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
    logic [DSZ-1:0] s0, _tos, tos = -1;
    logic [SSZ-1:0] sp_1, sp = 0;
    logic xt;

    modport master(output op, vi, import load, push, pop);
    modport slave(input op, vi, output sp, sp_1, s0, tos, import update_tos);
    
    always_comb begin
        sp_1 = sp + NEG1;
        xt   = 1'b0;
    end

    function void load(input [DSZ-1:0] v);
        _tos = v;
        xt   = 1'b1;
    endfunction: load
    
    function void push(input [DSZ-1:0] v);
        op  = SS_PUSH;
        vi  = v;
    endfunction: push

    function logic [DSZ-1:0] pop;
        op  = SS_POP;
        pop = s0;         // return from cached s0
    endfunction: pop
    
    task update_tos;
        if (xt) tos <= _tos;
    endtask: update_tos;

endinterface: ss_io
`endif // FORTHSUPER_FORTHSUPER_IF
