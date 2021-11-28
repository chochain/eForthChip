///
/// ForthSuper Memory Pool Testbench
///
`timescale 1ps / 1ps
`include "../source/pool.sv"
module pool_tb;
    localparam ASZ  = 17;   // 64K
    localparam DSZ  = 8;    // 32-bit data
    logic           clk, rst, bsy;
    logic [2:0]     op;
    logic [1:0]     st;
    logic [ASZ-1:0] ai, ao, ao1;
    logic [DSZ-1:0] vi, vo;
    logic           we;
    
    string str_a  = "abcdefghijklmnop";
    string str_b  = "abcd";

    pool dict(.clk, .rst, .op, .ai, .vi, .we, .vo, .st, .bsy, .ao, .ao1);
    
    function integer calc_v(input integer i);
        calc_v = str_a.getc(i);
    /* 32-bit implementation
        calc_v = str_a.getc(i) | str_a.getc(i+1)<<8 | str_a.getc(i+2)<<16 | str_a.getc(i+3)<<24;
    */
    endfunction        

    always #10 clk  = ~clk;
        
    task reset(); begin
        repeat(1) @(posedge clk);
        rst = 1;
        repeat(1) @(posedge clk);
        rst = 0;
    end
    endtask
        
    task add_u8([ASZ-1:0] ax, [7:0] vx); begin
        repeat(1) @(posedge clk) begin
            op = W1;
            ai = ax;
            vi = vx;
        end            
    end    
    endtask
        
    task setup_mem(); begin
        // write
        for (integer i=0; i < str_a.len(); i = i + 1) add_u8(i, str_a.getc(i));
        add_u8(str_a.len(), 0);
        for (integer i=0; i < str_b.len(); i = i + 1) add_u8(str_a.len()+1+i, str_b.getc(i));
        add_u8(str_a.len() + 1 + str_b.len(), 0);
        // verify - read back
        
        for (integer i=0; i < str_a.len() + 1 + str_b.len() + 3; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                op  = R1;
                ai  = i;
                $display("%x:%x=>%x", i, calc_v(i), vo);
            end
        end
        
    end
    endtask
        
    initial begin
        clk = 0;
        reset();
        setup_mem();
        
        reset();
        ai = 'h11;
        op = FIND;
        repeat(20) @(posedge clk);
        
        #20 $finish;
    end       
endmodule // pool_tb
