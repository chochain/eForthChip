\ asm32s.f 24jun21cht, bytecode, subroutine threading

HEX
VARIABLE h
VARIABLE lastH 0 lastH !   \ init linkfield address lfa

: nameR! ( d -- )
   h @ ramw!               \ store short to dictionar
   2 h +!                  \ bump h
   ;

: compile-only 40 lastH @ RAMC@ XOR lastH @ RAMC! ;
: IMMEDIATE    80 lastH @ RAMC@ XOR lastH @ RAMC! ;

: ORG   DUP . CR h ! ;
: #,   ( d ) H @ RAM!   4 h +! ;
: w,   ( d ) H @ RAMW!  2 h +! ;
: I,   ( d ) H @ RAMC!  1 h +! ;

: INST CONSTANT DOES> R> @ I, ;
: INSB CONSTANT DOES> R> @ I, I, ;
: INSW CONSTANT DOES> R> @ I, w, ;
: INSL CONSTANT DOES> R> @ I, #, ;

DECIMAL
00 ( 0x00  ) INST nop	
01 ( 0x01  ) INST aconst_null	
02 ( 0x02  ) INST iconst_m1	
03 ( 0x03  ) INST iconst_0	
04 ( 0x04  ) INST iconst_1	
05 ( 0x05  ) INST iconst_2	
06 ( 0x06  ) INST iconst_3	
07 ( 0x07  ) INST iconst_4	
08 ( 0x08  ) INST iconst_5	
09 ( 0x09  ) INST lconst_0	
10 ( 0x0a  ) INST lconst_1	
11 ( 0x0b  ) INST fconst_0	
12 ( 0x0c  ) INST fconst_1	
13 ( 0x0d  ) INST fconst_2	
14 ( 0x0e  ) INST dconst_0	
15 ( 0x0f  ) INST dconst_1	
16 ( 0x10  ) INSB bipush	
17 ( 0x11  ) INSW sipush	
18 ( 0x12  ) INSB ldc	
19 ( 0x13  ) INSW ldc_w	
20 ( 0x14  ) INSW ldc2_w	
21 ( 0x15  ) INSB iload	
22 ( 0x16  ) INSB lload	
23 ( 0x17  ) INSB fload	
24 ( 0x18  ) INSB dload	
25 ( 0x19  ) INSB aload	
26 ( 0x1a  ) INST iload_0	
27 ( 0x1b  ) INST iload_1	
28 ( 0x1c  ) INST iload_2	
29 ( 0x1d  ) INST iload_3	
30 ( 0x1e  ) INST lload_0	
31 ( 0x1f  ) INST lload_1	
32 ( 0x20  ) INST lload_2	
33 ( 0x21  ) INST lload_3	
34 ( 0x22  ) INST fload_0	
35 ( 0x23  ) INST fload_1	
36 ( 0x24  ) INST fload_2	
37 ( 0x25  ) INST fload_3	
38 ( 0x26  ) INST dload_0	
39 ( 0x27  ) INST dload_1	
40 ( 0x28  ) INST dload_2	
41 ( 0x29  ) INST dload_3	
42 ( 0x2a  ) INST aload_0	
43 ( 0x2b  ) INST aload_1	
44 ( 0x2c  ) INST aload_2	
45 ( 0x2d  ) INST aload_3	
46 ( 0x2e  ) INST iaload	
47 ( 0x2f  ) INST laload	
48 ( 0x30  ) INST faload	
49 ( 0x31  ) INST daload	
50 ( 0x32  ) INST aaload	
51 ( 0x33  ) INST baload	
52 ( 0x34  ) INST caload	
53 ( 0x35  ) INST saload	
54 ( 0x36  ) INSB istore	
55 ( 0x37  ) INSB lstore	
56 ( 0x38  ) INSB fstore	
57 ( 0x39  ) INSB dstore	
58 ( 0x3a  ) INSB astore	
59 ( 0x3b  ) INST istore_0	
60 ( 0x3c  ) INST istore_1	
61 ( 0x3d  ) INST istore_2	
62 ( 0x3e  ) INST istore_3	
63 ( 0x3f  ) INST lstore_0	
64 ( 0x40  ) INST lstore_1	
65 ( 0x41  ) INST lstore_2	
66 ( 0x42  ) INST lstore_3	
67 ( 0x43  ) INST fstore_0	
68 ( 0x44  ) INST fstore_1	
69 ( 0x45  ) INST fstore_2	
70 ( 0x46  ) INST fstore_3	
71 ( 0x47  ) INST dstore_0	
72 ( 0x48  ) INST dstore_1	
73 ( 0x49  ) INST dstore_2	
74 ( 0x4a  ) INST dstore_3	
75 ( 0x4b  ) INST astore_0	
76 ( 0x4c  ) INST astore_1	
77 ( 0x4d  ) INST astore_2	
78 ( 0x4e  ) INST astore_3	
79 ( 0x4f  ) INST iastore	
80 ( 0x50  ) INST lastore	
81 ( 0x51  ) INST fastore	
82 ( 0x52  ) INST dastore	
83 ( 0x53  ) INST aastore	
84 ( 0x54  ) INST bastore	
85 ( 0x55  ) INST castore	
86 ( 0x56  ) INST sastore	
87 ( 0x57  ) INST pop	
88 ( 0x58  ) INST pop2	
89 ( 0x59  ) INST dup	
90 ( 0x5a  ) INST dup_x1	
91 ( 0x5b  ) INST dup_x2	
92 ( 0x5c  ) INST dup2	
93 ( 0x5d  ) INST dup2_x1	
94 ( 0x5e  ) INST dup2_x2	
95 ( 0x5f  ) INST swap	
96 ( 0x60  ) INST iadd	
97 ( 0x61  ) INST ladd	
98 ( 0x62  ) INST fadd	
99 ( 0x63  ) INST dadd	
100 ( 0x64  ) INST isub	
101 ( 0x65  ) INST lsub	
102 ( 0x66  ) INST fsub	
103 ( 0x67  ) INST dsub	
104 ( 0x68  ) INST imul	
105 ( 0x69  ) INST lmul	
106 ( 0x6a  ) INST fmul	
107 ( 0x6b  ) INST dmul	
108 ( 0x6c  ) INST idiv	
109 ( 0x6d  ) INST ldiv	
110 ( 0x6e  ) INST fdiv	
111 ( 0x6f  ) INST ddiv	
112 ( 0x70  ) INST irem	
113 ( 0x71  ) INST lrem	
114 ( 0x72  ) INST frem	
115 ( 0x73  ) INST drem	
116 ( 0x74  ) INST ineg	
117 ( 0x75  ) INST lneg	
118 ( 0x76  ) INST fneg	
119 ( 0x77  ) INST dneg	
120 ( 0x78  ) INST ishl	
121 ( 0x79  ) INST lshl	
122 ( 0x7a  ) INST ishr	
123 ( 0x7b  ) INST lshr	
124 ( 0x7c  ) INST iushr	
125 ( 0x7d  ) INST lushr	
126 ( 0x7e  ) INST iand	
127 ( 0x7f  ) INST land	
128 ( 0x80  ) INST ior	
129 ( 0x81  ) INST lor	
130 ( 0x82  ) INST ixor	
131 ( 0x83  ) INST lxor	
132 ( 0x84  ) INSW iinc	
133 ( 0x85  ) INST i2l	
134 ( 0x86  ) INST i2f	
135 ( 0x87  ) INST i2d	
136 ( 0x88  ) INST l2i	
137 ( 0x89  ) INST l2f	
138 ( 0x8a  ) INST l2d	
139 ( 0x8b  ) INST f2i	
140 ( 0x8c  ) INST f2l	
141 ( 0x8d  ) INST f2d	
142 ( 0x8e  ) INST d2i	
143 ( 0x8f  ) INST d2l	
144 ( 0x90  ) INST d2f	
145 ( 0x91  ) INST i2b	
146 ( 0x92  ) INST i2c	
147 ( 0x93  ) INST i2s	
148 ( 0x94  ) INST lcmp	
149 ( 0x95  ) INST fcmpl	
150 ( 0x96  ) INST fcmpg	
151 ( 0x97  ) INST dcmpl	
152 ( 0x98  ) INST dcmpg	
153 ( 0x99  ) INSW ifeq	
154 ( 0x9a  ) INSW ifne	
155 ( 0x9b  ) INSW iflt	
156 ( 0x9c  ) INSW ifge	
157 ( 0x9d  ) INSW ifgt	
158 ( 0x9e  ) INSW ifle	
159 ( 0x9f  ) INSW if_icmpeq	
160 ( 0xa0  ) INSW if_icmpne	
161 ( 0xa1  ) INSW if_icmplt	
162 ( 0xa2  ) INSW if_icmpge	
163 ( 0xa3  ) INSW if_icmpgt	
164 ( 0xa4  ) INSW if_icmple	
165 ( 0xa5  ) INSW if_acmpeq	
166 ( 0xa6  ) INSW if_acmpne	
167 ( 0xa7  ) INSW goto	
168 ( 0xa8  ) INSW jsr	
169 ( 0xa9  ) INSB ret	
170 ( 0xaa  ) INST tableswitch	
171 ( 0xab  ) INST lookupswitch	
172 ( 0xac  ) INST ireturn	
173 ( 0xad  ) INST lreturn	
174 ( 0xae  ) INST freturn	
175 ( 0xaf  ) INST dreturn	
176 ( 0xb0  ) INST areturn	
177 ( 0xb1  ) INST return	
178 ( 0xb2  ) INSW getstatic	
179 ( 0xb3  ) INSW putstatic	
180 ( 0xb4  ) INSW getfield	
181 ( 0xb5  ) INSW putfield	
182 ( 0xb6  ) INSW invokevirtual	
183 ( 0xb7  ) INSW invokespecial	
184 ( 0xb8  ) INSW invokestatic	
185 ( 0xb9  ) INSL invokeinterface	
186 ( 0xba  ) INSL invokedynamic	
187 ( 0xbb  ) INSW new	
188 ( 0xbc  ) INSB newarray	
189 ( 0xbd  ) INSW anewarray	
190 ( 0xbe  ) INST arraylength	
191 ( 0xbf  ) INST athrow	
192 ( 0xc0  ) INSW checkcast	
193 ( 0xc1  ) INSW instanceof	
194 ( 0xc2  ) INST monitorenter	
195 ( 0xc3  ) INST monitorexit	
196 ( 0xc4  ) INSL wide	
197 ( 0xc5  ) INSL multianewarray	
198 ( 0xc6  ) INSW ifnull	
199 ( 0xc7  ) INSW ifnonnull	
200 ( 0xc8  ) INSL goto_w	
201 ( 0xc9  ) INSL jsr_w	
202 ( 0xca  ) INSW donext
203 ( 0xcb  ) INSL ldi
204 ( 0xcc  ) INST popr
205 ( 0xcd  ) INST pushr
206 ( 0xce  ) INST dupr
207 ( 0xcf  ) INST ext
208 ( 0xd0  ) INST get
209 ( 0xd1  ) INST put

HEX
: (makeHead)
   20 word                            \ get name of new definition
   lastH @ nameR!                     \ fill link field of last word
   H @ lastH !                        \ save nfa in lastH
   DUP c@ I,                          \ store count
   count FOR AFT
      count I,                        \ fill name field
   THEN NEXT
   DROP 
   ;
: makehead
   >IN @ >R                           \ save interpreter pointer
   (makehead)
   R> >IN !                           \ restore interpreter pointer
   ;

: $LIT ( -- )
   22 WORD
   DUP c@ I, ( compile count )
   count FOR AFT
      count I, ( compile characters )
   THEN NEXT    DROP ;

: ldb bipush ;
: ldw sipush ;
: LIT bipush ;

: begin h @ ;
: bz    ifeq ;
: bra   goto ;
: jmp   goto ;

: if      h @ 1+ 0 bz ;  
: ifeqq   h @ 1+ 0 if_icmpeq ;  
: ifneg   h @ 1+ 0 iflt ;  
: ifgreat h @ 1+ 0 if_icmpgt ;  
: ifless  h @ 1+ 0 if_icmplt ;  
: skip    h @ 1+ 0 bra ; 
: then    begin SWAP ramw! ;
: else    skip  SWAP then ;
: until   bz ;
: while   if SWAP ;
: repeat  bra then ;
: again   bra ;
: aft ( a -- a' a" ) DROP skip begin SWAP ;
: for ( -- a ) pushr begin ;
: next ( a -- ) donext ;

: CODE makeHead begin .head CONSTANT  DOES> R> @ invokevirtual ; 




















