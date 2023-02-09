///
/// eForth1 - eForth Inner Interpreter
///
`ifndef EFORTH1_EFORTH
`define EFORTH1_EFORTH
`include "../source/eforth1_if.sv"     /// iBus32 or iBus8 interfaces
`include "../source/eforth1.vh"

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
    logic [DSZ-1:0]        _tmp;
    /// IO controls
    logic                  _as, as;       /// address select
    logic [1:0]            _ds, ds;       /// data select
    logic [ASZ-1:0]        ob;            /// output buffer pointers
    logic                  xds, xob;      /// IO latches

    task PUSH(input logic [DSZ-1:0] v); ss_if.push(ss_if.tos); ss_if.load(v); endtask
    task POP;                           ss_if.load(ss_if.pop()); endtask
    task ALU(input logic [DSZ-1:0] v);  ss_if.load(v);           endtask
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
        ss_if.op = SS_LOAD;
        _bsy  = bsy ? ph < 'h3 : en;          // single cycle for now
        _ph   = _bsy ? ph + 'h1 : 'h0;        // multi-cycle phase control
        _ip   = (bsy ? ip : pfa) + 'h1;       // prefetch next opcode
        xip   = 1'b1;
        xop   = 1'b1;
        case (_op)
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
        _SWAP: begin 
            case (ph)
            'h0: begin _ph = 'h1; xip = 1'b0; end
            'h1: begin _tmp = ss_if.pop(); xop = 1'b0; xip = 1'b0; end
            'h2: begin PUSH(_tmp); xop = 1'b0; xip = 1'b0; end
            default: _ph = 'h0;
            endcase
        end
        _ROT:  begin end
        _PICK: begin end
        /// @}
        /// @defgroup ALU ops
        /// @{
        _ADD: ALU(ss_if.pop() + ss_if.tos);
        _SUB: ALU(ss_if.pop() - ss_if.tos);
        _MUL: ALU(ss_if.pop() * ss_if.tos);
        _DIV: ALU(ss_if.pop() / ss_if.tos);
        _MOD: ALU(ss_if.pop() % ss_if.tos);
        _MDIV: begin end
        _SMOD: begin end
        _MSMOD: begin end
        _AND: ALU(ss_if.pop() & ss_if.tos);
        _OR:  ALU(ss_if.pop() | ss_if.tos);
        _XOR: ALU(ss_if.pop() ^ ss_if.tos);
        _ABS: ALU(ss_if.tos[31] ? -ss_if.tos : ss_if.tos);
        _NEG: ALU(-ss_if.tos);
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
    always_ff @(negedge clk) begin
        if (en) ss_if.update_tos;       // memory returns a half cycle earlier
    end            

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
            
        if (_bsy) begin
            $display(
                "%6t> pfa=%04x ip:ma=%04x:%04x[%02x] %s.%d",
                $time, pfa, _ip, _ma, _op, _op.name, ph);
        end
    end
endmodule: eforth
`endif // EFORTH1_EFORTH
