///
/// @file
/// @brief eForth1 - memory and stack bus interfaces
///
`ifndef EFORTH1_EFORTH1_IF
`define EFORTH1_EFORTH1_IF

interface mb_io #(                      // generic memory block interface
    parameter DSZ = 32                  // 8, 16, 32-bit bus
    ) (
        input logic clk
    );
    localparam ASZ = 20 - $clog2(DSZ);  // 17, 16, 15 (for 128K SPRAM)
    logic           we;                 // interface ports are bidirectional by default
    logic [3:0]     bmsk;               // we use modport to regulate the usage
    logic [ASZ-1:0] ai;                 // specifying either master or slave device
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;
    /* verilator lint_off UNUSEDSIGNAL */
    logic [3:0]      bmsk;             // 8-bit does not need this
    /* verilator lint_on UNUSEDSIGNAL  */
   
    /* 
    clocking io_clk @(posedge clk);     // if needed, specify input and output signal delay    
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

typedef enum logic [1:0] {
    SS_PUSH = 2'b00, SS_POP = 2'b01, SS_SET = 2'b10, SS_PICK = 2'b11 
} sop_e;

interface ss_io #(                      ///> generic stack interface
    parameter DEPTH = 64,               ///> depth of stack
    parameter DSZ   = 16                ///> data bus width
    )(input logic clk);
    localparam SSZ = $clog2(DEPTH);     ///> bit count of stack
    sop_e           op;                 ///> stack opcode
    logic [SSZ-1:0] sp0, sp1;           ///> stack indexes (sp1 = sp0 + 1)
    logic [DSZ-1:0] s, vi;              ///> NOS, input value
    /* 
    clocking io_clk @(posedge clk);     // if needed, specify input and output signal delay    
        default input #1 output #1;
    endclocking
    */
    modport master(output op, vi);
    modport slave(input clk, op, output sp0, sp1, s, vi, import init, push, pop);
    
    function void init();
        vi = 16'hffff;
    endfunction: init
    
    function void push(input [DSZ-1:0] v);
        op  = SS_PUSH;
        sp0 = sp1;
        sp1 = sp1 + 6'h1;
        s   = v;
        vi  = v;
        // $display("%6t> %s %x => %d[%x %x]", $time, op, v, sp0, t, s);
    endfunction: push

    function void pop;
        op  = SS_POP;
        sp1 = sp0;
        sp0 = sp0 - 6'h1;
        // $display("%6t> %s => %d[%x %x]", $time, op, sp0, t, s);
    endfunction: pop
    
endinterface: ss_io
`endif // EFORTH1_EFORTH1_IF
