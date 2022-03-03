///
/// ForthSuper - Outer Interpreter
///
`ifndef FORTHSUPER_OUTER
`define FORTHSUPER_OUTER
`include "../source/forthsuper.vh"
`include "../source/forthsuper_if.sv"    /// iBus32 or iBus8 interfaces
`include "../source/spram.sv"            /// memory management module
`include "../source/finder.sv"           /// dictionary word search module
`include "../source/atoi.sv"             /// string to number module
`include "../source/comma.sv"            /// memory append module
`include "../source/stack.sv"            /// data/return stack module
`include "../source/eforth.sv"           /// eForth inner interpreter

typedef enum logic [2:0] { RDY, FND, EXE, CMA, A2I, NUM, PSH } outer_sts;
module outer #(
    parameter TIB  = 'h0,                /// terminal input buffer address
    parameter MSZ  = 8,                  /// 8-bit memory data path
    parameter DSZ  = 32,                 /// data path width
    parameter ASZ  = 17,                 /// 128K address path
    parameter SS_DEPTH = 64              /// data stack depth
    ) (
    mb8_io.master         mb_if,         /// generic master to drive memory block
    input                 clk,           /// clock
    input                 rst,           /// reset
    input                 en,            /// enable
    input [MSZ-1:0]       mem,           /// return value from memory
    input [ASZ-1:0]       ctx0,          /// context address
    input [ASZ-1:0]       here0,         /// current dictionary top
    output logic          bsy            /// outer interpreter busy signal
    );
    // outer interpreter control
    outer_sts             _st, st;       /// outer interpreter states
    logic [ASZ-1:0]       tib;           /// address to terminal input buffer
    logic [ASZ-1:0]       ctx;           /// word search context
    logic [ASZ-1:0]       here;          /// dictionary
    logic                 compile = 1'b0;/// TODO: compile flag
    // finder control
    logic                 en_fdr;        /// finder module enable signal
    logic [ASZ-1:0]       aw_fdr;        /// search address of word
    logic [MSZ-1:0]       vw_fdr;        /// result return from memory block
    logic                 bsy_fdr;       /// finder module busy signal
    logic                 hit_fdr;       /// finder hit flag, 1: found
    logic [ASZ-1:0]       tib_fdr;       /// current tib pointer
    // atoi control
    logic                 en_a2i;        /// atoi module enable signal
    logic                 hex = 1'b0;    /// TODO: hex parser flag
    logic [MSZ-1:0]       ch;            /// character fetched from memory
    logic                 bsy_a2i;       /// atoi module busy signal
    logic                 af;            /// memory address advance flag
    logic [DSZ-1:0]       vo_a2i;        /// value returned from atoi module
    // data stack module
    logic [DSZ-1:0]       tos, _tos;
    logic                 en_ss;
    logic                 bsy_ss;
    // inner interpreter
    logic                 en_exe;
    logic [ASZ-1:0]       pfa = 'h0;     /// take ai when finder module exits
    opcode_e              _op;
    logic                 bsy_exe;
    // mock comma module
    logic                 en_cma;
    logic [ASZ-1:0]       ai_cma;
    logic [MSZ-1:0]       vi_cma;
    logic                 bsy_cma;
    // mock number
    logic                 en_num;
    logic                 bsy_num;
    // master buses
    mb8_io  fdr_if();
    mb8_io  a2i_if();
    mb8_io  exe_if();
    mb8_io  cma_if();
    // data stack
    ss_io #(SS_DEPTH, DSZ) ss_if();
    stack #(SS_DEPTH, DSZ) ss(.ss_if(ss_if.slave), .en(en_ss), .*);

    // finder and atoi modules
    finder fdr(
        .mb_if(fdr_if.master),
        .clk,
        .en(en_fdr),
        .aw(aw_fdr),
        .vw(vw_fdr),
        .bsy(bsy_fdr),
        .hit(hit_fdr),
        .tib(tib_fdr)
        );
    atoier a2i(
        .mb_if(a2i_if.master),
        .clk,
        .en(en_a2i),
        .hex(hex),
        .tib(tib_fdr),
        .ch,
        .bsy(bsy_a2i),
        .vo(vo_a2i)
        );
    eforth exe(
        .mb_if(exe_if.master),
        .ss_if,
        .clk,
        .rst,
        .en(en_exe),
        .pfa,
        ._op,
        .bsy(bsy_exe)
        );
    comma cma(
        .mb_if(cma_if.master),
        .clk,
        .en(cma_en),
        .ai(here0),
        .vi(_op),
        .bsy(cma_bsy)
        );
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) st <= RDY;
        else     st <= _st;
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        RDY: _st = en ? FND : RDY;
        FND: _st = bsy_fdr ? FND : (hit_fdr ? (compile ? CMA : EXE) : A2I);
        EXE: _st = bsy_exe ? EXE : RDY;
        CMA: _st = RDY;
        A2I: _st = bsy_a2i ? A2I : (compile ? NUM : PSH);   // TODO: atoi error handler
        NUM: _st = bsy_num ? NUM : RDY;                     // TODO: expand comma module for 4 bytes
        PSH: _st = RDY;
        default: _st  = RDY;
        endcase
    end
    ///
    /// next output logic - glue logic between modules
    ///
    always_comb begin
        {en_fdr,en_exe,en_a2i,en_num,en_ss} = 0;  // everyone off, keep the bus quiet
        aw_fdr = ctx0;
        case (st)
        RDY: if (en) begin
            en_fdr = 1'b1;
            {mb_if.we, mb_if.ai, mb_if.vi} = {1'b0, fdr_if.ai, 8'b0};
            aw_fdr = tib;
        end
        FND: begin
            en_fdr = 1'b1;
            {mb_if.we, mb_if.ai, mb_if.vi} = {1'b0, fdr_if.ai, 8'b0};
            aw_fdr = tib;
            if (!bsy_fdr) begin           /// finder completed
                en_fdr = 1'b0;
                if (hit_fdr) begin        /// a word is found in the dictionary
                    en_exe   = 1'b1;      // enable inner interpreter
                    pfa      = fdr_if.ai; // starting opcode address
                    $cast(_op, vw_fdr);   // opcode at pfa
                end
                else if (vw_fdr) begin    /// or, might be a number (run in parallel?)
                    en_a2i   = 1'b1;
                    mb_if.ai = tib_fdr;   // starting address for atoi module
                end
                else mb_if.ai = TIB;
            end
        end
        EXE: begin
            en_exe = bsy_exe;
            en_ss  = bsy_exe;
            {mb_if.we, mb_if.ai, mb_if.vi} = {exe_if.we, exe_if.ai, exe_if.vi};
        end
        CMA: begin
            {mb_if.we, mb_if.ai, mb_if.vi} = {1'b1, here, vw_fdr};
        end
        A2I: begin
            en_a2i = 1'b1;
            {mb_if.we, mb_if.ai, mb_if.vi} = {1'b0, a2i_if.ai, 8'b0};
        end
        NUM: begin
            en_num = 1'b1;
            /* TODO, encode a number onto pfa */
        end
        PSH: en_ss = 1'b1;
        endcase
    end

    assign vw_fdr = mem;
    assign ch     = mem;
    assign {_op}  = {mem};
    ///
    /// register values for state machine input
    ///
    task step;
        case (st)
        FND: begin
            if (!bsy_fdr) begin
                tib <= tib_fdr;           // keep tib from finder result
                if (hit_fdr) begin        /// a word is found in the dictionary
                    $display("FND: HIT, pfa = %04x[%02x] %s", pfa, vw_fdr, _op.name);
                end
                else if (vw_fdr) begin    /// or, might be a number (run in parallel?)
                    $display("FND: MISS, reset tib at %04x", tib_fdr); 
                end
                else $display("FND: EMPTY, reset tib at %04x", TIB); 
            end
        end
        A2I: begin
            if (!bsy_a2i) begin
                tib <= a2i_if.ai; // feed tib from atoi result
                $display("A2I: parsed num = %0d, tib=%04x", vo_a2i, a2i_if.ai);
            end                
        end
        PSH: begin
            ss_if.push(vo_a2i);           /// push latched data onto stack
            $display("PSH: pushed %0d", vo_a2i);
        end    
        endcase
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            tib  <= TIB;       // terminal input buffer (or UART target buffer)
            ctx  <= ctx0;      // initial context (dictionary word address)
            here <= here0;     // starting address of dictionary top
        end
        else step();
    end
endmodule: outer
`endif // FORTHSUPER_OUTER
