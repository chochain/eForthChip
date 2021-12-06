///
/// ForthSuper Dictionary Word Finder Testbench
///
`timescale 1ps / 1ps
`include "../source/spram.sv"
`include "../source/finder.sv"
module finder_tb;
    localparam ASZ  = 17;      // 128K
    localparam DSZ  = 8;       // 8-bit data
    localparam TIB  = 0;       // Terminal input buffer address
    localparam DICT = 'h10;    // dictionary starting address
    
    logic clk, rst, en;        // input signals
    logic bsy, hit;            // output signals
    logic [ASZ-1:0] aw;        // word address
    logic [DSZ-1:0] vw;        // memory value of word
    logic [2:0] st;            // DEBUG: finder state
    logic [ASZ-1:0] ao0, ao1;  // DEBUG output addresses

    integer lfa, here;
    string word_tib = "abcd";
    string word_list[4] = {
        "abcd",
        "efgh",
        "ijkl",
        "mnop"
    };

    iBus8       b8();                      // memory bus
    spram8_128k m0(b8.slave, clk);         // memory module
    finder      f0(.*, .bus(b8.master));   // word finder module
    
    always #10 clk  = ~clk;
        
    task reset(); begin
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    end
    endtask
        
    task add_u8([ASZ-1:0] ax, [7:0] vx);
        repeat(1) @(posedge clk) begin
            b8.we = 1'b1;
            b8.ai = ax;
            b8.vi = vx;
        end 
    endtask
    
    task add_word(string w);
        automatic integer n   = w.len();
        automatic integer pfa = here + 3 + n; 
        add_u8(here,     lfa & 'hff);
        add_u8(here + 1, lfa >> 8);
        add_u8(here + 2, n);
        for (integer i = 0; i < n; i = i + 1) begin
            add_u8(here + 3 + i, w[i]);
        end
        add_u8(pfa,     'hbe);
        add_u8(pfa + 1, 'hef);
        
        lfa  = here;
        here = pfa + 2;
    endtask;
        
    task setup_mem();
        // write
        for (integer i=0; i < word_tib.len(); i = i + 1) begin
            add_u8(TIB + i, word_tib.getc(i));
        end
        add_u8(TIB+word_tib.len(), 0);

        lfa  = 'hffff;
        here = DICT;
        for (integer wi=0; wi < $size(word_list); wi++) begin
            add_word(string'(word_list[wi]));
        end;
        $display("lfa=%x, here=%x", lfa, here);
        
        // verify - read back
        for (integer i=0; i < here + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8.we = 1'b0;
                b8.ai = i;
                $display("%x:%x", i, b8.vo);
            end
        end
    endtask
    
    assign vw = b8.vo;   // direct feed from memory to finder
        
    initial begin
        clk = 0;         // start the clock
        en  = 1'b0;      // disable finder
        reset();
        setup_mem();

        aw    = lfa;     // setup CONTEXT word address
        repeat (1) @(posedge clk);
        en    = 1'b1;    // enable finder
        aw    = TIB;     // set TIB word address to be find
        repeat(60) @(posedge clk);
        
        #20 $finish;
    end       
endmodule // finder_tb