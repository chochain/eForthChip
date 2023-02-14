///
/// @file
/// @brief eForth1 32-bit Single-Port Memory Testbench
///
`timescale 1ps / 1ps
`include "../source/spram.sv"
module spram32_tb;
    localparam DSZ  = 32;               // 32-bit data
    localparam ASZ  = 20 - $clog2(DSZ); // 15-bits
    logic        clk;
    logic [31:0] vo;

    mb_io #(32)  b32_if(clk);           // bus instance
    spram32_32k  m0(b32_if.slave);      // memory block bus slave
    
    task one_pass;
        // byte check
        for (int i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b32_if.ai = i;
                b32_if.we = 1;
                b32_if.vi = (1 << i) | (i & 3);
            end
        end
        for (int i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b32_if.ai = i;
                b32_if.we = 0;
                $display("%d[%x]: %x => %x", i, b32_if.ai, (1 << i) | (i & 3), b32_if.vo);
            end
        end
        // range check
        for (int i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b32_if.put(31 + (1 << i), (~i << i) | (i & 3));
            end
        end
        for (int i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                vo = b32_if.get(31 + (1 << i));
                $display("%d[%x]: %x => %x", i, b32_if.ai, (~i << i) | (i & 3), vo);
            end
        end
        // high byte check
        for (int i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b32_if.put('h7fff - i, (1 << i) | (i & 3));
            end
        end
        for (int i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                vo = b32_if.get('h7fff - i);
                $display("%d[%x]: %x => %x", i, b32_if.ai, (1 << i) | (i & 3), vo);
            end
        end
    endtask : one_pass

    always #10 clk  = ~clk;

    initial begin
        clk       = 1;
        b32_if.ai = 0;
        
        // init clock
        repeat(2) @(negedge clk);
        
        for (int j = 0; j < 3; j = j + 1) begin
            b32_if.bmsk = 4'b1111 >> j;
            one_pass();
        end

        #20 $finish;
    end
endmodule: spram32_tb
