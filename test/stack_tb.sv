///
/// ForthSuper Stack Testbench
///
`timescale 1ps / 1ps
`include "../source/stack.sv"
module stack_tb;
    localparam DEPTH = 16;              // 64 cells
    localparam DSZ   = 32;              // 32-bit stack
    localparam FF    = 'hffffffff;
    logic clk, en;
    logic [DSZ-1:0] tos;

    ss_io #(DEPTH, DSZ) ss_if();
    stack #(DEPTH, DSZ) u1(.ss_if(ss_if.slave), .*);

    always #5 clk  = ~clk;

    function integer calc_v(input integer i);
        //calc_v = (i < DSZ) ? FF >> i : FF << (i - DSZ);
        calc_v = 1000+i;
    endfunction: calc_v

    initial begin
        $monitor("%0s %0x => [%0x, %0x..]", ss_if.op, ss_if.vi, tos, ss_if.s0);
        clk = 0;
        // init clock
        en = 1'b0; repeat(2) @(posedge clk);
        en = 1'b1;
        // write
        for (integer i = 0; i < DEPTH - 1; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                tos = calc_v(i);
                ss_if.push(tos);
            end
        end
        // read
        for (integer i = DEPTH - 1; i >= 0; i = i - 1) begin
            repeat(1) @(posedge clk) begin
                tos = ss_if.pop();
            end
        end

        #20 $finish;
    end
endmodule: stack_tb
