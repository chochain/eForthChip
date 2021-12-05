///
/// ForthSuper atoi module Testbench
///
`timescale 1ps / 1ps
`include "../source/spram.sv"
`include "../source/atoi.sv"
module atoi_tb;
    localparam DSZ  = 32;      // 32-bit converted value
    localparam ASZ  = 17;      // 128K address space
    localparam TIB  = 0;       // Terminal input buffer address
    localparam HEX  = 1'b1;
    
    logic clk, rst, en;        /// input signals
    logic [7:0]     ch;
    logic           bsy;       /// 0:busy, 1:done
    logic           af;        /// address advance flag
    logic [DSZ-1:0] vo;        /// resultant value
    logic [1:0]     st;        /// DEBUG: state
                  
    string tib = "-7f8";

    iBus8         b8();
    spram8_128k   m0(b8.slave, clk);
    atoi          u0(.clk, .en, .hex(HEX), .ch, .bsy, .af, .vo, .st);
    
    always #10 clk  = ~clk;
        
    task reset();
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    endtask
        
    task add_u8([ASZ-1:0] ax, [7:0] vx);
        repeat(1) @(posedge clk) begin
            b8.we = 1'b1;
            b8.ai = ax;
            b8.vi = vx;
        end            
    endtask
    
    task setup_mem();
        // write
        for (integer i=0; i < tib.len(); i  = i + 1) begin
            add_u8(TIB + i, tib[i]);
        end
        add_u8(tib.len(), 0);
        
        // read back validation
        for (integer i=0; i < tib.len() + 4; i  = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b0;
                b8.ai = TIB + i;
            end
        end
    endtask
    
    assign ch = b8.vo;       // feed value fetched from memory to atoi module 
    
    initial begin
        clk = 0;
        en  = 1'b0;
        setup_mem();

        b8.ai = TIB;         // initialize tib address for atoi conversion
        repeat(1) @(posedge clk);
        
        en  = 1'b1;          // start conversion
        repeat(30) @(posedge clk) begin
            if (en) b8.ai <= b8.ai + af; // advance address if requested by atoi module
        end
        
        #20 $finish;
    end       
endmodule // atoi_tb
