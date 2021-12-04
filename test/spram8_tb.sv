///
/// ForthSuper Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram8_tb;
    localparam ASZ  = 17;   // 128K
    localparam DSZ  = 8;    // 8-bit data
    logic clk, we;
    logic [ASZ-1:0] ai;
    logic [DSZ-1:0] vi;
    logic [DSZ-1:0] vo;

    iBus8       bus();
    spram8_128k u1(.bus, .clk, .ai, .vi, .vo);

    always #10 clk  = ~clk;

    initial begin
        clk = 0;

        // init clock
        repeat(2) @(posedge clk);

        // byte order check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                ai     = i;
                bus.we = 1;
                vi     = i;
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                ai     = i;
                bus.we = 0;
                $display("%d[%x]: %x => %x", i, ai, i, vo);
            end
        end
		/*
        // range check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = ('h1 << i) | (i & 3);
                we   = 1;
                vi   = (i < 8) ? ('h1 << i) : ('hff >> (i-8));
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = ('h1 << i) | (i & 3);
                we   = 0;
                $display("%d[%x]: %x => %x", i, a, i<8 ? ('h1 << i) : ('hff >> (i-8)), vo);
            end
        end
        // high address check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = 'h1ffff - i;
                we   = 1;
                vi   = i;
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                a    = 'h1ffff - i;
                we   = 0;
                $display("%d[%x]: %x => %x", i, a, i, vo);
            end
        end
		*/
        #20 $finish;
    end       
endmodule // spram8_tb
