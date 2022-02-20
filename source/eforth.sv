///
/// ForthSuper - eForth Inner Interpreter
///
`ifndef FORTHSUPER_EFORTH
`define FORTHSUPER_EFORTH
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces
`include "../source/forthsuper.vh"
import FS1::*;
module eforth #(
    parameter DSZ = 32,                   /// 32-bit data path
    parameter ASZ = 17                    /// 128K address path
    ) (
    mb32_io                mb_if,         /// generic master to drive memory block
    ss_io                  ds_if,         /// data stack interface
    ss_io                  rs_if,         /// return stack interface
    input                  clk,           /// clock
    input                  en,            /// enable
    input [ASZ-1:0]        pfa,           /// instruction pointer (pfa of the 1st opcode)
    opcode_e               op,            /// opcode to be executed
    output logic           bsy            /// 0:busy, 1:done
    );
    logic                  _st, st;       /// FSM  states
    /// registers
    opcode_e               op0;
    logic [ASZ-1:0]        _ip,  ip;      /// instruction pointer
    logic [ASZ-1:0]        _ma,  ma;      /// memory address
    logic [DSZ-1:0]        _tos, tos;     /// top of stack
    logic                  xop, xip, xma, xt;   /// latches
    /// IO controls
    logic                  _as, as;       /// address select
    logic [1:0]            _ds, ds;       /// data select
    logic [ASZ-1:0]        ib, ob;        /// IO buffer pointers
    logic                  xds, xib, xob; /// IO latches
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) st <= 1'b0;
        else     st <= _st;
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        1'b0: _st = en;
        1'b1: _st = bsy;
        default: _st = 1'b0;
        endcase
    end
    ///
    /// eForth execution unit
    /// note: depends on opcode, multiple-cycle controlled by st
    ///
    always_comb begin
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
        _DUP: begin end
        _DROP: begin end
        _OVER: begin end
        _SWAP: begin end
        _ROT: begin end
        _PICK: begin end
        /// @}
        /// @defgroup ALU ops
        /// @{
        _ADD: begin end
        _SUB: begin end
        _MUL: begin end
        _DIV: begin end
        _MOD: begin end
        _MDIV: begin end
        _SMOD: begin end
        _MSMOD: begin end
        _AND: begin end
        _OR: begin end
        _XOR: begin end
        _ABS: begin end
        _NEG: begin end
        _MAX: begin end
        _MIN: begin end
        /// @}
        /// @defgroup Logic ops
        /// @{
        _ZEQ: begin end
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
        default: bsy = 1'b0;
        endcase // (op)
    end
    ///
    /// register values for state machine input
    ///
    task step;
//        $display(
//            "%6t> ip:ma=%04x:%04x[%02x] sp=%2x<%8x, %8x> %s.%d",
//            $time, ip, ma, mb_if.vo, ds_if.sp, ds_if.s, tos, op.name, st);
            as <= _as;
            if (xop) op0 <= op;
            if (xip) ip  <= _ip;
            if (xma) ma  <= _ma;
            if (xt)  tos <= _tos;
            if (xds) ds  <= _ds;
            if (xib) ib  <= ib + 1;
            if (xob) ob  <= ob + 1;
/*
            if      (sload) ss[sp] <= t;
            else if (spop)  begin sp <= sp - 1; sp1 <= sp1 - 1; end
            else if (spush) begin ss[sp1] <= t; sp <= sp + 1; sp1 <= sp1 + 1; end
            if (rload)      rs[rp] <= r_in;
            else if (rpop)  begin rp <= rp - 1; rp1 <= rp1 - 1; end
            else if (rpush) begin rs[rp1] <= r_in; rp <= rp + 1; rp1 <= rp1 + 1; end
 */
    endtask: step
    ///
    /// logic for current output
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            tos<= {DSZ{1'b0}};
            ma <= {ASZ{1'b0}};
            ip <= {ASZ{1'b0}};
            as <= 1'b0;
            ds <= 3;
            ib <= 'h1000;
            ob <= 'h1400;
        end
        else step();
    end
endmodule: eforth
`endif // FORTHSUPER_EFORTH
