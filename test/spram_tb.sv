///
/// ForthSuper Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram_tb;
    localparam ASZ  = 16;   // 64K
    localparam DSZ  = 32;   // 32-bit data
    logic clk, we;
    logic [ASZ-1:0] a;
    logic [DSZ-1:0] vi, vo;

    spram64k u1(.clk, .we, .a, .vi, .vo);

    always #10 clk  = ~clk;

    initial begin
        {clk, we, a, vi, vo} = 0;

        // init clock
        repeat(2) @(posedge clk);

        // write
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a  = 1 << i;
                we = 1;
                vi = -i << i;
            end
        end
        // read
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a  = 1 << i;
                we = 0;
                $display("%d: %x => %x", i, -i << i, vo);
            end
        end

        #20 $finish;
    end       
endmodule // spram
