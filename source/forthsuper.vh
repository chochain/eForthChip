///
/// ForthSuper common types, and enums
///
package FS1;
typedef enum logic [7:0] {
    //
    // flow ops
    //
    _NOP = 0, _DOVAR, _DOCON, _DOLIT,
    _DOLIST, _EXIT, _EXEC,
    _BRAN, _0BRAN, _DONEXT, _DOES,
    //
    // load/store op
    //
    _STOR, _AT, _CSTOR, _CAT,
    _TOR, _RFROM, _RAT,
    //
    // stack ops
    //
    _DUP, _DROP, _OVER, _SWAP, _ROT, _PICK,
    //
    // alu ops
    //
    _ADD, _SUB, _MUL, _DIV,
    _MOD, _MDIV, _SMOD, _MSMOD,
    _AND, _OR, _XOR, _ABS, _NEG,
    _MAX, _MIN,
    //
    // logic ops
    //
    _ZEQ, _ZLT, _ZGT, 
    _EQ, _LT, _GT, _NE, _GE, _LE,
    //
    // io ops
    //
    _QRX, _TXSTO,
    _QKEY, _KEY, _EMIT, 
    _WITHIN, _TCHAR, 
    _CHARS, _TYPE, _SPC, _SPCS,
    _HEX, _DEC,
    _CR, _DOT, _DOTR, _UDOTR, _UDOT, _QUEST,
    //
    // literal ops
    //
    _DOTSTR, _STRQP, _DOTQP, _BSLSH, _DOSTR,         
    //
    // branching ops
    //
    _IF, _ELSE, _THEN,
    _BEGIN, _AGAIN, _UNTIL,
    _WHILE, _REPEAT, _FOR, _NEXT, _AFT,
    //
    // meta ops
    //
    _LBRAC, _RBRAC,
    _COLON, _SEMIS, _VAR, _CON,
    _CREATE, _TO, _IS,
    _COMMA, _ALLOT, _PSTOR, 
    //
    // debug ops
    //
    _HERE, _UCASE, _WORDS, _TICK, _SDUMP,
    _SEE, _DUMP, _FORGET,
    _PEEK, _POKE,
    //
    // pin & system ops
    //
    _PIN, _IN, _OUT,
    _ADC, _DUTY, _ATTC,
    _SETUP, _TONE,
    _CLOCK, _DELAY,
    _BYE, _BOOT
} opcode_e;

typedef struct {
    opcode_e   op;
    string     name;
} word_s;
endpackage: FS1

