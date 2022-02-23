///
/// ForthSuper Stack Testbench
///
`timescale 1ps / 1ps
`include "../source/stack.sv"
module stack_tb;
    localparam DEPTH = 16;              // 64 cells
    localparam DSZ   = 32;              // 32-bit stack
    localparam SSZ   = $clog2(DEPTH);
    localparam FF    = 'hffffffff;
    logic clk, rst, en;
    logic [DSZ-1:0] tos;

    ss_io #(DSZ,SSZ) ss_if;
    stack #(DEPTH) u1(.ss_if(ss_if.slave), .*);
    
    always #5 clk  = ~clk;
        
    function integer calc_v(input integer i);
        //calc_v = (i < DSZ) ? FF >> i : FF << (i - DSZ);
        calc_v = i;
    endfunction: calc_v

    initial begin
        $monitor("%0s %0x => [%0x, %0x, %0x..]", ss_if.op, ss_if.vi, tos, ss_if.s0, ss_if.s1);
        clk = 0;
        // init clock
        rst = 1'b1; repeat(2) @(posedge clk);
        rst = 1'b0;
        en  = 1'b1;
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
