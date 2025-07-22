///
/// @file
/// @brief 32-bit bus interface
///
interface mb32_io (                   // generic memory block interface
        input logic clk
    );
    localparam DSZ = 32;              // 32-bit bus
    localparam ASZ = 15;              // 32K rows
    logic           we;               // interface ports are bidirectional by default
    logic [3:0]     bmsk;             // we use modport to regulate the usage
    logic [ASZ-3:0] ai;               // specifying either master or slave device
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
endinterface: mb32_io
