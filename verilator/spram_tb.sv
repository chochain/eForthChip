///
/// @file
/// @brief eForth1 - 8-bit Single-Port Memory Testbench
///
module top (
    input logic         clk,
    input logic         rst,   /// not used, for testsing only
    output logic [16:0] ai,
    output logic [7:0]  vi, 
    output logic [7:0]  vo
    );
    localparam ASZ  = 17;      /// 128K
    logic [7:0] vx;            ///< expected result
  
    mb8_io      b8_if(clk);
    spram8_128k u1(b8_if);

    assign ai = b8_if.ai;
    assign vi = b8_if.vi;

    initial begin
        int i;
        vo = 0;

        repeat(2) @(negedge clk);               /// stablize clock
       
        $display("write - low addr sequential ================================");
        for (i = 0; i < ASZ; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i[ASZ-1:0];
                b8_if.vi = i[7:0];
                b8_if.we = 1'b1;
                vo       = b8_if.vo;
            end
        end
        repeat(2) @(negedge clk);
       
        $display("read - low addr sequential ---------------------------------");
        for (i = 0; i < ASZ + 4; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i[ASZ-1:0];
                b8_if.we = 1'b0;
                vo       = b8_if.vo;
            end
            assert(i > 0 && i < ASZ+1 && vo != vx) 
                $display("*** i[%2d] %h != %h\n", i, vo, vx);
            vx  = i[7:0];                     /// expected, 1-cycle delay
        end
        repeat(2) @(negedge clk);

        $display("write - high addr sequential ===============================");
        for (i = 0; i < ASZ; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = 'h1ffff - i[ASZ-1:0];
                b8_if.vi = i[7:0];
                b8_if.we = 1'b1;
                vo = b8_if.vo;
            end
        end
        repeat(2) @(negedge clk);
       
        $display("read - high addr sequential -------------------------------");
        for (i = 0; i < ASZ + 4; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = 'h1ffff - i[ASZ-1:0];
                b8_if.we = 1'b0;
                vo = b8_if.vo;
            end
            assert(i > 0 && i < ASZ+1 && vo != vx) 
                $display("*** i[%2d] %h != %h\n", i, vo, vx);
            vx  = i[7:0];
        end
        repeat(2) @(negedge clk);

        $display("write - odd addr random ===================================");
        for (i = 0; i < ASZ; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = ('h1 << i[ASZ-1:0]) | (i[ASZ-1:0] & 3);
                b8_if.vi = (i < 8) ? ('h1 << i) : ('hff >> (i-8));
                b8_if.we = 1'b1;
                vo = b8_if.vo;
            end
        end
        repeat(2) @(negedge clk);
       
        $display("read - odd addr random -----------------------------------");
        for (i = 0; i < ASZ + 4; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = ('h1 << i[ASZ-1:0]) | (i[ASZ-1:0] & 3);
                b8_if.we = 1'b0;
                vo = b8_if.vo;
            end
            assert(i > 0 && i < ASZ+1 && vo != vx) 
                $display("*** i[%2d] %h != %h\n", i, vo, vx);
            vx = (i < 8) ? ('h1 << i) : ('hff >> (i-8));
        end

        #2 $finish;
    end       
endmodule: top
