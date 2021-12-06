///
/// ForthSuper Stack Testbench
///
`timescale 1ps / 1ps
`include "../source/stack.sv"
module stack_tb;
    localparam DSZ   = 32;              // 32-bit stack
    localparam DEPTH = 64;              // 64 cells
    localparam SSZ   = $clog2(DEPTH);
    localparam FF    = 'hffffffff;
    logic clk, rst, we, e, f, push, pop;
    logic [DSZ-1:0] vi, vo;
    logic [SSZ-1:0] idx;

    //stack u1(.*);
    //stack2 u1(.clk, .we, .delta(2'b11), .vi, .vo);
    stack3 u1(.clk, .rst, .push, .pop, .vi, .idx, .vo);

    always #10 clk  = ~clk;
        
    function integer calc_v(input integer i);
        calc_v = (i < DSZ) ? FF >> i : FF << (i - DSZ);
    endfunction: calc_v

    initial begin
        {clk, we, vi, vo, idx} = 0;

        // init clock
        rst  = 1;
        repeat(2) @(posedge clk);
        rst  = 0;
        // write
        for (integer i = 0; i < DEPTH; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                push = 1;
                pop  = 0;
                vi   = calc_v(i);
                $display("%d: %x[%x]", i, vi, idx);
            end
        end
        // read
        for (integer i = DEPTH; i >=0; i = i - 1) begin
            repeat(1) @(posedge clk) begin
                push = 0;
                pop  = 1;
                $display("%d: %x => %x[%x]", i, calc_v(i), vo, idx);
            end
        end

        #20 $finish;
    end       
endmodule: stack_tb
