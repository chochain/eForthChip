///
/// @file
/// @brief eForth1 common types, and enums
///
`ifndef EFORTH1_EF1
`define EFORTH1_EF1
package EF1;
typedef enum logic [5:0] {
    ///
    /// @defgroup Execution flow ops
    /// @brief - DO NOT change the sequence here (see forth_opcode enum)
    /// @{
    _NOP = 0, _BYE, _QRX, _TXSTO,
    _DOLIT, _DOVAR,
    /// @}
    /// @defgroup Branching ops
    /// @{
    _EXECU, _ENTER, _EXIT, _DONEXT, _0BRAN, _BRAN,
    /// @}
    /// @defgroup memory access
    /// @{
    _STORE, _PSTOR, _AT, _CSTOR, _CAT,
    _RFROM, _RAT, _TOR,
    /// @}
    /// @defgroup Stack ops
    /// @brief - opcode sequence can be changed below this line
    /// @{
    _DROP, _DUP, _SWAP, _OVER, _ROT, _PICK,
    /// @}
    /// @defgroup ALU ops
    /// @{
    _AND, _OR, _XOR, _INV, _LSH, _RSH,
    _ADD, _SUB, _MUL, _DIV, _MOD, _NEG,
    /// @}
    /// @defgroup Logic ops
    /// @{
    _GT, _EQ, _LT, _ZGT, _ZEQ, _ZLT,
    /// @}
    /// @defgroup Misc ops
    /// @{
    _ONEP, _ONEM, _QDUP, _DEPTH, _RP, _ULESS,
    /// @}
    /// @defgroup Double
    /// @{
    _UMMOD, _UMSTAR, _MSTAR, _UMPLUS,
    _DNEG, _DADD, _DSUB
    /// @}
} opcode_e;

typedef struct {
    opcode_e   op;
    string     name;
} word_s;
endpackage: EF1

import EF1::*;
`endif  // EFORTH1_EF1
