///
/// ForthSuper Dictionary Setup Testbench
///
`timescale 1ps / 1ps
`include "../source/pool.sv"
`include "../source/opcode.sv"
module dict_setup;
    localparam DICT = 'h100;
    localparam ASZ  = 17;      // 64K
    localparam DSZ  = 8;       // 32-bit data
    
    pool_ops op;               // MMU opcodes
    pool_sts st;               // DEBUG: pool state
    logic clk, rst;            // input signals
    logic bsy, we, hit;        // output signals
    logic [ASZ-1:0] ai;        // input address
    logic [ASZ-1:0] ao0, ao1;  // DEBUG output addresses
    logic [DSZ-1:0] vi, vo;    // I/O values

    integer         ctx, here; // control variables

    word word_list[$size(opcode)] = {
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
    pool dict(.clk, .rst, .op, .ai, .vi, .we, .vo, .bsy, .hit, .st, .ao0, .ao1);

    always #10 clk = ~clk;
    
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
    
    task add_word(string w, logic [7:0] o); begin
        automatic integer n   = w.len();
        automatic integer pfa = here + 3 + n; 
        add_u8(here,     ctx & 'hff);
        add_u8(here + 1, ctx >> 8);
        add_u8(here + 2, n);
        for (integer i = 0; i < n; i = i + 1) add_u8(here + 3 + i, w[i]);
        add_u8(pfa,      o);
        
        ctx  = here;
        here = pfa + 1;
    end
    endtask; // add_word

    task setup_mem(); begin
        automatic integer n = $size(word_list);
        ctx  = 'hffff;
        here = DICT;
        // write
        for (integer wi=0; wi < n; wi++) begin
            add_word(string'(word_list[wi].name), word_list[wi].op);
        end;
        $display("lfa=%x, here=%x", ctx, here);
/*        
        // verify - read back
        for (integer i=DICT; i < here + 4; i = i + 1) begin
            repeat(1) @(posedge clk) begin
                op  = R1;
                ai  = i;
                $display("%x:%x", i, vo);
            end
        end
*/        
    end
    endtask
        
    initial begin
        clk   = 0;
        reset();
        setup_mem();
        
        #20 $finish;
    end
endmodule // dict_setup
