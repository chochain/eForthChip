///
/// ForthSuper Memory Pool Testbench
///
`timescale 1ps / 1ps
`include "../source/pool.sv"
module pool_tb;
    localparam ASZ  = 16;   // 64K
    localparam DSZ  = 32;   // 32-bit data
    logic           clk, rst, ok;
    logic [2:0]     op;
    logic [1:0]     st;
    logic [ASZ-1:0] ai, ao;
    logic [DSZ-1:0] vi, vo;
    
    string str_a  = "abcdefghijklmnop";
    string str_b  = "abcd";

    pool dict(.clk, .rst, .op, .ai, .vi, .st, .ok, .ao, .vo);

    function integer calc_v(input integer i);
        calc_v = str_a.getc(i) | str_a.getc(i+1)<<8 | str_a.getc(i+2)<<16 | str_a.getc(i+3)<<24;
    endfunction        

    always #10 clk  = ~clk;

    task setup_mem(); begin
        // write
        for (integer i=0, j=0; i < str_a.len(); i = i + 4, j = j + 1) begin
            repeat(1) @(posedge clk) begin
                op  = W4;
                ai  = j;
                vi  = calc_v(i);
            end
        end
        // read
        for (integer j=0; j < 8; j = j + 1) begin
            repeat(1) @(posedge clk) begin
                op  = R4;
                ai  = j;
                $display("%x:%x=>%x", j, calc_v(j), vo);
            end
        end
    end
    endtask
        
    initial begin
        clk = 0;
        rst = 1;
        repeat(2) @(posedge clk);   // setup clock
        rst  = 0;

        setup_mem();
        
        #20 $finish;
    end       
endmodule // pool_tb
