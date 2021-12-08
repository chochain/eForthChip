///
/// ForthSuper Single-Port Memory with Multi-Driver Testbench
///
`timescale 1ps / 1ps
module mdrv_tb;
    logic clk, ok;

    md_io md_if();                      // bus instance
    mdrv  dr(md_if.master, clk, en);
    
    always #10 clk  = ~clk;

    initial begin
        clk = 0;
        ok  = 1;
        // init clock
        repeat(30) @(posedge clk);

        #20 $finish;
    end       
endmodule: mdrv_tb
