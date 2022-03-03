///
/// ForthSuper - eForth Inner Interpreter
///
`ifndef FORTHSUPER_EFORTH
`define FORTHSUPER_EFORTH
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces
`include "../source/forthsuper.vh"

module eforth #(
    parameter DSZ = 32,                   /// 32-bit data path
    parameter ASZ = 17,                   /// 128K address path
    parameter PAD = 'h80                  /// address of output buffer
    ) (
    mb8_io                 mb_if,         /// generic master to drive memory block
    ss_io                  ss_if,         /// data stack interface
    input                  clk,           /// clock
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
    logic [ASZ-1:0]        _ip, ip;       /// instruction pointer
    logic [ASZ-1:0]        _ma, ma;       /// memory address
    logic                  xop, xip, xma; /// latches
    /// stack ops
    sop_e                  ss_op;
    logic [DSZ-1:0]        _tos;
    /// IO controls
    logic                  _as, as;       /// address select
    logic [1:0]            _ds, ds;       /// data select
    logic [ASZ-1:0]        ob;            /// output buffer pointers
    logic                  xds, xob;      /// IO latches

    task PUSH(input logic [DSZ-1:0] v); _tos = v;        ss_op = SS_PUSH; endtask
    task POP;                           _tos = ss_if.s0; ss_op = SS_POP;  endtask
    task ALU(input logic [DSZ-1:0] v);  _tos = v;        ss_op = SS_ALU;  endtask
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        bsy <= en ? _bsy : 1'b0;              // module control
        ph  <= _ph;                           // phase control
    end
    ///
    /// eForth execution unit
    /// note: depends on opcode, multiple-cycle controlled by ph
    ///
    always_comb begin
        _bsy  = bsy ? (en && ph == 'h0) : en;
        _ph   = _bsy ? ph + 'h1 : 'h0;        // multi-cycle phase control
        _ip   = (bsy ? ip : pfa) + 'h1;       // prefetch next opcode
        xip   = 1'b1;
        xop   = 1'b1;
        ss_op = SS_LOAD;                      // default stack ops
        _tos  = ss_if.tos;
        case (op)
        ///
        /// @defgroup Execution flow ops
        /// @brief - DO NOT change the sequence here (see forth_opcode enum)
        /// @{
        ///
        _NOP:   begin /* do nothing */ end
        _DOVAR: begin end
        _DOLIT: begin end
        _BRAN: begin end
        _0BRAN: begin end
        _DONEXT: begin end
        _DOES: begin end
        _TOR: begin end
        _RFROM: begin end
        _RAT: begin end
        /// @}
        /// @defgroup Stack ops
        /// @brief - opcode sequence can be changed below this line
        /// @{
        _DUP:  PUSH(ss_if.tos);
        _DROP: POP();
        _OVER: PUSH(ss_if.s0);
        _SWAP: begin end
        _ROT:  begin end
        _PICK: begin end
        /// @}
        /// @defgroup ALU ops
        /// @{
        _ADD: ALU(ss_if.s0 + ss_if.tos);
        _SUB: ALU(ss_if.s0 - ss_if.tos);
        _MUL: ALU(ss_if.s0 * ss_if.tos);
        _DIV: ALU(ss_if.s0 / ss_if.tos);
        _MOD: ALU(ss_if.s0 % ss_if.tos);
        _MDIV: begin end
        _SMOD: begin end
        _MSMOD: begin end
        _AND: ALU(ss_if.s0 & ss_if.tos);
        _OR:  ALU(ss_if.s0 | ss_if.tos);
        _XOR: ALU(ss_if.s0 ^ ss_if.tos);
        _ABS: begin _tos = ss_if.tos[31] ? -ss_if.tos : ss_if.tos; ss_op = SS_LOAD; end
        _NEG: begin _tos = -ss_if.tos; ss_op = SS_LOAD; end
        _MAX: begin end
        _MIN: begin end
        /// @}
        /// @defgroup Logic ops
        /// @{
        _ZEQ: case (ph)
            'h0: begin end
            'h1: begin end
            endcase
        _ZLT: begin end
        _ZGT: begin end
        _EQ: begin end
        _LT: begin end
        _GT: begin end
        _NE: begin end
        _GE: begin end
        _LE: begin end
        /// @}
        /// @defgroup IO ops
        /// @{
        _BAT: begin end
        _BSTOR: begin end
        _HEX: begin end
        _DEC: begin end
        _CR: begin end
        _DOT: begin end
        _DOTR: begin end
        _UDOTR: begin end
        _KEY: begin end
        _EMIT: begin end
        _SPC: begin end
        _SPCS: begin end
        /// @}
        /// @defgroup Literal ops
        /// @{
        _LBRAC: begin end
        _RBRAC: begin end
        _BSLSH: begin end
        _STRQP: begin end
        _DOTQP: begin end
        _DOSTR: begin end
        _DOTSTR: begin end
        /// @}
        /// @defgroup Branching ops
        /// @brief - if...then, if...else...then
        /// @{
        _IF: begin end
        _ELSE: begin end
        _THEN: begin end
        /// @}
        /// @defgroup Loops
        /// @brief  - begin...again, begin...f until, begin...f while...repeat
        /// @{
        _BEGIN: begin end
        _AGAIN: begin end
        _UNTIL: begin end
        _WHILE: begin end
        _REPEAT: begin end
        /// @}
        /// @defgrouop For loops
        /// @brief  - for...next, for...aft...then...next
        /// @{
        _FOR: begin end
        _NEXT: begin end
        _AFT: begin end
        /// @}
        /// @defgrouop Compiler ops
        /// @{
        _COLON: begin end
        _SEMIS: begin end
        _VAR: begin end
        _CON: begin end
        _EXIT: begin end
        _EXEC: begin end
        _CREATE: begin end
        _TO: begin end
        _IS: begin end
        _QTO: begin end
        _AT: begin end
        _STOR: begin end
        _COMMA: begin end
        _ALLOT: begin end
        _PSTOR: begin end
        /// @}
        /// @defgroup Debug ops
        /// @{
        _HERE: begin end
        _UCASE: begin end
        _WORDS: begin end
        _TICK: begin end
        _SDUMP: begin end
        _SEE: begin end
        _DUMP: begin end
        _FORGET: begin end
        /// @}
        /// @defgroup Hardware specific ops
        /// @{
        _PEEK: begin end
        _POKE: begin end
        _CLOCK: begin end
        _DELAY: begin end
        _PIN: begin end
        _IN: begin end
        _OUT: begin end
        _ADC: begin end
        _DUTY: begin end
        _ATTC: begin end
        _SETUP: begin end
        _TONE: begin end
        /// @}
        _BYE: begin end
        _BOOT: begin end
        default: begin end
        endcase // (op)
    end
    ///
    /// register values for state machine input
    ///
    task step;
        mb_if.get_u8(_ip);                  // prefetch next opcode
        as  <= _as;
        if (xop) op  <= _op;
        if (xip) ip  <= _ip;
        if (xma) ma  <= _ma;
        if (xds) ds  <= _ds;
        if (xob) ob  <= ob + 1;
        if (bsy) begin
            case (ss_op)                    // data stack ops
            SS_LOAD: ss_if.load(_tos);
            SS_PUSH: ss_if.push(_tos);
            SS_POP:  void'(ss_if.pop());
            SS_ALU:  void'(ss_if.alu(_tos));
            endcase
        end
        $display(
            "%6t> pfa=%04x ip:ma=%04x:%04x[%02x] sp=%2x<%8x, %8x> %s.%d",
            $time, pfa, _ip, _ma, _op, ss_if.sp, ss_if.tos, ss_if.s0, _op.name, ph);
    endtask: step
    ///
    /// logic for current output
    ///
    always_ff @(posedge clk) begin
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
    end
endmodule: eforth
`endif // FORTHSUPER_EFORTH
