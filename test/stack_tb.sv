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
    logic clk, rst, en;

    //stack u1(.*);
    //stack2 u1(.clk, .we, .delta(2'b11), .vi, .vo);
    ss_io  ss_if();
    dstack u1(.ss_if(ss_if.slave), .*);

    always #10 clk  = ~clk;
        
    function integer calc_v(input integer i);
        calc_v = (i < DSZ) ? FF >> i : FF << (i - DSZ);
    endfunction: calc_v

    initial begin
        clk = 0;
        // init clock
        rst = 1'b1; repeat(2) @(posedge clk);
        rst = 1'b0;
        en  = 1'b1;
        // write
        for (integer i = 0; i < DEPTH - 1; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                ss_if.op = PUSH;
                ss_if.vi = calc_v(i);
                $display("push[%x] %x (%x, %x)", i, ss_if.vi, ss_if.t, ss_if.s);
            end
        end
        // read
        for (integer i = DEPTH - 1; i >= 0; i = i - 1) begin
            repeat(1) @(posedge clk) begin
                ss_if.op = POP;
                $display("pop[%x]: %x => (%x,%x)", i, calc_v(i), ss_if.t, ss_if.s);
            end
        end

        #20 $finish;
    end       
endmodule: stack_tb
