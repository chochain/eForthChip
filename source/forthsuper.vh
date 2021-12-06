///
/// ForthSuper common types, and enums
///
package FS1;
typedef enum logic [7:0] {
    NOP = 0, DUP, DROP, OVER, SWAP, ROT,
    PLUS, MINUS, MUL, DIV, MOD,
    AND, OR, XOR, ABS, NEG,
    EQ, LT, GT, NE, GE, LE,
    ZEQ, ZLT, ZGT, 
    MAX, MIN
} opcode_e;

typedef struct {
    opcode_e   op;
    string     name;
} word_s;
endpackage: FS1

