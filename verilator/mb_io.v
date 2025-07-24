///
/// @file
/// @brief universal memory bus interface - paramatric sizing
/// @note use modport to regulate the usage
///
interface mb_io #(                     // generic memory block interface
        parameter DSZ = 32             // 8, 16, 32-bit bus
    ) (
        input logic clk
    );
    localparam ASZ = 20 - $clog2(DSZ); // 17, 16, 15 (for 128K SPRAM)
    logic           we;                // interface ports are bidirectional by default
    logic [ASZ-1:0] ai;                // specifying either master or slave device
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;
    /* verilator lint_off UNUSEDSIGNAL */
    logic [3:0]      bmsk;             // 8-bit does not need this
    /* verilator lint_on UNUSEDSIGNAL  */
    /* 
    clocking io_clk @(posedge clk);    // if needed, specify input and output signal delay    
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
