///
/// eForth1 Single-Port Memory with Multi-Driver Testbench
///
`timescale 1ps / 1ps
module mdrv_tb;
    logic clk, ok;

    md_io md_if();                      // bus instance
    mdrv  dr(.md_if(md_if.master), .clk, .ok);
    
    always #10 clk  = ~clk;

    initial begin
        clk = 1'b0;
        ok  = 1'b0;
        repeat(2) @(posedge clk);
        ok  = 1'b1;
        repeat(30) @(posedge clk);

        #20 $finish;
    end       
endmodule: mdrv_tb
