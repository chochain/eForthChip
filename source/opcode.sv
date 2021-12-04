///
/// ForthSuper Opcodes
///
`ifndef FORTHSUPER_OPCODE
`define FORTHSUPER_OPCODE
typedef enum logic [7:0] {
    NOP, DUP, DROP, OVER, SWAP, ROT,
    PLUS, MINUS, MUL, DIV, MOD,
    AND, OR, XOR, ABS, NEG,
    EQ, LT, GT, NE, GE, LE,
    ZEQ, ZLT, ZGT, 
    MAX, MIN
} opcode;

typedef struct {
    opcode     op;
    string     name;
} word;
`endif // FORTHSUPER_OPCODE
