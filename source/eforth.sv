///
/// ForthSuper - eForth Inner Interpreter
///
`ifndef FORTHSUPER_EFORTH
`define FORTHSUPER_EFORTH
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces
`include "../source/forthsuper.vh"

module eforth #(
    parameter DSZ      = 32,              /// 32-bit data path
    parameter ASZ      = 17,              /// 128K address path
    parameter SS_DEPTH = 64,              /// data stack depth
    parameter RS_DEPTH = 64               /// return stack depth
    ) (
    mb8_io                 mb_if,         /// generic master to drive memory block
    ss_io                  ss_if,         /// data stack interface
    input                  clk,           /// clock
    input                  en,            /// enable
    input [ASZ-1:0]        pfa,           /// instruction pointer (pfa of the 1st opcode)
    opcode_e               op1,           /// opcode to be executed
    output logic           bsy            /// 0:busy, 1:done
    );
    logic                  _st, st;       /// FSM  states
    /// registers
    opcode_e               op;
    logic [ASZ-1:0]        _ip,  ip;      /// instruction pointer
    logic [ASZ-1:0]        _ma,  ma;      /// memory address
    logic [DSZ-1:0]        _tos, tos;     /// top of stack
    logic                  xop, xip, xma, xt;   /// latches
    /// IO controls
    logic                  _as, as;       /// address select
    logic [1:0]            _ds, ds;       /// data select
    logic [ASZ-1:0]        ib, ob;        /// IO buffer pointers
    logic                  xds, xib, xob; /// IO latches
    
    task PUSH(input logic [DSZ-1:0] v); ss_if.push(ss_if.s0); _tos = v; xt = 1'b1; endtask;
    task POP; _tos = ss_if.pop(); xt = 1'b1; endtask;
    task ALU(input logic [DSZ-1:0] v); _tos = v; xt = 1'b1; endtask;  
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
        mb_if.get_u8(ip);
        _ip = ip + 1;
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
        _DUP:  PUSH(tos);
        _DROP: POP();
        _OVER: PUSH(ss_if.s0);
        _SWAP: begin end
        _ROT: begin end
        _PICK: begin end
        /// @}
        /// @defgroup ALU ops
        /// @{
        _ADD: ALU(tos + ss_if.pop());
        _SUB: ALU(tos - ss_if.pop());
        _MUL: ALU(tos * ss_if.pop());
        _DIV: ALU(tos / ss_if.pop());
        _MOD: ALU(tos % ss_if.pop());
        _MDIV: begin end
        _SMOD: begin end
        _MSMOD: begin end
        _AND: ALU(tos & ss_if.pop());
        _OR:  ALU(tos | ss_if.pop());
        _XOR: ALU(tos ^ ss_if.pop());
        _ABS: ALU($abs(tos));
        _NEG: ALU(0 - tos);
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
            as  <= _as;
            if (xop) op  <= op1;
            if (xip) ip  <= _ip;
            if (xma) ma  <= _ma;
            if (xt)  tos <= _tos;
            if (xds) ds  <= _ds;
            if (xib) ib  <= ib + 1;
            if (xob) ob  <= ob + 1;
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
