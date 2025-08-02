///
/// @file
/// @brief universal memory bus interface - paramatric sizing
/// @note use modport to regulate the usage
///
interface mb8_io (                     // generic memory block interface
        input logic clk
    );
    localparam DSZ = 8;                // 8-bit bus
    localparam ASZ = 20 - $clog2(DSZ); // 17, 16, 15 (for 128K SPRAM)
    logic           we;                // interface ports are bidirectional by default
    logic [ASZ-1:0] ai;                // specifying either master or slave device
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;
endinterface: mb8_io
