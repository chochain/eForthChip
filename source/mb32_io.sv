///
/// @file
/// @brief universal memory bus interface - paramatric sizing
/// @note use modport to regulate the usage
///
`ifndef EFORTH1_MB32_IO
`define EFORTH1_MB32_IO

interface mb32_io (                   // generic memory block interface
        input logic clk
    );
    localparam DSZ = 32;               // 8, 16, 32-bit bus
    localparam ASZ = 20 - $clog2(DSZ); // 17, 16, 15 (for 128K SPRAM)
    logic           we;                // interface ports are bidirectional by default
    logic [ASZ-1:0] ai;                // specifying either master or slave device
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;
    logic [3:0]     bmsk;
    
    modport master(input clk, output we, bmsk, ai, vi, vo);
    modport slave(input clk, we, bmsk, ai, vi, output vo);
endinterface

`endif // EFORTH1_MB32_IO
