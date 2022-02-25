///
/// ForthSuper Dictionary Setup Testbench
///
`timescale 1ps / 1ps
`include "../source/forthsuper_if.sv"
`include "../source/forthsuper.vh"

module dict_setup #(
    parameter TIB  = 'h0,       /// terminal input buffer
    parameter DICT = 'h100,     /// dictionary starting address
    parameter ASZ  = 17         /// 128K address space
    ) (
    mb8_io b8_if,               /// 8-bit memory bus master
    input  clk,
    output logic [ASZ-1:0] ctx,
    output logic [ASZ-1:0] here
    );
/*  use the shorter version below for debugging
    opcode_e op;                /// opcode, for num()
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
        '{ _NOP,   "nop"  },
        '{ _DUP,   "dup"  },
        '{ _DROP,  "drop" },
        '{ _SWAP,  "swap" },
        '{ _ADD,   "+"    },
        '{ _SUB,   "-"    }
    };
    string tib = "123 dup + 456 -";

    task add_u8(input logic [ASZ-1:0] ax, [7:0] vx);
        repeat(1) @(posedge clk) begin
            b8_if.put_u8(ax, vx);
        end
    endtask: add_u8

    task add_word(string w, input logic [7:0] o);
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
        $display("dictionary at %04x:", DICT);
        foreach(word_list[i]) begin
            automatic word_s w = word_list[i];
            add_word(string'(w.name), w.op);
            $display("[%04x,%04x] op=%02x %s", ctx, here, w.op, w.name);
        end;
    endtask: setup_mem

    task setup_tib;
        $display("tib at %04x: [%s]", TIB, tib);
        foreach(tib[i]) begin
            add_u8(TIB + i, tib[i]);
        end
        add_u8(TIB + tib.len(), 'h0);
        //
        // prefetch TIB (prep for finder)
        //
        repeat(1) @(posedge clk) begin
            b8_if.we = 1'b0;
            b8_if.ai = TIB;
        end
    endtask: setup_tib
endmodule: dict_setup
/*
module dict_setup_tb;
    localparam TIB  = 'h0;        /// starting address of TIB
    localparam DICT = 'h100;      /// starting address of dictionary
    localparam ASZ  = 17;
    logic clk, rst, en;
    logic [16:0] ctx, here;

    mb8_io      b8_if();
    spram8_128k m0(b8_if.slave, ~clk);

    dict_setup  dict(.b8_if(b8_if.master), .*);

    task reset;
        repeat(1) @(posedge clk) rst = 1;
        repeat(1) @(posedge clk) rst = 0;
    endtask: reset

    task verify;
        $display("lfa=%x, here=%x", ctx, here);
        // verify - read back
        for (integer i=TIB; i < here + 4; i = i + 1) begin
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
        dict.setup_tib();
        dict.setup_mem();

        verify();

        #20 $finish;
    end
endmodule: dict_setup_tb
*/

