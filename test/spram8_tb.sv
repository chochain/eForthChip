///
/// ForthSuper Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram8_tb;
    localparam ASZ  = 17;   // 128K
    localparam DSZ  = 8;    // 8-bit data
    logic clk, we;
    logic [ASZ-1:0] a;
    logic [DSZ-1:0] vi, vo;

    spram8_128k u1(.clk, .we, .a, .vi, .vo);

    always #10 clk  = ~clk;

    initial begin
        {clk, we, a, vi} = 0;

        // init clock
        repeat(2) @(posedge clk);

        // write
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a  = i;
                we = 1;
                vi = i;
            end
        end
        // read
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a  = i;
                we = 0;
                $display("%d[%x]: %x => %x", i, a, i, vo);
            end
        end

        #20 $finish;
    end       
endmodule // spram8_tb
