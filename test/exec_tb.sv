///
/// ForthSuper Execution Unit Testbench
///
`timescale 1ps / 1ps
`include "../source/exec.sv"
`include "../source/spram.sv"
module exec_tb;
    localparam DSZ   = 32;              // 32-bit stack
    localparam ASZ   = 17;              // address width
    localparam DEPTH = 64;              // 64 cells
    localparam SSZ   = $clog2(DEPTH);
    localparam IP0   = 'h100;
    logic clk, rst, en_xu, en_ds;
    logic [ASZ-1:0] ip0 = IP0;
    logic [DSZ-1:0] s0 = 'h0;
    opcode_e        op  = _NOP;
    logic           pop;

    mb8_io      b8_if();
    mb8_io      op_if();
    ss_io       ds_if();
    spram8_128k m0(.b8_if(b8_if.slave), .clk);
    stack       ds(.ss_if(ds_if.slave), .en(en_ds), .*);
    exec        xu(
        .mb_if(op_if.master),
        .ds_if(ds_if.master),
        .clk, .rst, .en(en_xu), .ip0, .op, .pop);

    always #10 clk  = ~clk;
        
    task reset;
        rst = 1'b1; repeat(2) @(posedge clk);
        rst = 1'b0;
    endtask: reset
    
    task put_mem([ASZ-1:0] ai, [DSZ-1:0] vi);
        repeat(1) @(posedge clk) b8_if.put_u8(ai, vi);
    endtask: put_mem
    
    task get_mem([ASZ-1:0] ai);
        repeat(1) @(posedge clk) b8_if.get_u8(ai);
    endtask: get_mem
    
    task push_ds([DSZ-1:0] vi);
        repeat(1) @(posedge clk) ds_if.push(vi);
    endtask: push_ds

    task setup;
        reset();
        // setup stack and opcode memory
        for (integer i = 0; i < DSZ; i = i + 1) begin
            put_mem(IP0 + i, (i % 2) == 0 ? _ADD : _SUB);
        end
        en_ds = 1'b1;
        for (integer i = DSZ + 10; i >= 10; i = i - 1) begin
            push_ds(i);
        end
    endtask: setup
    
    always_comb begin
        if (en_xu) {b8_if.we, b8_if.ai, op} = {op_if.we, op_if.ai, b8_if.vo};
    end
    
    initial begin
        {clk, en_xu, en_ds} = 0;
        setup();
        // start execution unit
        en_xu = 1'b1;
        repeat(30) @(posedge clk);

        #20 $finish;
    end       
endmodule: exec_tb
