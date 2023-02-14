///
/// @file
/// @brief eForth1 -  Bus interfaces
///
`ifndef EFORTH1_EFORTH1_IF
`define EFORTH1_EFORTH1_IF

typedef enum logic [1:0] {
    SS_LOAD = 2'b0, SS_PUSH = 2'b01, SS_POP = 2'b10, SS_PICK = 2'b11 
} sop_e;

interface mb_io #(
    parameter DSZ = 16,               // 8, 16, 24, 32
    parameter ASZ = 17                // total 128K bytes
    )(input logic clk);
    logic           we;
    logic [3:0]     bmsk;
    logic [ASZ-1:0] ai;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;
    
    clocking ioDrv @(posedge clk);
        default input #1 output #1;
    endclocking                       // ioMaster

    modport master(clocking ioDrv, output we, bmsk, ai, vi, import put, get);
    modport slave(clocking ioDrv, input clk, we, bmsk, ai, vi, output vo);
    
    function void put([ASZ-1:0] ax, [DSZ-1:0] vx);
        we = 1'b1;
        ai = ax;
        vi = vx;
    endfunction: put

    function logic[DSZ-1:0] get([ASZ-1:0] ax);
        we  = 1'b0;
        ai  = ax;
        get = vo;
    endfunction: get
endinterface: mb_io

///
/// 8-bit memory block interface (for debugging, mostly)
///
interface mb8_io #(
    parameter ASZ=17,
    parameter DSZ=8
    )(input logic clk);
    logic we;
    logic [ASZ-1:0] ai;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;
 
    modport master(output we, ai, vi, import put, get);
    modport slave(input clk, we, ai, vi, output vo);

    function void put([ASZ-1:0] ax, [DSZ-1:0] vx);
         we = 1'b1;
         ai = ax;
         vi = vx;
    endfunction: put

    function logic [DSZ-1:0] get([ASZ-1:0] ax);
        we  = 1'b0;
        ai  = ax;
        get = vo;
    endfunction: get
endinterface: mb8_io

/*
interface ss_io #(
    parameter DEPTH = 64,
    parameter DSZ   = 32);
    sop_e           op;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] s0, _tos, tos;
    logic [SSZ-1:0] sp_1, sp;
    logic xt;

    modport master(output op, vi, import load, push, pop);
    modport slave(input op, vi, output sp, sp_1, s0, tos);
    
    function logic [DS-1:0] load(input [DSZ-1:0] v);
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
    
endinterface: ss_io
*/
`endif // EFORTH1_EFORTH1_IF
