///
/// ForthSuper spacer module Testbench
///
`timescale 1ps / 1ps
`include "../source/spram.sv"
`include "../source/spacer.sv"
module spacer_tb;
    localparam DSZ  = 32;      // 32-bit converted value
    localparam ASZ  = 17;      // 128K address space
    localparam TIB  = 0;       // Terminal input buffer address
    
    logic clk, rst, en;        /// input signals
    logic           bsy;       /// 0:busy, 1:done
    logic [7:0]     ch;        /// charater fetched from memory
    logic [ASZ-1:0] a0;
    
    string tib = "  abc";

    mb8_io        b8_if();
    spram8_128k   m0(b8_if.slave, clk);
    spacer #(ASZ) u0(.*, .mb_if(b8_if.master));
    
    always #10 clk  = ~clk;
        
    task reset;
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    endtask: reset
        
    task add_u8([ASZ-1:0] ax, [7:0] vx);
        repeat(1) @(posedge clk) begin
            b8_if.put_u8(ax, vx);
        end            
    endtask: add_u8
    
    task setup_mem;
        // write
        for (integer i=0; i < tib.len(); i  = i + 1) begin
            add_u8(TIB + i, tib[i]);
        end
        add_u8(tib.len(), 0);
        
        // read back validation
        for (integer i=0; i < tib.len() + 4; i  = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8_if.get_u8(TIB + i);
            end
        end
    endtask: setup_mem
    
    assign ch = b8_if.vo;
    
    initial begin
        clk = 0;
        en  = 1'b0;
        setup_mem();

        a0  = TIB;
        reset();
        en  = 1'b1;             // start conversion
        repeat(30) @(posedge clk);

        #20 $finish;
    end       
endmodule: spacer_tb
