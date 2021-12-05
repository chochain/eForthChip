///
/// ForthSuper types
///
///
package FS1;
typedef enum logic [7:0] {
    NOP = 0, DUP, DROP, OVER, SWAP, ROT,
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
///
/// forced one-hot encoding => 316 LUTs (7 lines into 5 MUXs)
///
//typedef enum logic [2:0] { R1, W1, FIND } pool_ops;
//typedef enum logic [6:0] { MEM, LF0, LF1, LEN, NFA, TIB, CMP } pool_sts;
///
/// automatic one-hot encoding => 261 LUTs (4 lines into 6 MUXs)
///
typedef enum logic [1:0] { R1, W1, FIND } pool_ops;
typedef enum logic [2:0] { MEM, LF0, LF1, LEN, NFA, TIB, CMP } pool_sts;
endpackage : FS1
