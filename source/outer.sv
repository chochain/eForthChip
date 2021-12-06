///
/// ForthSuper - Outer Interpreter
///
`ifndef FORTHSUPER_OUTER
`define FORTHSUPER_OUTER
`include "../source/forthsuper_if.sv"    /// iBus32 or iBus8 interfaces
`include "../source/finder.sv"
`include "../source/atoi.sv"
typedef enum logic [2:0] { RDY, FND, EXE, CMA, A2I, NUM, PSH } outer_sts;
module outer #(
    parameter TIB  = 'h0,
    parameter DSZ  = 8,                  /// 8-bit data path
    parameter ASZ  = 17                  /// 128K address path
    ) (
    mb8_io                mb_if,         /// generic master to drive memory block
    input                 clk,           /// clock
    input                 en,            /// enable
    input [ASZ-1:0]       ctx0,          /// context address
    input [ASZ-1:0]       here0,
    // debug output        
    output                outer_sts st   /// state: DEBUG
    );
    // outer interpreter control
    outer_sts             _st;
    logic [ASZ-1:0]       ctx;           /// word search context
    logic [ASZ-1:0]       here;          /// dictionary 
    logic                 compile;
    // finder control
    logic                 en_fdr;
    logic [ASZ-1:0]       aw_fdr;
    logic [DSZ-1:0]       vw_fdr;
    logic                 bsy_fdr;
    logic                 hit_fdr;
    finder_sts            st_fdr;        /// DEBUG: finder state
    logic [ASZ-1:0]       ao0, ao1;      /// DEBUG: finder output addresses
    // atoi control
    logic                 en_a2i;
    logic                 hex;
    logic [7:0]           ch;
    logic                 bsy_a2i;
    logic                 af;
    logic [DSZ-1:0]       vo_a2i;
    atoi_sts              st_a2i;        /// DEBUG: atoi state
    // fake controls for inner interpreter, number, and data stack push
    logic                 en_exe, en_num, en_psh;
    logic                 bsy_exe, bsy_num, bsy_psh;

    finder f0(.clk,
        .en(en_fdr),
        .aw(aw_fdr),
        .vw(vw_fdr),
        .bsy(bsy_fdr),
        .hit(hit_fdr),
        .st(st_fdr),
        .ao0,
        .ao1,
        .mb_if(mb_if.master));
    atoi a0(.clk,
        .en(en_a2i),
        .hex(hex),
        .ch, 
        .bsy(bsy_a2i),
        .af,
        .vo(vo_a2i),
        .st(st_a2i));
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
        NUM: _st = bsy_num ? NUM : RDY;
        PSH: _st = bsy_psh ? PSH : RDY;
        default: _st  = RDY;
        endcase
    end
    ///
    /// logic for memory access
    /// Note: one-hot encoding automatically done by synthesizer
    ///
    assign vw_fnd = mb_if.vo;      // feed memory value to finder
    assign ch     = mb_if.vo;      // feed memory value to atoi

    always_comb begin
        {en_fdr, en_a2i, en_num, en_psh} = 0;
        mb_if.we  = 1'b0;
        mb_if.ai  = ctx;
        aw_fdr    = ctx;
        case (st)
        FND: begin
            en_fdr = 1'b1;
            aw_fdr = TIB;
        end
        EXE: begin
            en_exe  = 1'b1;
            bsy_exe = 1'b0;         // TODO: fake
        end
        CMA: mb_if.put_u8(here, vw_fnd);
        A2I: begin
            en_a2i    = 1'b1;
            mb_if.ai  = TIB;        // read from nfa
        end
        NUM: begin
            en_num  = 1'b1;
            bsy_num = 1'b0;         // TODO: fake
        end
        PSH: begin
            en_psh  = 1'b1;
            bsy_num = 1'b0;         // TODO: fake
        end
        default: mb_if.ai = ctx;
        endcase
    end
    ///
    /// register values for state machine input
    ///
    task step;
        case (st)
        A2I: mb_if.ai <= mb_if.ai + af;
        endcase
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            ctx  <=  ctx0;          // initial context (dictionary word address)
            here <= here0;
        end
        else step();
    end
endmodule: outer
`endif // FORTHSUPER_OUTER
