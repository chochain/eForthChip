: <<init.f>> ;
HEX

: CAPS -1 CAP ! ; 
  CAPS   		 \ change to case insensitive mode

  CREATE FENCE HERE ,    \ protect system words

: DOES>                  \ change runtime behavior to following code, para on return stack
  R>           ( ra )    \ run time code address ra of the defining word
  LAST @ NAME> ( ra ca ) \ code address ca of the defined word
  1+ SWAP    ( ca+1 ra ) \ skip 1-byte call code , dovar-addr parent-body
  OVER CELL+ -           \ compute run time code relative-offset 
  SWAP ! ;               \ overwrite doVar to run time code relative-offset

VARIABLE CLINK   \ for collecting all related constants 05mar02sam
\ link the constant into CLINK list   05mar02sam

: MakeCLink ( -- ) HERE CLINK @ , CLINK ! ;

: CLinkCONSTANT CREATE , MakeCLink
  DOES>  [ HERE ]  R> @ ; 
  ClinkCONSTANT doCLinkCON \ make runtime code addr as a CLinkconstant 05mar02sam

: CONSTANT CREATE ,
  DOES>  [ HERE ]  R> @ ;
  ClinkCONSTANT doCON \ make runtime code addr as a CLinkconstant 11jun02sam

  VARIABLE   LASTVOC  
  ROOT CELL+ LASTVOC ! \ firstly, take ROOT as the last defined vocabulary

: >BODY 5 + ;
: COMPILING 'EVAL @ ['] $COMPILE = ;

: DEFER CREATE ['] NOP , DOES> [ HERE ] R> @EXECUTE ;
  CONSTANT doDEFER MakeCLink

  VARIABLE (IS)  DEFER IS IMMEDIATE
  
: (_is_) ( n -- ) R> >BODY DUP >R ( n a )
  DUP @ + CELL+ ( n ca ) >BODY ( n pa ) ! ; \ refined later for more effesion
' (_is_) (IS) !

: _is_ ( interpret: ca <valuename> -- )
     ( compiling: <valuename> -- )
  ' ( v ca ) DUP >BODY ( v ca pa ) DUP CELL- @ + ( v ca ca' )
  doDEFER XOR ( v ca flag ) OVER C@ $E8 XOR OR ( v ca flag' ) 
  IF ( v ca ) CR ." can't put ca into non-DEFER word "
     >NAME .ID ABORT EXIT
  THEN ( v ca ) COMPILING
  IF (IS) @ call, call,
  ELSE >BODY ! 
  THEN ; IMMEDIATE
  
'  _is_  _is_  IS

: NAME&VOC ( ca -- na va -1 | ca 0 ) LASTVOC
  BEGIN @ ( ca va ) ?DUP
  WHILE ( ca va ) DUP >R CELL- ( ca la ) 
      BEGIN @ ( ca na ) ?DUP
      WHILE 2DUP NAME> =
         IF ( ca na ) SWAP DROP R> ( na va ) -1 EXIT
         then CELL-
      REPEAT ( ca ) R>
  REPEAT ( ca ) 0 ;
CR space
: >NAME ( ca -- na | 0 ) NAME&VOC SWAP DROP 
  IF EXIT
  THEN 0 ;

: ALIAS ( CA <NAME> -- ) 
  BL WORD $,n OVERT
  $E9 C, DUP HERE CELL+ - ,
  >NAME C@ $80 AND
  IF IMMEDIATE
  THEN ;
' FLOAD ALIAS INCLUDE

: RET, $C3 C, ;
: JMP, $E9 [ ' call, 9 + ] LITERAL >R ;

: EXIT 'EVAL @ ['] $COMPILE =
  IF [ ' RET, JMP, ] \ compile the RET code then exit
  THEN R> R> 2DROP   \ ignore the rest of a loaded file
; IMMEDIATE

: >BODY 1+ CELL+ ;
: BODY> 1- CELL- ;

: VLINK> ( vl -- ca ) $9 - ;
: >VLINK ( ca -- vl ) $9 + ;

: VOCABULARY CREATE 0 , HERE LASTVOC @ , LASTVOC ! 
  DOES> [ HERE ] R> CONTEXT ! ;
  CONSTANT doVOC MakeCLink

: ALSO CONTEXT 7 CELLS + DUP @
  ABORT" no more than 8 vocabularies in CONTEXT"
  BEGIN CELL- DUP @ 0 =
  UNTIL CELL+
  BEGIN CELL- DUP @ OVER CELL+ ! DUP CONTEXT =
  UNTIL DROP ;

: DEFINITIONS CONTEXT @ CURRENT ! ;

: PREVIOUS CONTEXT DUP CELL+ CELL+ @  
  IF BEGIN CELL+ DUP @ OVER CELL- ! DUP @ 0 =
     UNTIL DROP EXIT
  THEN ABORT" no less than 2 vocabularies in context" ;

: | ALSO ' EXECUTE ' EXECUTE PREVIOUS ;

  VOCABULARY FORTH
  vocabulary hidden

: ONLY CONTEXT 9 CELLS 0 FILL
  ['] FORTH >BODY  DUP CURRENT !  DUP CONTEXT 2! ;

  LAST @ ' FORTH >BODY       !  \ let FORTH link to current list
  0      ' FORTH >BODY CELL+ !  \ isolate FORTH vocabulary

  ONLY FORTH DEFINITIONS
  
: .VOCNAME ( va -- ) DUP ROOT =
  IF DROP ." root" EXIT
  THEN BODY> >NAME .ID ;

: ORDER 
  CR ." CONTEXT: " CONTEXT
  BEGIN DUP @ ?DUP
  WHILE ( a va ) .VOCNAME SPACE CELL+
  REPEAT DROP 
  CR ." CURRENT: " CURRENT @ .VOCNAME ;

: VOCS CR LASTVOC
  BEGIN @ ?DUP
  WHILE DUP CELL- .VOCNAME SPACE
  REPEAT ;

: doFORGET0 ( ca -- ) DUP >NAME ?DUP
  IF ( ca na ) SWAP DROP CELL-
  THEN ( a ) LASTVOC
  BEGIN @ ?DUP
  WHILE ( a va ) DUP >R CELL-
      BEGIN @ CELL- ( a la ) 2DUP SWAP <
      UNTIL CELL+ R@ CELL- ! R>
  REPEAT CP ! ;

: doFORGET ( ca -- ) DUP >NAME ?DUP
  IF ( ca na ) SWAP DROP CELL-
  THEN ( a ) LASTVOC
  BEGIN 
     BEGIN 2DUP @ <
     WHILE DUP @ @ OVER !
     REPEAT @ ?DUP
  WHILE ( a va ) DUP >R CELL-
      BEGIN @ CELL- ( a la ) 2DUP SWAP <
      UNTIL CELL+ R@ CELL- ! R>
  REPEAT CP ! ;

: EMPTY ( -- ) CONTEXT 8 CELLS 0 FILL  ONLY 
  ['] <<init.f>> >NAME CELL- @ CELL- 
  ( LA ) DUP @ ( LA NA ) DUP LAST ! ( LA NA )
  ROOT ! ( LA ) CP ! 
  ROOT CURRENT !
  ROOT DUP CONTEXT 2! ;

: FORGET ' DUP FENCE @ < ABORT" cannot forget any word in FENCE"
  doFORGET ;

: ANEW BL WORD DUP NAME?
  IF doFORGET
  ELSE DROP 
  THEN $,n HERE [COMPILE] LITERAL COMPILE doFORGET 
  [COMPILE] ; ;

: FREESPACE  ( -- freespace )
  EOD @ HERE - 
;