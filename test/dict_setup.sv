///
/// ForthSuper Dictionary Setup Testbench
///
`timescale 1ps / 1ps
`include "../source/forthsuper.vh"
`include "../source/spram.sv"
import FS1::*;
module dict_setup #(
    parameter TIB  = 'h0,
    parameter DICT = 'h100,     /// starting address of dictionary
    parameter DSZ  = 8,         /// 8-bit data path
    parameter ASZ  = 17         /// 128K address space
    ) (
    mb8_io b8_if,               /// 8-bit memory bus master
    input  clk,
    output logic [ASZ-1:0] ctx,
    output logic [ASZ-1:0] here
    );
    opcode_e op;                /// opcode, for num()
/*    
    word_s word_list[op.num()] = {
        '{ NOP,   "nop"  },
        '{ DUP,   "dup"  },
        '{ DROP,  "drop" },
        '{ OVER,  "over" },
        '{ SWAP,  "swap" },
        '{ ROT,   "rot"  },
        '{ PLUS,  "+"    },
        '{ MINUS, "-"    },
        '{ MUL,   "*"    },
        '{ DIV,   "/"    },
        '{ MOD,   "mod"  },
        '{ AND,   "and"  },
        '{ OR,    "or"   },
        '{ XOR,   "xor"  },
        '{ ABS,   "abs"  },
        '{ NEG,   "negate" },
        '{ EQ,    "="    },
        '{ LT,    "<"    },
        '{ GT,    ">"    },
        '{ NE,    "<>"   },
        '{ GE,    ">="   },
        '{ LE,    "<="   },
        '{ ZEQ,   "0="   },
        '{ ZLT,   "0<"   },
        '{ ZGT,   "0>"   },
        '{ MAX,   "max"  },
        '{ MIN,   "min"  }
    };
*/        
    word_s word_list[6] = {
        '{ NOP,   "nop"  },
        '{ DUP,   "dup"  },
        '{ DROP,  "drop" },
        '{ SWAP,  "swap" },
        '{ PLUS,  "+"    },
        '{ MINUS, "-"    }
    };
    string tib = "dup swap +";
    
    task add_u8([16:0] ax, [7:0] vx);
        repeat(1) @(posedge clk) begin
            b8_if.put_u8(ax, vx);
        end
    endtask: add_u8
    
    task add_word(string w, logic [7:0] o);
        automatic integer n   = w.len();
        automatic integer pfa = here + 3 + n; 
        add_u8(here,     ctx & 'hff);
        add_u8(here + 1, ctx >> 8);
        add_u8(here + 2, n);
        for (integer i = 0; i < n; i = i + 1) begin
            add_u8(here + 3 + i, w[i]);
        end
        add_u8(pfa, o);
        
        ctx  = here;
        here = pfa + 1;
    endtask: add_word

    task setup_mem;
        ctx  = 'hffff;
        here = DICT;
        // write
        foreach(word_list[i]) begin
            add_word(string'(word_list[i].name), word_list[i].op);
        end;
    endtask: setup_mem

    task setup_tib;
        for (integer i = 0; i < tib.len(); i = i + 1) begin
            add_u8(TIB + i, tib[i]);
        end
        add_u8(TIB + tib.len(), 'h0);
    endtask: setup_tib
endmodule: dict_setup
/*
module dict_setup_tb;
    localparam DICT = 'h100;      /// starting address of dictionary
    logic clk, rst, en;
    logic [16:0] ctx, here;
    
    mb8_io      b8_if();
    spram8_128k m0(b8_if.slave, clk);

    dict_setup #(DICT) dict(.*, .b8_if(b8_if.master));
    
    task reset;
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    endtask: reset
    
    task verify; 
        $display("lfa=%x, here=%x", ctx, here);
        // verify - read back
        for (integer i=DICT; i < here + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                b8_if.get_u8(i);
                $display("%x:%x", i, b8_if.vo);
            end
        end
    endtask: verify
    
    always #10 clk = ~clk;
        
    initial begin
        clk = 0;
        reset();
        dict.setup_mem();
        
        verify();
        
        #20 $finish;
    end
endmodule: dict_setup_tb
*/
