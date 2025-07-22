///
/// @file
/// @brief eForth1 - 8-bit Single-Port Memory Testbench
///
module top (
    input  logic       clk,
    output logic [7:0] vo
    );
    localparam ASZ  = 17;   // 128K
//    localparam DSZ  = 8;    // 8-bit data
  
    mb8_io      b8_if(clk);
    spram8_128k u1(b8_if.slave);

    initial begin
        // init clock
        repeat(2) @(negedge clk);

        // byte order check (direct access interface ports)
        for (int i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i[ASZ-1:0];
                b8_if.vi = i[7:0];
                b8_if.we = 1'b1;
            end
        end
        repeat(2) @(negedge clk);
        for (int i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i[ASZ-1:0];
                b8_if.we = 1'b0;
                $display("%d[%x]: %x => %x", i, b8_if.ai, i, b8_if.vo);
            end
        end
        
        // range check
        for (int i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.put(
                    (('h1 << i[ASZ-1:0]) | (i[ASZ-1:0] & 3)),
                    (i < 8) ? ('h1 << i) : ('hff >> (i-8))
                );
            end
        end
        repeat(2) @(negedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                vo = b8_if.get(('h1 << i[ASZ-1:0]) | (i[ASZ-1:0] & 3));
                $display("%d[%x]: %x => %x", i, b8_if.ai, i<8 ? ('h1 << i) : ('hff >> (i-8)), vo);
            end
        end
        // high address check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                b8_if.put('h1ffff - i[ASZ-1:0], i[7:0]);
            end
        end
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                vo = b8_if.get('h1ffff - i[ASZ-1:0]);
                $display("%d[%x]: %x => %x", i, b8_if.ai, i, vo);
            end
        end
        
        #20 $finish;
    end       
endmodule : top
