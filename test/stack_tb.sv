///
/// ForthSuper Stack Testbench
///
`timescale 1ps / 1ps
module stack_tb;
    localparam DSZ   = 32;   // 32-bit stack
    localparam DEPTH = 64;
    localparam SSZ   = $clog(DEPTH);
    logic clk, we, e, f, push, pop;
    logic [DSZ-1:0] vi, vo;

    //stack u1(.*);
    //stack2 u1(.clk, .we, .delta(2'b11), .vi, .vo);
    stack3 u1(.clk, push, pop, vi, vo);

    always #10 clk  = ~clk;

    initial begin
        {clk, we, vi, push, pop, vo} = 0;

        // init clock
        repeat(2) @(posedge clk);

        // write
        for (integer i = 0; i < SSZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                we  = 1;
                vi  = -i << i;
            end
        end
        // read
        for (integer i = 0; i < SSZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                we = 0;
                $display("%d: %x => %x", i, -i << i, vo);
            end
        end

        #20 $finish;
    end       
endmodule // stack_tb
