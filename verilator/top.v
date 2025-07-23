///
/// @file
/// @brief eForth1 - 8-bit Single-Port Memory Testbench
///
module top (
    input logic         clk,
    output logic [16:0] ai,
    output logic [7:0]  vi, 
    output logic [7:0]  vo
    );
    localparam ASZ  = 17;   // 128K
  
    mb8_io      b8_if(clk);
    spram8_128k u1(b8_if.slave);

    assign ai = b8_if.ai;
    assign vi = b8_if.vi;

    initial begin
        if ($test$plusargs("trace") != 0) begin
            $display("Tracing to logs/vlt_dump.vcd...");
            $dumpfile("logs/vlt_dump.vcd");
            $dumpvars();
        end
        vo = 0;

        // init clock
        repeat(2) @(negedge clk);

        $display("byte order check (port direct write)");
        for (int i = 0; i < ASZ; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i[ASZ-1:0];
                b8_if.vi = i[7:0];
                b8_if.we = 1'b1;
                vo       = b8_if.vo;
            end
        end
        $display("byte order check (port direct read)");
        repeat(2) @(negedge clk);
        for (int i = 0; i < ASZ + 4; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.ai = i[ASZ-1:0];
                b8_if.we = 1'b0;
                vo       = b8_if.vo;
            end
        end

        $display("range check (write via interface)");
        for (int i = 0; i < ASZ; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.put(
                    (('h1 << i[ASZ-1:0]) | (i[ASZ-1:0] & 3)),
                    (i < 8) ? ('h1 << i) : ('hff >> (i-8))
                );
                vo = b8_if.vo;
            end
        end
        $display("range check (read via interface)");
        repeat(2) @(negedge clk);
        for (integer i = 0; i < ASZ + 4; i++) begin
            repeat(1) @(negedge clk) begin
                vo = b8_if.get(('h1 << i[ASZ-1:0]) | (i[ASZ-1:0] & 3));
            end
        end

        $display("high address write");
        for (integer i = 0; i < ASZ; i++) begin
            repeat(1) @(negedge clk) begin
                b8_if.put('h1ffff - i[ASZ-1:0], i[7:0]);
                vo = b8_if.vo;
            end
        end
       
        $display("high address read");
        repeat(2) @(posedge clk);
        for (integer i = 0; i < ASZ + 4; i++) begin
            repeat(1) @(negedge clk) begin
                vo = b8_if.get('h1ffff - i[ASZ-1:0]);
            end
        end

        #20 $finish;
    end       
endmodule : top
