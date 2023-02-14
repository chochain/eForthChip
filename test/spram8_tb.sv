///
/// eForth1 8-bit Single-Port Memory Testbench
///
`timescale 1ps / 1ps
`include "../source/spram.sv"
module spram8_tb;
    localparam ASZ  = 17;   // 128K
    localparam DSZ  = 8;    // 8-bit data
    logic       clk;
    logic [7:0] vo;
   
    mb8_io      b8_if(clk);
    spram8_128k u1(b8_if.slave);

    always #10 clk = ~clk;

    initial begin
        clk = 1;

        // init clock
        repeat(2) @(negedge clk);

        // byte order check (direct access interface ports)
        for (int i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i;
                b8_if.vi = i;
                b8_if.we = 1'b1;
            end
        end
        repeat(2) @(negedge clk);
        for (int i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i;
                b8_if.we = 1'b0;
                $display("%d[%x]: %x => %x", i, b8_if.ai, i, b8_if.vo);
            end
        end
        
        // range check
        for (int i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.put(
                    ('h1 << i) | (i & 3),
                    (i < 8) ? ('h1 << i) : ('hff >> (i-8))
                );
            end
        end
        repeat(2) @(negedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                vo = b8_if.get(('h1 << i) | (i & 3));
                $display("%d[%x]: %x => %x", i, b8_if.ai, i<8 ? ('h1 << i) : ('hff >> (i-8)), vo);
            end
        end
        // high address check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.put('h1ffff - i, i);
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                vo = b8_if.get('h1ffff - i);
                $display("%d[%x]: %x => %x", i, b8_if.ai, i, vo);
            end
        end
        
        #20 $finish;
    end       
endmodule : spram8_tb
