///
/// @file
/// @brief eForth1 16-bit Single-Port Memory Testbench
///
`timescale 1ps / 1ps
`include "../source/spram.sv"
module spram16_tb;
    localparam DSZ  = 16;               // 16-bit data
    localparam ASZ  = 17;               // 128k range
    logic clk;
    logic [15:0] i, vo;

    mb_io #(16)  b16_if(clk);           // bus instance
    spram16_64k  m0(b16_if.slave);      // memory block bus slave
    
    task one_pass;
        // single byte check
        for (i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b16_if.put(i, (16'h1 << i) | (i & 16'h3));
            end
        end
        for (i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                vo = b16_if.get(i);
                $display("%d[%x]: %x => %x", i, b16_if.ai, (16'h1 << i) | (i & 16'h3), vo);
            end
        end
        // range check
        for (i = 0; i < ASZ; i = i + 2) begin
            repeat(1) @(negedge clk) begin
                b16_if.put(16'hf + (16'h1 << i), (~i << i) | (i & 16'h3));
            end
        end
        for (i = 0; i < ASZ + 4; i = i + 2) begin
            repeat(1) @(negedge clk) begin
                vo = b16_if.get(16'hf + (16'h1 << i));
                $display("%d[%x]: %x => %x", i, b16_if.ai, (~i << i) | (i & 16'h3), vo);
            end
        end
        // high byte check
        for (i = 0; i < ASZ; i = i + 2) begin
            repeat(1) @(negedge clk) begin
                b16_if.put(16'h7fff - i, (16'h1 << i) | (i & 16'h3));
            end
        end
        for (i = 0; i < ASZ + 4; i = i + 2) begin
            repeat(1) @(negedge clk) begin
                vo = b16_if.get(16'h7fff - i);
                $display("%d[%x]: %x => %x", i, b16_if.ai, (16'h1 << i) | (i & 16'h3), vo);
            end
        end
    endtask : one_pass

    always #10 clk  = ~clk;

    initial begin
        clk         = 1;
        b16_if.ai   = 0;
        b16_if.bmsk = 4'b1111;
        
        // init clock
        repeat(2) @(negedge clk);
        
        one_pass();

        #20 $finish;
    end
endmodule : spram16_tb
