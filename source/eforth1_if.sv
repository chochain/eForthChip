///
/// @file
/// @brief eForth1 - memory and stack bus interfaces
///
`ifndef EFORTH1_EFORTH1_IF
`define EFORTH1_EFORTH1_IF

interface mb_io #(                    // generic memory block interface
    parameter DSZ = 16,               // 8, 16, 24, 32
    parameter ASZ = 17                // total 128K bytes
    )(input logic clk);
    logic           we;               // interface ports are bidirectional by default
    logic [3:0]     bmsk;             // we use modport to regulate the usage
    logic [ASZ-1:0] ai;               // specifying either master or slave device
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;
    /* 
    clocking io_clk @(posedge clk);   // if needed, specify input and output signal delay    
        default input #1 output #1;
    endclocking
    */
    modport master(output we, bmsk, ai, vi, import put, get);
    modport slave(input clk, we, bmsk, ai, vi, output vo);
    
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

typedef enum logic [1:0] {
    SS_SET = 2'b00, SS_PUSH = 2'b01, SS_POP = 2'b10, SS_PICK = 2'b11 
} sop_e;

interface ss_io #(                      ///> generic stack interface
    parameter DEPTH = 64,               ///> depth of stack
    parameter DSZ   = 16                ///> data bus width
    )(input logic clk);
    localparam SSZ = $clog2(DEPTH);     ///> bit count of stack
    sop_e           op;                 ///> stack opcode
    logic [SSZ-1:0] sp0, sp1;           ///> stack indexes (sp1 = sp0 + 1)
    logic [DSZ-1:0] s, t;               ///> NOS and TOS
    /* 
    clocking io_clk @(posedge clk);     // if needed, specify input and output signal delay    
        default input #1 output #1;
    endclocking
    */
    modport master(output op, t, import set, push, pop);
    modport slave(input clk, op, output sp0, sp1, t, s, import set, push, pop);
    
    function void set(input [DSZ-1:0] v);
        op = SS_SET;
        t  = v;
    endfunction: set
    
    function void push(input [DSZ-1:0] v);
        op  = SS_PUSH;
        s   = t;
        sp0 = sp1;
        sp1 = sp1 + 6'h1;
        t   = v;
        // $display("%6t> %s %x => %d[%x %x]", $time, op, v, sp0, t, s);
    endfunction: push

    function logic [DSZ-1:0] pop;
        op  = SS_POP;
        sp1 = sp0;
        sp0 = sp0 - 6'h1;
        t   = s;         // return from cached s0
        // $display("%6t> %s => %d[%x %x]", $time, op, sp0, t, s);
    endfunction: pop
    
endinterface: ss_io
`endif // EFORTH1_EFORTH1_IF
