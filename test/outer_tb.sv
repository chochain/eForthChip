///
/// ForthSuper Outer Interpreter Testbench
///
`timescale 1ps / 1ps
`include "../source/outer.sv"
`include "../test/dict_setup.sv"
module outer_tb;
    localparam TIB  = 'h0;
    localparam DICT = 'h100;      /// starting address of dictionary
    logic clk, rst;
    logic en, bsy;                /// outer interpreter enable signal
    logic [16:0] ctx0, here0;     /// word context, dictionary top
    logic [7:0]  mem;             /// value fetch from memory
    
    mb8_io      b8_if();
    spram8_128k m0(b8_if.slave, clk);

    dict_setup #(TIB, DICT) dict(.b8_if(b8_if.master), .clk, .ctx(ctx0), .here(here0));
    outer      #(TIB) outi(
        .mb_if(b8_if.master), .clk, .rst, .en, .mem, .ctx0, .here0, .bsy);

    task reset;
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    endtask: reset

    always #5 clk  = ~clk;

    assign mem = b8_if.vo;
        
    initial begin
        clk = 0;
        en  = 1'b0;
        reset();
        dict.setup_mem();
        dict.setup_tib();

        en  = 1'b1;
        repeat(150) @(posedge clk);
        
        #20 $finish;
    end
endmodule: outer_tb
