( ep32s, bytecode & subroutine thread )
HEX
cr .( system variables ) 
: BASE    40 LIT ;    \ number base
: COMPI   44 LIT ;    \ compile flag
: >IN     48 LIT ;    \ ptr to input char
: HLD     4C LIT ;    \ ptr to output digit
: CONTEXT 50 LIT ;    \ ptr to vocabulary
: LAST    54 LIT ;    \ ptr to last name 
: CP      58 LIT ;    \ ptr dictionary top
: DP      5C LIT ;    \ ptr to last dictionary entry
: FENCE   60 LIT ;    \ ptr to boot dictionary 
: tmp     64 LIT ;    \ scratch
: ucase   68 LIT ;    \ case insensitive, $FFFFFFDF
: input   6C LIT ;    \ input buffer
: output  70 LIT ;    \ output buffer

cr .( macro words ) cr
: EXIT return ;
: ! ( n a -- ) swap iastore ;
: @ ( a - n ) iaload ;
: C! ( n a -- ) swap bastore ;
: C@ ( a - n ) baload ;
: W! ( n a -- ) swap sastore ;
: W@ ( a - n ) saload ;
: >R ( n ) pushr ;
: R> ( - n ) popr ;
: R@ ( - n ) dupr ;
: DUP ( n - n n ) dup ;
: SWAP ( n1 n2 - n2 n1 )
   swap ;
: DROP ( w w  -- )
   pop ;
: 2DROP ( w w  -- )
   pop2 ;
: + iadd ;
: - isub ;
: * imul ;
: / idiv ;
: MOD irem ;
: OR ( n n - n )
   ior ;
: AND iand ;
: XOR ixor ;
: OVER dup2 pop ;
: NEGATE ( n -- -n )
   ineg ;
: 1- ( a -- a )
   iconst_m1 iadd ;
: 1+ ( a -- a )
   iconst_1 iadd ;
: 2- ( a -- a )
   iconst_2 isub ;
: 2+ ( a -- a )
   iconst_2 iadd ;
: CELL- ( a -- a )
   iconst_4 isub ;
: CELL+ ( a -- a )
   iconst_4 iadd ;
: NOT ( w -- w ) iconst_m1 ixor ;
: BL ( -- 32 )
   20 LIT ;
: +! ( n a -- )
   dup pushr iaload iadd 
   popr swap iastore ;
: ROT ( w1 w2 w3 -- w2 w3 w1 )
   pushr swap popr swap ;
: -ROT ( w1 w2 w3 -- w3 w1 w2 )
   dup_x2 pop ;
: 2DUP ( w1 w2 -- w1 w2 w1 w2 )
   dup2 ;
: 2! dup2 ! swap pop iconst_4 iadd ! ;
: 2@ dup @ swap iconst_4 iadd @ swap ;
: COUNT ( b -- b+1 c )
   dup baload swap 1+ swap ;
: 0< ( n - f )
   ifneg iconst_0 else iconst_m1 then ;
: = ( w w -- t )
   ifeqq iconst_0 else iconst_m1 then ;
: > ( n1 n2 - f )
   ifgreat iconst_0 else iconst_m1 then ;
: < ( n1 n2 - f )
   ifless iconst_0 else iconst_m1 then ;
: ?DUP ( w -- w w | 0 )
   dup if dup then ;
: ABS ( n -- +n )
   dup ifneg else ineg then ;



