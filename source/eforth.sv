///
/// eForth1 - eForth Inner Interpreter
///
`ifndef EFORTH1_EFORTH
`define EFORTH1_EFORTH
`include "../source/eforth1_if.sv"     /// iBus32 or iBus8 interfaces
`include "../source/eforth1.vh"

module eforth #(
    parameter DSZ = 16,                   /// 16-bit data path width
    parameter ASZ = 17,                   /// 17-bit (128K) address path width
    parameter PAD = 'h80                  /// address of output buffer
    ) (
    mb_io                  mb_if,         /// generic master to drive memory block
    ss_io                  ss_if,         /// data stack interface
    input                  rst,           /// reset
    input                  en,            /// enable
    input [ASZ-1:0]        pfa,           /// instruction pointer (pfa of the 1st opcode)
    opcode_e               _op,           /// opcode to be executed
    output logic           bsy            /// 0:busy, 1:done
    );
    logic                  _bsy;          /// inner interpreter states
    logic [2:0]            _ph, ph;       /// phases for multiple-cycle opcodes
    /// registers
    opcode_e               op;
    logic [DSZ-1:0]        t;             /// TOS
    logic [ASZ-1:0]        _ip, ip;       /// instruction pointer
    logic [ASZ-1:0]        _ma, ma;       /// memory address
    logic                  xop, xip, xma; /// latches
    logic [DSZ-1:0]        _tmp;
    /// IO controls
    logic                  _as, as;       /// address select
    logic [1:0]            _ds, ds;       /// data select
    logic [ASZ-1:0]        ob;            /// output buffer pointers
    logic                  xds, xob;      /// IO latches

    task PUSH(input logic [DSZ-1:0] v); ss_if.push(ss_if.t); ss_if.load(v); endtask
    task POP;                           ss_if.load(ss_if.pop()); endtask
    task ALU(input logic [DSZ-1:0] v);  ss_if.load(v); endtask
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge mb_if.clk) begin
        bsy <= en ? _bsy : 1'b0;              // module control
        ph  <= _ph;                           // phase control
    end
    ///
    /// eForth execution unit
    /// note: depends on opcode, multiple-cycle controlled by ph
    ///
    always_comb begin
        ss_if.op = SS_LOAD;
        _bsy  = bsy ? ph < 'h3 : en;          // single cycle for now
        _ph   = _bsy ? ph + 'h1 : 'h0;        // multi-cycle phase control
        _ip   = (bsy ? ip : pfa) + 'h1;       // prefetch next opcode
        xip   = 1'b1;
        xop   = 1'b1;
        case (_op)
        ///
        /// @defgroup Execution flow ops
        /// @{
        _NOP:
        _BYE:
        _QRX:
        _TXSTO:
        _DOLIT:
        _DOVAR:
        _EXECU:
        _ENTER:
        _EXIT:
        _DONEXT:
        _0BRAN:
        _BRAN:
        /// @}
        /// @defgroup Memory Access ops
        /// @{
        _STORE:
        _PSTOR:
        _AT:
        _CSTOR:
        _CAT:
        _RFROM:
        _RAT:
        _TOR:
        /// @}
        /// @defgroup Stack ops
        /// @{
        _DROP: POP();
        _DUP:  PUSH(ss_if.t);
        _SWAP: begin 
            case (ph)
            'h0: begin _ph = 'h1; xip = 1'b0; end
            'h1: begin _tmp = ss_if.pop(); xop = 1'b0; xip = 1'b0; end
            'h2: begin PUSH(_tmp); xop = 1'b0; xip = 1'b0; end
            default: _ph = 'h0;
            endcase
        end
        _OVER: PUSH(ss_if.s0);
        _ROT:
        _PICK:
        /// @}
        /// @defgroup ALU ops
        /// @{
        _AND: ALU(ss_if.pop() & ss_if.t);
        _OR:  ALU(ss_if.pop() | ss_if.t);
        _XOR: ALU(ss_if.pop() ^ ss_if.t);
        _INV:
        _LSH:
        _RSH:
        _ADD: ALU(ss_if.pop() + ss_if.t);
        _SUB: ALU(ss_if.pop() - ss_if.t);
        _MUL: ALU(ss_if.pop() * ss_if.t);
        _DIV: ALU(ss_if.pop() / ss_if.t);
        _MOD: ALU(ss_if.pop() % ss_if.t);
        _NEG:
        /// @}
        /// @defgroup Logic ops
        /// @{
        _GT:
        _EQ:
        _LT:
        _ZEQ: case (ph)
            'h0: begin end
            'h1: begin end
            endcase
        _ZGT:
        _ZLT:
        /// @}
        /// @defgroup Misc. ops
        /// @{
        _ONEP:
        _ONEM:
        _QDUP:
        _DEPTH:
        _RP:
        _ULESS:
        /// @}
        /// @defgroup Misc. ops
        /// @{
        _UMMOD:
        _UMSTAR:
        _MSTAR:
        _UMPLUS:
        _DNEG:
        _DADD:
        _DSUB:
        /// @}
        default: begin end
        endcase // (op)
    end
    ///
    /// register values for state machine input
    ///
    task step;
        mb_if.get_u8(_ip);              // prefetch next opcode
        as  <= _as;
        if (xop) op  <= _op;
        if (xip) ip  <= _ip;
        if (xma) ma  <= _ma;
        if (xds) ds  <= _ds;
        if (xob) ob  <= ob + 1;
    endtask: step
    ///
    /// logic for current output
    ///
    always_ff @(negedge mb_if.clk) begin
        if (en) ss_if.update_tos;       // memory returns a half cycle earlier
    end            

    always_ff @(posedge mb_if.clk) begin
        if (rst) begin
            ma <= 0;
            as <= 1'b0;
            ds <= 3;
            ob <= PAD;
        end
        else if (!en) begin
            ip <= pfa;
            op <= _NOP;
        end
        else step();
            
        if (_bsy) begin
            $display(
                "%6t> pfa=%04x ip:ma=%04x:%04x[%02x] %s.%d",
                $time, pfa, _ip, _ma, _op, _op.name, ph);
        end
    end
endmodule: eforth
`endif // EFORTH1_EFORTH
