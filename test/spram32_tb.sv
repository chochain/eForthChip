///
/// ForthSuper Single-Port Memory Testbench
///
`timescale 1ps / 1ps
module spram32_tb;
    localparam ASZ  = 15;   // 32K
    localparam DSZ  = 32;   // 32-bit data
    logic clk;

    iBus32      bus();
    spram32_32k u1(.bus, .clk);
    
    task one_pass(); begin
        // byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                bus.ai = i;
                bus.we = 1;
                bus.vi = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                bus.ai = i;
			    bus.we = 0;
                $display("%d[%x]: %x => %x", i, bus.ai, (1 << i) | (i & 3), bus.vo);
            end
        end
        // range check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                bus.ai = 31 + (1 << i);
                bus.we = 1;
                bus.vi = (~i << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                bus.ai = 31 + (1 << i);
                bus.we = 0;
                $display("%d[%x]: %x => %x", i, bus.ai, (~i << i) | (i & 3), bus.vo);
            end
        end
        // high byte check
        for (integer i = 0; i < ASZ; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                bus.ai   = 'h7fff - i;
                bus.we   = 1;
                bus.vi   = (1 << i) | (i & 3);
            end
        end
        for (integer i = 0; i < ASZ + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                bus.ai = 'h7fff - i;
                bus.we = 0;
                $display("%d[%x]: %x => %x", i, bus.ai, (1 << i) | (i & 3), bus.vo);
            end
        end
    end
    endtask

    always #10 clk  = ~clk;

    initial begin
        clk    = 0;
		bus.ai = 0;
        
        // init clock
        repeat(2) @(posedge clk);
        
        for (integer j = 0; j < 3; j = j + 1) begin
            bus.bmsk = 4'b1111 >> j;
            one_pass();
        end

        #20 $finish;
    end       
endmodule // spram32_tb
