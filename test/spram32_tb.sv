///
/// ForthSuper Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram32_tb;
    localparam ASZ  = 15;   // 32K
    localparam DSZ  = 32;   // 32-bit data
    logic clk, we;
    logic [3:0] bmsk;
    logic [ASZ-1:0] a;
    logic [DSZ-1:0] vi, vo;

    spram32_32k u1(.clk, .we, .bmsk, .a, .vi, .vo);

    always #10 clk  = ~clk;

    initial begin
        {clk, we, a, vi}  = 0;
        bmsk = 4'b1111;
        
        // init clock
        repeat(2) @(posedge clk);

        // byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = i;
                we   = 1;
                vi   = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = i;
                we   = 0;
                $display("%d[%x]: %x => %x", i, a, (1 << i) | (i & 3), vo);
            end
        end
        // range check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = 31 + (1 << i);
                we   = 1;
                vi   = (~i << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a  = 31 + (1 << i);
                we = 0;
                $display("%d[%x]: %x => %x", i, a, (~i << i) | (i & 3), vo);
            end
        end
        // high byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = 'h7fff - i;
                we   = 1;
                vi   = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a  = 'h7fff - i;
                we = 0;
                $display("%d[%x]: %x => %x", i, a, (1 << i) | (i & 3), vo);
            end
        end

        #20 $finish;
    end       
endmodule // spram32_tb
