///
/// ForthSuper atoi module Testbench
///
`timescale 1ps / 1ps
`include "../source/spram.sv"
`include "../source/atoi.sv"
module atoi_tb;
    localparam DSZ  = 32;      // 32-bit data
    localparam ASZ  = 17;      // 64K
    localparam TIB  = 0;       // Terminal input buffer address
    
    logic clk, rst, en, we;    // input signals
    logic [ASZ-1:0] ai;        /// input address
    logic [7:0]     ch, _ch;
    logic [2:0]     st;        /// DEBUG state
    logic           bsy;       /// 0:busy, 1:done
    logic [ASZ-1:0] ao;        /// endptr
    logic [DSZ-1:0] vo;        /// DEBUG memory
    logic [7:0]     vi;
                  
    string tib = "123";

    spram8_128k mem(.clk, .we, .a(ai), .vi, .vo(_ch));
    atoi u0(.clk, .rst, .en, .ai, .ch, .st, .bsy, .ao, .vo);
    
    always #10 clk  = ~clk;
        
    task reset(); begin
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    end
    endtask
        
    task add_u8([ASZ-1:0] ax, [7:0] vx); begin
        repeat(1) @(posedge clk) begin
            we = 1'b1;
            ai = ax;
            vi = vx;
        end            
    end    
    endtask
        
    task setup_mem(); begin
        // write
        for (integer i=0; i < tib.len(); i  = i + 1) begin
            add_u8(TIB + i, tib[i]);
        end
        add_u8(tib.len(), 0);
        
        // read back validation
        for (integer i=0; i < tib.len() + 4; i  = i + 1) begin
            repeat(1) @(posedge clk) begin
                we = 1'b0;
                ai = TIB + i;
            end
        end
        
    end
    endtask
    
    initial begin
        clk = 0;
        en  = 1'b0;
        setup_mem();

        ai  = TIB;
        reset();
        we  = 1'b0;
        en  = 1'b1;
        repeat(40) @(posedge clk);
        
        #20 $finish;
    end       
    
    always @(posedge clk) begin
        if (en) begin
            ai <= ao;
            ch <= _ch;
        end
    end
endmodule // atoi_tb
