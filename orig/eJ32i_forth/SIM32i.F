 D0B1 forth_' key  >body forth_@ ramw!
 D1B1 forth_' emit >body forth_@ ramw!

forth_forget h

DECIMAL
$3F CONSTANT LIMIT ( stack depth )
$1FFF CONSTANT RANGE ( program memory size in byte )
VARIABLE CLOCK 
VARIABLE (REGISTER) ( where registers and stacks are )
VARIABLE BREAK
VARIABLE input $1000 input !
VARIABLE output $1400 output !

: REGISTER  PAD ;

: P     REGISTER ;
: RP    REGISTER 8 + ;
: SP    REGISTER 12 + ;
: T     REGISTER 16 + ;
: RSTACK  RP C@ LIMIT AND 4 * REGISTER + $100 + ;
: SSTACK  SP C@ LIMIT AND 4 * REGISTER + $200 + ;
: S	SSTACK ;
: R	RSTACK ;

: RPUSH ( n -- , push n on return stack )
        4 RP +! RSTACK ! ;
: RPOPP ( -- n , pop n from return stack )
        RSTACK @ -4 RP +! ;
: SPUSH ( n -- , push n on data stack )
        T @ 1 SP +! SSTACK ! T ! ;
: SPOPP ( -- n , pop n from data stack )
        T @ SSTACK @ T ! -1 SP +! ;
: CYCLE 1 CLOCK +! ;

: continue 1 P +! ;
: JUMP  2 P +! ;
: bra   P @ 1+ ramw@ 1- P ! ; 
: bz    SPOPP IF JUMP ELSE bra THEN ;
: call  P @ 3 + RPUSH bra ;
: return R @ 1- P ! -4 RP +!  ;
: ret   R P @ 1+ ramc@ CELLS - @ 1- P ! ;

: get   KEY DUP $1B = ABORT" done"
        SPUSH ;
: put   SPOPP $7F AND EMIT ;

DECIMAL

: execute ( code -- )
 DUP 00 = ( 0x00 nop ) IF DROP EXIT THEN 
 DUP 01 = ( 0x01 aconst_null ) IF DROP 0 SPUSH EXIT THEN
 DUP 02 = ( 0x02 iconst_m1 ) IF DROP -1 SPUSH EXIT THEN
 DUP 03 = ( 0x03 iconst_0 ) IF DROP 0 SPUSH EXIT THEN
 DUP 04 = ( 0x04 iconst_1 ) IF DROP 1 SPUSH EXIT THEN
 DUP 05 = ( 0x05 iconst_2 ) IF DROP 2 SPUSH EXIT THEN
 DUP 06 = ( 0x06 iconst_3 ) IF DROP 3 SPUSH EXIT THEN
 DUP 07 = ( 0x07 iconst_4 ) IF DROP 4 SPUSH EXIT THEN
 DUP 08 = ( 0x08 iconst_5 ) IF DROP 5 SPUSH EXIT THEN
 DUP 09 = ( 0x09 lconst_0 ) IF DROP EXIT THEN
 DUP 10 = ( 0x0a lconst_1 ) IF DROP EXIT THEN
 DUP 11 = ( 0x0b fconst_0 ) IF DROP EXIT THEN
 DUP 12 = ( 0x0c fconst_1 ) IF DROP EXIT THEN
 DUP 13 = ( 0x0d fconst_2 ) IF DROP EXIT THEN
 DUP 14 = ( 0x0e dconst_0 ) IF DROP EXIT THEN
 DUP 15 = ( 0x0f dconst_1 ) IF DROP EXIT THEN
 DUP 16 = ( 0x10 bipush ) IF DROP P @ 1+ RAMC@ DUP $80 AND IF $FFFFFF00 + THEN
     SPUSH 1 P +! EXIT THEN
 DUP 17 = ( 0x11 sipush ) IF DROP p @ 1+ RAMW@ DUP $8000 AND IF $FFFF0000 + THEN 
     SPUSH 2 P +! EXIT THEN
 DUP 18 = ( 0x12 ldc ) IF DROP EXIT THEN
 DUP 19 = ( 0x13 ldc_w ) IF DROP EXIT THEN
 DUP 20 = ( 0x14 ldc2_w ) IF DROP EXIT THEN
 DUP 21 = ( 0x15 iload ) IF DROP R P @ 1+ ramc@ 4 * 
     - @ SPUSH 1 P +! EXIT THEN
 DUP 22 = ( 0x16 lload ) IF DROP EXIT THEN
 DUP 23 = ( 0x17 fload ) IF DROP EXIT THEN
 DUP 24 = ( 0x18 dload ) IF DROP EXIT THEN
 DUP 25 = ( 0x19 aload ) IF DROP EXIT THEN
 DUP 26 = ( 0x1a iload_0 ) IF DROP R @ SPUSH EXIT THEN
 DUP 27 = ( 0x1b iload_1 ) IF DROP R 4 - @ SPUSH EXIT THEN
 DUP 28 = ( 0x1c iload_2 ) IF DROP R 8 - @ SPUSH EXIT THEN
 DUP 29 = ( 0x1d iload_3 ) IF DROP R 12 - @ SPUSH EXIT THEN
 DUP 30 = ( 0x1e lload_0 ) IF DROP EXIT THEN
 DUP 31 = ( 0x1f lload_1 ) IF DROP EXIT THEN
 DUP 32 = ( 0x20 lload_2 ) IF DROP EXIT THEN
 DUP 33 = ( 0x21 lload_3 ) IF DROP EXIT THEN
 DUP 34 = ( 0x22 fload_0 ) IF DROP EXIT THEN
 DUP 35 = ( 0x23 fload_1 ) IF DROP EXIT THEN
 DUP 36 = ( 0x24 fload_2 ) IF DROP EXIT THEN
 DUP 37 = ( 0x25 fload_3 ) IF DROP EXIT THEN
 DUP 38 = ( 0x26 dload_0 ) IF DROP EXIT THEN
 DUP 39 = ( 0x27 dload_1 ) IF DROP EXIT THEN
 DUP 40 = ( 0x28 dload_2 ) IF DROP EXIT THEN
 DUP 41 = ( 0x29 dload_3 ) IF DROP EXIT THEN
 DUP 42 = ( 0x2a aload_0 ) IF DROP EXIT THEN
 DUP 43 = ( 0x2b aload_1 ) IF DROP EXIT THEN
 DUP 44 = ( 0x2c aload_2 ) IF DROP EXIT THEN
 DUP 45 = ( 0x2d aload_3 ) IF DROP EXIT THEN
 DUP 46 = ( 0x2e iaload ) IF DROP SPOPP ram@ SPUSH EXIT THEN
 DUP 47 = ( 0x2f laload ) IF DROP EXIT THEN
 DUP 48 = ( 0x30 faload ) IF DROP EXIT THEN
 DUP 49 = ( 0x31 daload ) IF DROP EXIT THEN
 DUP 50 = ( 0x32 aaload ) IF DROP EXIT THEN
 DUP 51 = ( 0x33 baload ) IF DROP SPOPP ramc@ SPUSH EXIT THEN
 DUP 52 = ( 0x34 caload ) IF DROP EXIT THEN
 DUP 53 = ( 0x35 saload ) IF DROP SPOPP ramw@ SPUSH EXIT THEN
 DUP 54 = ( 0x36 istore ) IF DROP SPOPP R P @ 1+ ramc@ 4 * 
     - ! 1 P +! EXIT THEN
 DUP 55 = ( 0x37 lstore ) IF DROP EXIT THEN
 DUP 56 = ( 0x38 fstore ) IF DROP EXIT THEN
 DUP 57 = ( 0x39 dstore ) IF DROP EXIT THEN
 DUP 58 = ( 0x3a astore ) IF DROP EXIT THEN
 DUP 59 = ( 0x3b istore_0 ) IF DROP SPOPP R ! EXIT THEN
 DUP 60 = ( 0x3c istore_1 ) IF DROP SPOPP R 4 - ! EXIT THEN
 DUP 61 = ( 0x3d istore_2 ) IF DROP SPOPP R 8 - ! EXIT THEN
 DUP 62 = ( 0x3e istore_3 ) IF DROP SPOPP R 12 - ! EXIT THEN
 DUP 63 = ( 0x3f lstore_0 ) IF DROP EXIT THEN
 DUP 64 = ( 0x40 lstore_1 ) IF DROP EXIT THEN
 DUP 65 = ( 0x41 lstore_2 ) IF DROP EXIT THEN
 DUP 66 = ( 0x42 lstore_3 ) IF DROP EXIT THEN
 DUP 67 = ( 0x43 fstore_0 ) IF DROP EXIT THEN
 DUP 68 = ( 0x44 fstore_1 ) IF DROP EXIT THEN
 DUP 69 = ( 0x45 fstore_2 ) IF DROP EXIT THEN
 DUP 70 = ( 0x46 fstore_3 ) IF DROP EXIT THEN
 DUP 71 = ( 0x47 dstore_0 ) IF DROP EXIT THEN
 DUP 72 = ( 0x48 dstore_1 ) IF DROP EXIT THEN
 DUP 73 = ( 0x49 dstore_2 ) IF DROP EXIT THEN
 DUP 74 = ( 0x4a dstore_3 ) IF DROP EXIT THEN
 DUP 75 = ( 0x4b astore_0 ) IF DROP EXIT THEN
 DUP 76 = ( 0x4c astore_1 ) IF DROP EXIT THEN
 DUP 77 = ( 0x4d astore_2 ) IF DROP EXIT THEN
 DUP 78 = ( 0x4e astore_3 ) IF DROP EXIT THEN
 DUP 79 = ( 0x4f iastore ) IF DROP SPOPP SPOPP ram! EXIT THEN
 DUP 80 = ( 0x50 lastore ) IF DROP EXIT THEN
 DUP 81 = ( 0x51 fastore ) IF DROP EXIT THEN
 DUP 82 = ( 0x52 dastore ) IF DROP EXIT THEN
 DUP 83 = ( 0x53 aastore ) IF DROP EXIT THEN
 DUP 84 = ( 0x54 bastore ) IF DROP SPOPP SPOPP RAMC! EXIT THEN
 DUP 85 = ( 0x55 castore ) IF DROP EXIT THEN
 DUP 86 = ( 0x56 sastore ) IF DROP SPOPP SPOPP RAMW! EXIT THEN
 DUP 87 = ( 0x57 pop ) IF DROP SPOPP DROP EXIT THEN
 DUP 88 = ( 0x58 pop2 ) IF DROP SPOPP DROP SPOPP DROP EXIT THEN
 DUP 89 = ( 0x59 dup ) IF DROP T @ SPUSH EXIT THEN
 DUP 90 = ( 0x5a dup_x1 ) IF DROP SPOPP SPOPP OVER SPUSH SPUSH SPUSH EXIT THEN
 DUP 91 = ( 0x5b dup_x2 ) IF DROP SPOPP SPOPP OVER SPOPP SWAP 
     SPUSH SPUSH SPUSH SPUSH EXIT THEN
 DUP 92 = ( 0x5c dup2 ) IF DROP SPOPP SPOPP OVER OVER SPUSH SPUSH SPUSH SPUSH EXIT THEN
 DUP 93 = ( 0x5d dup2_x1 ) IF DROP EXIT THEN
 DUP 94 = ( 0x5e dup2_x2 ) IF DROP EXIT THEN
 DUP 95 = ( 0x5f swap ) IF DROP SPOPP SPOPP SWAP SPUSH SPUSH EXIT THEN
 DUP 96 = ( 0x60 iadd ) IF DROP SPOPP SPOPP + SPUSH EXIT THEN
 DUP 97 = ( 0x61 ladd ) IF DROP EXIT THEN
 DUP 98 = ( 0x62 fadd ) IF DROP EXIT THEN
 DUP 99 = ( 0x63 dadd ) IF DROP EXIT THEN
 DUP 100 = ( 0x64 isub ) IF DROP SPOPP SPOPP SWAP - SPUSH EXIT THEN
 DUP 101 = ( 0x65 lsub ) IF DROP EXIT THEN
 DUP 102 = ( 0x66 fsub ) IF DROP EXIT THEN
 DUP 103 = ( 0x67 dsub ) IF DROP EXIT THEN
 DUP 104 = ( 0x68 imul ) IF DROP SPOPP SPOPP * SPUSH EXIT THEN
 DUP 105 = ( 0x69 lmul ) IF DROP EXIT THEN
 DUP 106 = ( 0x6a fmul ) IF DROP EXIT THEN
 DUP 107 = ( 0x6b dmul ) IF DROP EXIT THEN
 DUP 108 = ( 0x6c idiv ) IF DROP SPOPP SPOPP SWAP / SPUSH EXIT THEN
 DUP 109 = ( 0x6d ldiv ) IF DROP EXIT THEN
 DUP 110 = ( 0x6e fdiv ) IF DROP EXIT THEN
 DUP 111 = ( 0x6f ddiv ) IF DROP EXIT THEN
 DUP 112 = ( 0x70 irem ) IF DROP SPOPP SPOPP SWAP MOD SPUSH EXIT THEN
 DUP 113 = ( 0x71 lrem ) IF DROP EXIT THEN
 DUP 114 = ( 0x72 frem ) IF DROP EXIT THEN
 DUP 115 = ( 0x73 drem ) IF DROP EXIT THEN
 DUP 116 = ( 0x74 ineg ) IF DROP SPOPP NEGATE SPUSH EXIT THEN
 DUP 117 = ( 0x75 lneg ) IF DROP EXIT THEN
 DUP 118 = ( 0x76 fneg ) IF DROP EXIT THEN
 DUP 119 = ( 0x77 dneg ) IF DROP EXIT THEN
 DUP 120 = ( 0x78 ishl ) IF DROP SPOPP SPOPP SWAP LSHIFT SPUSH EXIT THEN
 DUP 121 = ( 0x79 lshl ) IF DROP EXIT THEN
 DUP 122 = ( 0x7a ishr ) IF DROP SPOPP SPOPP SWAP RSHIFT SPUSH EXIT THEN
 DUP 123 = ( 0x7b lshr ) IF DROP EXIT THEN
 DUP 124 = ( 0x7c iushr ) IF DROP EXIT THEN
 DUP 125 = ( 0x7d lushr ) IF DROP EXIT THEN
 DUP 126 = ( 0x7e iand ) IF DROP SPOPP SPOPP AND SPUSH EXIT THEN
 DUP 127 = ( 0x7f land ) IF DROP EXIT THEN
 DUP 128 = ( 0x80 ior ) IF DROP SPOPP SPOPP OR SPUSH EXIT THEN
 DUP 129 = ( 0x81 lor ) IF DROP EXIT THEN
 DUP 130 = ( 0x82 ixor ) IF DROP SPOPP SPOPP XOR SPUSH EXIT THEN
 DUP 131 = ( 0x83 lxor ) IF DROP EXIT THEN
 DUP 132 = ( 0x84 iinc ) IF DROP SPOPP SPOPP DUP ram@ ROT + SWAP ram! EXIT THEN
 DUP 133 = ( 0x85 i2l ) IF DROP EXIT THEN
 DUP 134 = ( 0x86 i2f ) IF DROP EXIT THEN
 DUP 135 = ( 0x87 i2d ) IF DROP EXIT THEN
 DUP 136 = ( 0x88 l2i ) IF DROP EXIT THEN
 DUP 137 = ( 0x89 l2f ) IF DROP EXIT THEN
 DUP 138 = ( 0x8a l2d ) IF DROP EXIT THEN
 DUP 139 = ( 0x8b f2i ) IF DROP EXIT THEN
 DUP 140 = ( 0x8c f2l ) IF DROP EXIT THEN
 DUP 141 = ( 0x8d f2d ) IF DROP EXIT THEN
 DUP 142 = ( 0x8e d2i ) IF DROP EXIT THEN
 DUP 143 = ( 0x8f d2l ) IF DROP EXIT THEN
 DUP 144 = ( 0x90 d2f ) IF DROP EXIT THEN
 DUP 145 = ( 0x91 i2b ) IF DROP EXIT THEN
 DUP 146 = ( 0x92 i2c ) IF DROP EXIT THEN
 DUP 147 = ( 0x93 i2s ) IF DROP EXIT THEN
 DUP 148 = ( 0x94 lcmp ) IF DROP EXIT THEN
 DUP 149 = ( 0x95 fcmpl ) IF DROP EXIT THEN
 DUP 150 = ( 0x96 fcmpg ) IF DROP EXIT THEN
 DUP 151 = ( 0x97 dcmpl ) IF DROP EXIT THEN
 DUP 152 = ( 0x98 dcmpg ) IF DROP EXIT THEN
 DUP 153 = ( 0x99 ifeq ) IF DROP SPOPP IF JUMP ELSE bra THEN EXIT THEN
 DUP 154 = ( 0x9a ifne ) IF DROP SPOPP IF bra ELSE JUMP THEN EXIT THEN
 DUP 155 = ( 0x9b iflt ) IF DROP SPOPP 0< IF bra ELSE JUMP THEN EXIT THEN
 DUP 156 = ( 0x9c ifge ) IF DROP SPOPP 0< IF JUMP ELSE bra THEN EXIT THEN
 DUP 157 = ( 0x9d ifgt ) IF DROP SPOPP 0 > IF bra ELSE JUMP THEN EXIT THEN
 DUP 158 = ( 0x9e ifle ) IF DROP SPOPP 0 > IF JUMP ELSE bra THEN EXIT THEN
 DUP 159 = ( 0x9f if_icmpeq ) IF DROP SPOPP SPOPP = IF bra ELSE JUMP THEN EXIT THEN
 DUP 160 = ( 0xa0 if_icmpne ) IF DROP EXIT THEN
 DUP 161 = ( 0xa1 if_icmplt ) IF DROP SPOPP SPOPP SWAP < IF bra ELSE JUMP THEN EXIT THEN
 DUP 162 = ( 0xa2 if_icmpge ) IF DROP EXIT THEN
 DUP 163 = ( 0xa3 if_icmpgt ) IF DROP SPOPP SPOPP SWAP > IF bra ELSE JUMP THEN EXIT THEN
 DUP 164 = ( 0xa4 if_icmple ) IF DROP EXIT THEN
 DUP 165 = ( 0xa5 if_acmpeq ) IF DROP EXIT THEN
 DUP 166 = ( 0xa6 if_acmpne ) IF DROP EXIT THEN
 DUP 167 = ( 0xa7 goto ) IF DROP P @ 1+ RAMW@ 1- P ! EXIT THEN
 DUP 168 = ( 0xa8 jsr ) IF DROP bra P @ 2+ SPUSH EXIT THEN
 DUP 169 = ( 0xa9 ret ) IF DROP ret EXIT THEN
 DUP 170 = ( 0xaa tableswitch ) IF DROP EXIT THEN
 DUP 171 = ( 0xab lookupswitch ) IF DROP EXIT THEN
 DUP 172 = ( 0xac ireturn ) IF DROP EXIT THEN
 DUP 173 = ( 0xad lreturn ) IF DROP EXIT THEN
 DUP 174 = ( 0xae freturn ) IF DROP EXIT THEN
 DUP 175 = ( 0xaf dreturn ) IF DROP EXIT THEN
 DUP 176 = ( 0xb0 areturn ) IF DROP EXIT THEN
 DUP 177 = ( 0xb1 return ) IF DROP return EXIT THEN
 DUP 178 = ( 0xb2 getstatic ) IF DROP EXIT THEN
 DUP 179 = ( 0xb3 putstatic ) IF DROP EXIT THEN
 DUP 180 = ( 0xb4 getfield ) IF DROP EXIT THEN
 DUP 181 = ( 0xb5 putfield ) IF DROP EXIT THEN
 DUP 182 = ( 0xb6 invokevirtual ) IF DROP call EXIT THEN
 DUP 183 = ( 0xb7 invokespecial ) IF DROP EXIT THEN
 DUP 184 = ( 0xb8 invokestatic ) IF DROP EXIT THEN
 DUP 185 = ( 0xb9 invokeinterface ) IF DROP EXIT THEN
 DUP 186 = ( 0xba invokedynamic ) IF DROP EXIT THEN
 DUP 187 = ( 0xbb new ) IF DROP EXIT THEN
 DUP 188 = ( 0xbc newarray ) IF DROP EXIT THEN
 DUP 189 = ( 0xbd anewarray ) IF DROP EXIT THEN
 DUP 190 = ( 0xbe arraylength ) IF DROP EXIT THEN
 DUP 191 = ( 0xbf athrow ) IF DROP EXIT THEN
 DUP 192 = ( 0xc0 checkcast ) IF DROP EXIT THEN
 DUP 193 = ( 0xc1 instanceof ) IF DROP EXIT THEN
 DUP 194 = ( 0xc2 monitorenter ) IF DROP EXIT THEN
 DUP 195 = ( 0xc3 monitorexit ) IF DROP EXIT THEN
 DUP 196 = ( 0xc4 wide ) IF DROP EXIT THEN
 DUP 197 = ( 0xc5 multianewarray ) IF DROP EXIT THEN
 DUP 198 = ( 0xc6 ifnull ) IF DROP EXIT THEN
 DUP 199 = ( 0xc7 ifnonnull ) IF DROP EXIT THEN
 DUP 200 = ( 0xc8 goto_w ) IF DROP EXIT THEN
 DUP 201 = ( 0xc9 jsr_w ) IF DROP EXIT THEN
 DUP 202 = ( 0xca donext ) IF DROP 
     R -1 OVER +! @ 0< IF -4 RP +! JUMP ELSE bra THEN EXIT THEN
 DUP 203 = ( 0xcb ldi ) IF DROP P @ 1+ RAM@ SPUSH 4 P +! EXIT THEN
 DUP 204 = ( 0xcc popr ) IF DROP RPOPP SPUSH EXIT THEN
 DUP 205 = ( 0xcd pushr ) IF DROP SPOPP RPUSH EXIT THEN
 DUP 206 = ( 0xce dupr ) IF DROP R @ SPUSH EXIT THEN
\ DUP 207 = ( 0xcf ext ) IF DROP EXIT THEN
\ DUP 208 = ( 0xd0 get ) IF DROP KEY SPUSH EXIT THEN
\ DUP 209 = ( 0xd1 put ) IF DROP SPOPP EMIT EXIT THEN
 DUP 208 = ( 0xd0 get ) IF DROP  input @ ramc@ SPUSH 1  input +! EXIT THEN
 DUP 209 = ( 0xd1 put ) IF DROP SPOPP output @ ramc! 1 output +! EXIT THEN
 . -1 ABORT" : Illegel instruction" ;
HEX
: .stack ( add # ) FOR AFT DUP @ U. 4 - THEN NEXT DROP CR ;
: .sstack ." S:" T ? SSTACK SP C@ .stack ;
: .rstack ." R:" RSTACK RP C@ .stack ;
: .registers ."  P=" P @ DUP . ."  code=" ram@ . CR ;
: S  CR ." CLOCK=" CLOCK @ . .registers .sstack .rstack ;
: exec  P @ ramc@ execute 1 P +! ;
: C     exec CYCLE S .S ;
: reset P $300 0 FILL 0 CLOCK ! ;
reset

: G     ( addr -- )
        CR ." Press any key to stop." CR
        BREAK !
        BEGIN exec P @ BREAK @ =
              IF CYCLE C EXIT
              ELSE CYCLE
              THEN 
              ?KEY
        UNTIL ;

: D     P @ 1- FOUR ;
: M     show ;
: RUN   CR ." Press ESC to stop." CR
        BEGIN C KEY 1B = UNTIL ;
\ : P     DUP RANGE AND P ! RANGE AND P ! ;

: HELP  CR ." eP32 Simulator, copyright eForth Group, 2000"
        CR ." C: execute next cycle"
        CR ." S: show all registers"
        CR ." D: display next 8 words"
        CR ." addr M: display 128 words from addr"
        CR ." addr P: start execution at addr"
        CR ." addr G: run and stop at addr"
        CR ." RUN: execute, one key per cycle"
        CR ;
HELP
 -1 G

