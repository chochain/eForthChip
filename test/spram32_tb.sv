///
/// ForthSuper Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram32_tb;
    localparam ASZ  = 15;   // 32K
    localparam DSZ  = 32;   // 32-bit data
    logic clk;

    mb32_io     b32_if(clk);            // bus instance
    spram32_32k m0(b32_if.slave, clk);  // memory block bus slave
    
    task one_pass;
        // byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32_if.ai = i;
                b32_if.we = 1;
                b32_if.vi = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32_if.ai = i;
                b32_if.we = 0;
                $display("%d[%x]: %x => %x", i, b32_if.ai, (1 << i) | (i & 3), b32_if.vo);
            end
        end
        // range check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32_if.ai = 31 + (1 << i);
                b32_if.we = 1;
                b32_if.vi = (~i << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32_if.ai = 31 + (1 << i);
                b32_if.we = 0;
                $display("%d[%x]: %x => %x", i, b32_if.ai, (~i << i) | (i & 3), b32_if.vo);
            end
        end
        // high byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32_if.ai = 'h7fff - i;
                b32_if.we = 1;
                b32_if.vi = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b32_if.ai = 'h7fff - i;
                b32_if.we = 0;
                $display("%d[%x]: %x => %x", i, b32_if.ai, (1 << i) | (i & 3), b32_if.vo);
            end
        end
    endtask : one_pass

    always #10 clk  = ~clk;

    initial begin
        clk       = 0;
        b32_if.ai = 0;
        
        // init clock
        repeat(2) @(posedge clk);
        
        for (integer j = 0; j < 3; j = j + 1) begin
            b32_if.bmsk = 4'b1111 >> j;
            one_pass();
        end

        #20 $finish;
    end       
endmodule : spram32_tb
