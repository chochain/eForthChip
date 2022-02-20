///
/// ForthSuper common types, and enums
///
package FS1;
typedef enum logic [7:0] {
    ///
    /// @defgroup Execution flow ops
    /// @brief - DO NOT change the sequence here (see forth_opcode enum)
    /// @{
    ///
    _NOP = 0, _DOVAR, _DOLIT,
    _BRAN, _0BRAN, _DONEXT, _DOES,
    _TOR, _RFROM, _RAT,
    /// @}
    /// @defgroup Stack ops
    /// @brief - opcode sequence can be changed below this line
    /// @{
    _DUP, _DROP, _OVER, _SWAP, _ROT, _PICK,
    /// @}
    /// @defgroup ALU ops
    /// @{
    _ADD, _SUB, _MUL, _DIV,
    _MOD, _MDIV, _SMOD, _MSMOD,
    _AND, _OR, _XOR, _ABS, _NEG,
    _MAX, _MIN,
    /// @}
    /// @defgroup Logic ops
    /// @{
    _ZEQ, _ZLT, _ZGT,
    _EQ, _LT, _GT, _NE, _GE, _LE,
    /// @}
    /// @defgroup IO ops
    /// @{
    _BAT, _BSTOR, _HEX, _DEC,
    _CR, _DOT, _DOTR, _UDOTR,
    _KEY, _EMIT, _SPC, _SPCS,
    /// @}
    /// @defgroup Literal ops
    /// @{
    _LBRAC, _RBRAC,
    _BSLSH, _STRQP, _DOTQP, _DOSTR, _DOTSTR,
    /// @}
    /// @defgroup Branching ops
    /// @brief - if...then, if...else...then
    /// @{
    _IF, _ELSE, _THEN,
    /// @}
    /// @defgroup Loops
    /// @brief  - begin...again, begin...f until, begin...f while...repeat
    /// @{
    _BEGIN, _AGAIN, _UNTIL,
    _WHILE, _REPEAT,
    /// @}
    /// @defgrouop For loops
    /// @brief  - for...next, for...aft...then...next
    /// @{
    _FOR, _NEXT, _AFT,
    /// @}
    /// @defgrouop Compiler ops
    /// @{
    _COLON, _SEMIS, _VAR, _CON,
    _EXIT, _EXEC, 
    _CREATE, _TO, _IS, _QTO, 
    _AT, _STOR, _COMMA, _ALLOT, _PSTOR, 
    /// @}
    /// @defgroup Debug ops
    /// @{
    _HERE, _UCASE, _WORDS, _TICK, _SDUMP,
    _SEE, _DUMP, _FORGET,
    /// @}
    /// @defgroup Hardware specific ops
    /// @{
    _PEEK, _POKE,
    _CLOCK, _DELAY,
    _PIN, _IN, _OUT,
    _ADC, _DUTY, _ATTC,
    _SETUP, _TONE,
    _BYE, _BOOT,
    //
    // extra from ceForth
    //
    _UDOT, _QUEST,
    _QRX, _TXSTO,
    _QKEY,
    _WITHIN, _TCHAR,
    _CHARS, _TYPE
} opcode_e;

typedef struct {
    opcode_e   op;
    string     name;
} word_s;
endpackage: FS1
