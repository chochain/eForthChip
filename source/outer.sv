///
/// ForthSuper - Outer Interpreter
///
`ifndef FORTHSUPER_OUTER
`define FORTHSUPER_OUTER
`include "../source/forthsuper_if.sv"    /// iBus32 or iBus8 interfaces
`include "../source/finder.sv"           /// dictionary word search module
`include "../source/atoi.sv"             /// string to number module
`include "../source/inner.sv"            /// mock inner interpreter module
`include "../source/comma.sv"            /// memory append module
typedef enum logic [2:0] { RDY, FND, EXE, CMA, A2I, NUM, PSH } outer_sts;
module outer #(
    parameter TIB  = 'h0,                /// terminal input buffer address
    parameter DSZ  = 8,                  /// 8-bit data path
    parameter ASZ  = 17                  /// 128K address path
    ) (
    mb8_io.master         mb_if,         /// generic master to drive memory block
    input                 clk,           /// clock
    input                 en,            /// enable
    input [DSZ-1:0]       mem,           /// return value from memory
    input [ASZ-1:0]       ctx0,          /// context address
    input [ASZ-1:0]       here0          /// current dictionary top
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
    logic [DSZ-1:0]       vw_fdr;        /// result return from memory block
    logic                 bsy_fdr;       /// finder module busy signal
    logic                 hit_fdr;       /// finder hit flag, 1: found
    logic [ASZ-1:0]       tib_fdr;       /// current tib pointer
    // atoi control
    logic                 en_a2i;        /// atoi module enable signal
    logic                 hex = 1'b0;    /// TODO: hex parser flag
    logic [7:0]           ch;            /// character fetched from memory
    logic                 bsy_a2i;       /// atoi module busy signal
    logic                 af;            /// memory address advance flag
    logic [31:0]          vo_a2i;        /// value returned from atoi module
    // mock inner interpreter
    logic                 en_exe;        
    logic [ASZ-1:0]       pfa;           /// take ai when finder module exits
    logic [7:0]           op;
    logic                 bsy_exe;
    // mock comma module
    logic                 en_cma;
    logic [ASZ-1:0]       ai_cma;
    logic [DSZ-1:0]       vi_cma;
    logic                 bsy_cma;
    // mock stack module
    // mock number, and data stack
    logic                 en_num, en_psh;
    logic                 bsy_num, bsy_psh;
    // master buses
    mb8_io fdr_if();
    mb8_io exe_if();
    mb8_io cma_if();
    mb8_io a2i_if();
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
        .ch, 
        .bsy(bsy_a2i),
        .vo(vo_a2i)
        );
    inner exe(
        .mb_if(exe_if.master),
        .clk,
        .en(en_exe),
        .pfa,
        .op,
        .bsy(bsy_exe)
        );
    comma cma(
        .mb_if(cma_if.master),
        .clk,
        .en(cma_en),
        .ai(here0),
        .vi(op),
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
        NUM: _st = bsy_num ? NUM : RDY;                      // TODO: expand comma module for 4 bytes
        PSH: _st = bsy_psh ? PSH : RDY;
        default: _st  = RDY;
        endcase
    end
    ///
    /// next output logic - glue logic between modules
    ///
    always_comb begin
        {en_fdr,en_exe,en_a2i,en_num,en_psh} = 0;  // everyone off, keep the bus quiet
        aw_fdr = ctx0;
        case (st)
        RDY: if (en) begin
            en_fdr   = 1'b1;
            mb_if.we = 1'b0;
            mb_if.ai = fdr_if.ai;
            aw_fdr   = tib;
        end
        FND: begin
            en_fdr   = 1'b1;
            mb_if.we = 1'b0;
            mb_if.ai = fdr_if.ai;
            aw_fdr   = tib;
            if (!bsy_fdr) begin
                pfa = fdr_if.ai;
                if (hit_fdr) en_exe = 1'b1;  // since we have the opcode and pfa here
                else begin
                    en_a2i   = 1'b1;
                    mb_if.ai = tib_fdr;      // enable inner or atoi module 1-cycle earlier
                end
            end
        end
        EXE: if (bsy_exe) en_exe = 1'b1;
        CMA: begin
            mb_if.we = 1'b1;
            mb_if.ai = here;
            mb_if.vi = vw_fdr;
        end
        A2I: begin
            en_a2i   = 1'b1;
            if (a2i_if.ai) begin
                mb_if.we = 1'b0;
                mb_if.ai = a2i_if.ai;
            end
        end
        NUM: en_num = 1'b1;
        PSH: en_psh = 1'b1;
        endcase
    end
    
    assign vw_fdr = mem;
    assign ch     = mem;
    assign op     = mem;
    ///
    /// register values for state machine input
    ///
    task step;
        case (st)
        FND: begin
            if (!bsy_fdr) tib <= tib_fdr;    // collect tib from finder module
        end
        A2I: begin
            if (!bsy_a2i) tib <= a2i_if.ai; // collect tib from atoi module
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
