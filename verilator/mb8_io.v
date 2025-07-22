///
/// @file
/// @brief 8-bit memory block interface (for debugging, mostly)
///
interface mb8_io (
       input logic clk
    );
    localparam ASZ = 17;
    localparam DSZ = 8;
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
