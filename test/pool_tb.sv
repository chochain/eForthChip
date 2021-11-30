///
/// ForthSuper Memory Pool Testbench
///
`timescale 1ps / 1ps
`include "../source/pool.sv"
module pool_tb;
    localparam TIB  = 0;
    localparam DICT = 'h10;
    localparam ASZ  = 17;   // 64K
    localparam DSZ  = 8;    // 32-bit data
    logic           clk, rst, bsy;
    logic [1:0]     op;
    logic [2:0]     st;
    logic [ASZ-1:0] ai, ao0, ao1;
    logic [15:0]    lfa, here;
    logic [DSZ-1:0] vi, vo;
    logic           we, hit;
    
    string tib = "abcd";
    string word_list[4] = {
        "abcd",
        "efgh",
        "ijkl",
        "mnop"
    };

    pool dict(.clk, .rst, .op, .ai, .vi, .we, .vo, .bsy, .hit, .st, .ao0, .ao1);
    
    always #10 clk  = ~clk;
        
    task reset(); begin
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    end
    endtask
        
    task add_u8([ASZ-1:0] ax, [7:0] vx); begin
        repeat(1) @(posedge clk) begin
            op = W1;
            ai = ax;
            vi = vx;
        end            
    end    
    endtask
    
    task add_word(string w); begin
        automatic integer n   = w.len();
        automatic integer pfa = here + 3 + n; 
        add_u8(here,     lfa & 'hff);
        add_u8(here + 1, lfa >> 8);
        add_u8(here + 2, n);
        for (integer i = 0; i < n; i = i + 1) add_u8(here + 3 + i, w[i]);
        add_u8(pfa,     'hbe);
        add_u8(pfa + 1, 'hef);
        
        lfa  = here;
        here = pfa + 2;
    end
    endtask;
        
    task setup_mem(); begin
        // write
        for (integer i=0; i < tib.len(); i = i + 1) add_u8(TIB + i, tib.getc(i));
        add_u8(TIB+tib.len(), 0);

        lfa  = 'hffff;
        here = DICT;
        for (integer wi=0; wi < $size(word_list); wi++) begin
            add_word(string'(word_list[wi]));
        end;
        $display("lfa=%x, here=%x", lfa, here);
        
        // verify - read back
        for (integer i=0; i < here + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                op  = R1;
                ai  = i;
                $display("%x:%x", i, vo);
            end
        end

    end
    endtask
        
    initial begin
        clk = 0;
        reset();
        setup_mem();

        reset();
        ai = TIB;
        op = FIND;
        repeat(60) @(posedge clk);
        
        #20 $finish;
    end       
endmodule // pool_tb
