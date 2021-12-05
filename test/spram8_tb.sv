///
/// ForthSuper 8-bit Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram8_tb;
    localparam ASZ  = 17;   // 128K
    localparam DSZ  = 8;    // 8-bit data
    logic clk;
   
    iBus8       b8();
    spram8_128k u1(b8.slave, clk);

    always #10 clk = ~clk;

    initial begin
        clk = 0;

        // init clock
        repeat(2) @(posedge clk);

        // byte order check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b1;
                b8.ai = i;
                b8.vi = i;
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b0;
                b8.ai = i;
                $display("%d[%x]: %x => %x", i, b8.ai, i, b8.vo);
            end
        end
        
        // range check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b1;
                b8.ai = ('h1 << i) | (i & 3);
                b8.vi = (i < 8) ? ('h1 << i) : ('hff >> (i-8));
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b0;
                b8.ai = ('h1 << i) | (i & 3);
                $display("%d[%x]: %x => %x", i, b8.ai, i<8 ? ('h1 << i) : ('hff >> (i-8)), b8.vo);
            end
        end
        // high address check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b1;
                b8.ai = 'h1ffff - i;
                b8.vi = i;
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b0;
                b8.ai = 'h1ffff - i;
                $display("%d[%x]: %x => %x", i, b8.ai, i, b8.vo);
            end
        end
        
        #20 $finish;
    end       
endmodule // spram8_tb
