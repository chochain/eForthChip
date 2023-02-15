///
/// eForth1 Stack Testbench
///
`timescale 1ps / 1ps
`include "../source/stack.sv"
module stack_tb;
    localparam DEPTH = 8;               // 64 cells
    localparam DSZ   = 16;              // 16-bit stack
    localparam FF    = 'hffffffff;
    localparam SSZ   = $clog2(DEPTH);
    logic clk, en;
    logic [DSZ-1:0] i, v;

    ss_io #(DEPTH, DSZ) ss_if(clk);
    stack #(DEPTH, DSZ) u1(.ss_if(ss_if.slave), .*);

    always #5 clk  = ~clk;
        
    function integer calc_v(input integer i);
        //calc_v = (i < DSZ) ? FF >> i : FF << (i - DSZ);
        calc_v = i;
    endfunction: calc_v
    
    initial begin
        $monitor("%6t> %0s %0x => %x[%0x]", $time, ss_if.op, v, ss_if.sp0, ss_if.s);
        clk = 1;
        // init clock
        en  = 1'b0; repeat(2) @(negedge clk);
        en  = 1'b1;
        
        ss_if.sp1 = 6'h0;
        // write
        for (i = 0; i != DEPTH - 2; i = i + 1) begin
            repeat(1) @(negedge clk) begin
                v = calc_v(i);
                ss_if.push(v);
            end
            /// one extra push/pop pair
            repeat(1) @(negedge clk) ss_if.push(calc_v(i + 'h100));
            repeat(1) @(negedge clk) ss_if.pop();
        end
        // read
        for (i = DEPTH - 1; i != 1; i = i - 1) begin
            repeat(1) @(negedge clk) ss_if.pop();
        end

        #20 $finish;
    end
endmodule: stack_tb
