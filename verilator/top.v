///
/// @file
/// @brief eForth1 - 8-bit Single-Port Memory Testbench
///
`include "../source/mb8_io.sv"
`include "../source/mb32_io.sv"
`include "../source/spram8_128k.sv"
`include "../source/spram32_32k.sv"
module top (
    input         clk,
    output [16:0] ai,
    output [7:0]  vi,
    output [7:0]  vo);
   
    localparam ASZ  = 17;      // 128K
  
    mb8_io      b8_if(clk);
    spram8_128k u1(b8_if);

    assign ai = b8_if.ai;
    assign vi = b8_if.vi;
    assign vo = b8_if.vo;
endmodule : top
