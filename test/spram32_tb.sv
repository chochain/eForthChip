///
/// ForthSuper Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram32_tb;
    localparam ASZ  = 15;   // 32K
    localparam DSZ  = 32;   // 32-bit data
    logic clk;

    iBus32      b32(.clk);          // bus instance
    spram32_32k m0(.b32, .clk);     // memory block bus slave
    
    task one_pass(); begin
        // byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32.ai = i;
                b32.we = 1;
                b32.vi = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32.ai = i;
                b32.we = 0;
                $display("%d[%x]: %x => %x", i, b32.ai, (1 << i) | (i & 3), b32.vo);
            end
        end
        // range check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32.ai = 31 + (1 << i);
                b32.we = 1;
                b32.vi = (~i << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32.ai = 31 + (1 << i);
                b32.we = 0;
                $display("%d[%x]: %x => %x", i, b32.ai, (~i << i) | (i & 3), b32.vo);
            end
        end
        // high byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32.ai = 'h7fff - i;
                b32.we = 1;
                b32.vi = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32.ai = 'h7fff - i;
                b32.we = 0;
                $display("%d[%x]: %x => %x", i, b32.ai, (1 << i) | (i & 3), b32.vo);
            end
        end
    end
    endtask

    always #10 clk  = ~clk;

    initial begin
        clk    = 0;
        b32.ai = 0;
        
        // init clock
        repeat(2) @(posedge clk);
        
        for (integer j = 0; j < 3; j = j + 1) begin
            b32.bmsk = 4'b1111 >> j;
            one_pass();
        end

        #20 $finish;
    end       
endmodule // spram32_tb
