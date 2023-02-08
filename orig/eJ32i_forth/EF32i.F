\ eJ32f.f
: code CODE ;
: ::   CODE ;
: ;;   return ; 

CRR .( Chararter IO ) CRR
:: bye   ext ;;      
:: key   get ;;      
:: emit  put ;;

CRR .( Common functions ) CRR
:: max ( n n -- n ) 2DUP      < if SWAP then DROP ;;
:: min ( n n -- n ) 2DUP SWAP < if SWAP then DROP ;;
:: /mod ( n n -- r q )
   2DUP / >R MOD R> ;;
:: */ ( n n n -- q ) 
   >R * R> / ;;

CRR .( Memory access ) CRR
:: execute ( a ) >R ;;
:: here ( -- a ) CP @ ;;
:: pad ( -- a ) CP @ 50 LIT + ;;
:: cmove ( b b u -- ) 
  for aft >R DUP C@ R@ C! 1+ R> 1+
  then next 2DROP ;;
:: fill ( b u c -- ) 
  SWAP for SWAP aft 2DUP C! 1+ then next 2DROP ;;

CRR .( Numeric Output ) CRR \ single precision
:: digit ( u -- c )
  9 LIT OVER < 7 LIT AND + 
  ( CHAR 0 ) 30 LIT + ;;
:: extract ( n base -- n c )
  /mod SWAP digit ;;
:: <# ( -- ) pad HLD ! ;;
:: hold ( c -- ) HLD @ 1- DUP HLD ! C! ;;
:: # ( u -- u ) BASE @ extract hold ;;
:: #s ( u -- 0 ) begin # DUP while repeat ;;
CRR
:: sign ( n -- ) 0< if ( CHAR - ) 2D LIT hold then ;;
:: #> ( w -- b u ) DROP HLD @ pad OVER - ;;
:: str ( n -- b u ) DUP >R ABS <# #s R> sign #> ;;
:: hex ( -- ) 10 LIT BASE ! ;;
:: decimal ( -- ) 0A LIT BASE ! ;;

CRR .( Basic I/O ) CRR
:: space ( -- ) BL emit ;;
:: spaces ( +n -- ) for aft space then next ;;
:: >char ( c -- c )
  $7E LIT min BL max ;;
:: type ( b u -- )
  for aft COUNT ( >char ) emit
  then next DROP ;;
:: cr ( -- ) ( =Cr )
  0A LIT 0D LIT emit emit ;;
:: do$ ( -- a , get prior frame )
  R> R> DUP COUNT +  >R SWAP >R ;; 

CRR
:: $"| ( -- a ) do$ ;; 
:: ."| ( -- ) do$ COUNT type ;;
::  .r ( n +n -- )
  >R str R> OVER - spaces type ;;
::  . ( n -- )
  str space type ;;
:: ? ( a -- ) @ . ;;

CRR .( Numeric Input ) CRR \ single precision
:: digit? ( c base -- u t | x 0 )
  >R ( c ) DUP 40 LIT >
  if 5F LIT AND 37 LIT - ( above @ )
  else DUP 39 LIT >
    if DROP 7F LIT ( above 9 )
    else 30 LIT - DUP ( 0-9 )
      0< if ( below 0 ) DROP 7F LIT then
    then
  then DUP R> ( u u base ) < ( u t | x 0 )
  ;;
:: number? ( a -- n T | a F )
  DUP >R COUNT >R ( a+1 )
  COUNT ( a+2 c - ) 2D LIT = ( a+2 f )
  DUP tmp !
  if R> 1- ( a+2 n-1 )
  else 1- R> ( a+1 n )
  then tmp @ >R iconst_0 tmp !
  for aft ( a' )
    COUNT ( a'+1 c ) BASE @ digit? ( a'+1 b  f )
    if tmp @ BASE @ * + tmp !
    else 2DROP R> R> 2DROP R> iconst_0 ( a 0 ) EXIT
    then
  then next
  DROP tmp @ ( u ) R> if NEGATE then
  iconst_m1 R> DROP ;; ( u t )
CRR .( Parsing ) CRR
:: parse ( c a -- a-1 )
  DUP tmp ! >IN ! ( c )
  begin key DUP emit DUP >IN @ C! $20 LIT > until
  begin iconst_1 >IN +! ( c )
    key DUP emit 2DUP XOR ( c k f1 ) 
    OVER $1F LIT > ( c k f1 f2 ) AND ( c k f )
  while >IN @ C! ( c )
  repeat ( c k )
  2DROP tmp @ >IN @ OVER - ( a n )
  SWAP 1- SWAP ( a-1 n )
  OVER C! ( a-1 )
  ;;
:: token ( -- a , parser buffer )
  BL CP @ iconst_3 + parse  ;; 
:: word ( c -- a , word buffer )
  CP @ 1+ parse ;;

CRR .( Dictionary Search ) CRR
:: name> ( na -- ca ) COUNT 1F LIT AND +  ;;
:: same? ( a na -- a na diff ) 
  OVER W@ OVER W@ ( a na ca cna ) 
  $1FFF ldi AND XOR ucase @ AND ?DUP if EXIT ( a na diff ) then
  OVER C@ 1- >R ( a na )
  OVER 2+ OVER 2+ R> ( a na a+1 na+1 length ) 
  for aft OVER R@ + C@ ( a na a+i na+i ca ) 
    OVER R@ + C@ ( a na a+i na+i ca cna ) 
    XOR ucase @ AND ( a na a+i na+i diff ) 
    if R> 2DROP ( a na a+i ) EXIT then 
  then next ( a na a+i na+i ) 
  2DROP iconst_0  ;; ( a na 0 ) 

:: name? ( a -- cfa nfa | a 0 )
  CONTEXT ( a va )
  begin W@ DUP  ( a na na )
  while ( a na )
    same? ( a na f )
    if 2- ( a la ) DUP tmp ! ( save for see )
    else SWAP DROP DUP name> SWAP EXIT ( ca na )
    then
  repeat ;; ( a 0 --, dictionary start )

CRR .( compiler ) CRR
:: [ ( -- )
  iconst_0 COMPI ! ;; IMMEDIATE
:: ] ( -- )
  iconst_m1 COMPI ! ;; 
:: , ( n -- ) here DUP CELL+ CP ! ! CP @ DP ! ;;
:: w, ( w -- ) here DUP 2+ CP ! W! CP @ DP ! ;;
:: c, ( c -- ) here DUP 1+ CP ! C! CP @ DP ! ;;
:: allot ( n -- ) 
   for aft iconst_0 c, then next ;;
:: compil ( w -- ) B6 LIT c, w, ;; 
:: literal ( n ) 
   DUP 0< if CB LIT c, , EXIT then
   DUP $100 ldi < if 10 LIT c, c, EXIT then
   DUP $10000 ldi <
   if 11 LIT c, w,
   else CB LIT c, , 
   then ;; 

CRR ( outer interpreter )
:: ok ( -- )
  COMPI @ if else
    cr >R >R >R DUP .
    R> DUP . R> DUP . R> DUP . 
    ."| $LIT >ok " 
  then ;;
:: quit ( -- )
  [ ( outer interpret )
  begin
    token ( a )
    name? ( ca na | a 0 )
    ?DUP ( ca na na | a 0 )
    if ( ca na )
      C@ $80 LIT AND ( ca immd )
      if ( ca ) execute 
      else
        COMPI @ if compil else execute then
      then
    else ( a )
      number? ( n f | a 0 )
      if ( n ) COMPI @ if literal then
      else ( a ) 
        DP @ CP ! ( clean dictionary )
        COUNT type $3F LIT emit cr [
      then 
    then 
    COMPI @ if else ok then
  again   
:: abort"| ( f -- )
  if do$ COUNT type quit then do$ DROP ;;
:: error ( a -- )
  space COUNT type $3F LIT emit cr quit

CRR .( colon compiler ) CRR
:: compile ( -- )
  R> 1+ DUP W@ compil
  2+ >R ;;
:: ?unique ( a -- a )
  DUP name?
  if COUNT type ."| $LIT reDef "
  then DROP ;;
:: $,n ( a -- )
  DUP @
  if ?unique
    ( na) CP @ DP !
    ( na) DUP name> CP !
    ( na) DUP LAST ! \ for overt
    ( na) 2-
    ( la) CONTEXT W@ SWAP W! EXIT
  then error
:: overt ( -- ) LAST @ CONTEXT W! ;;
:: ; ( -- )
  B1 LIT c, [ overt ;; IMMEDIATE
:: : ( -- ; <string> )
  token $,n ] ;;

CRR .( Tools ) CRR
:: ' ( -- ca )
  token name? if EXIT then
  error
:: dm+ ( b u -- b+u )
  OVER 6 LIT .r space
  for aft DUP C@ 3 LIT .r 1+
  then next ;;
:: dump ( b u -- )
  hex  10 LIT /
  for aft cr 10 LIT dm+ space
    DUP 10 LIT - 10 LIT type
  then next DROP ;;

CRR
:: >name ( ca -- na | F )
  CONTEXT ( ca la )
  begin W@ DUP ( ca na na )
  while 2DUP name> ( ca na ca ca ) XOR
    if 2- ( ca la )
    else SWAP DROP EXIT ( na )
    then
  repeat SWAP DROP ( na=0 ) ;; 
:: id ( a -- )
  COUNT $01F LIT AND type space ;;

CRR
:: see ( -- ; <string> )
  cr ' ( ca --, tmp has next la )
  begin ( ca )
    COUNT DUP $B6 LIT XOR ( ca+1 b f )
    if . space
    else DROP COUNT >R ( ca+2 )
      COUNT $100 ldi * R> + ( ca+3 w ) >name
      ?DUP if id else $5F LIT emit space then
      1+ ( ca+4 )
    then 
    DUP tmp @ > ( ca+4 )
  until DROP ;;
:: words ( -- )
  cr CONTEXT
  begin W@ ?DUP
  while DUP id 2-
  repeat cr ;;
:: case if $FFFFFFDF ldi else $FFFFFFFF ldi then ucase ! ;;

CRR .( Hardware reset ) CRR
:: diagnose     ( - )
     get put get put get put
     9 LIT 9 LIT =
     8 LIT 9 LIT =
     9 LIT 8 LIT =
     $65 LIT iconst_0 0< +
\     mask
\ 'F'  prove + 0<         
     -2 ldi 0<     \ -1
     4 LIT +     \ 3
     $43 LIT +       \ 'F'
\ 'o' logic: XOR AND OR
     $4F LIT $6F LIT XOR    \ 20h
     $F0 LIT AND
     $4F LIT OR
\ 'r' stack: DUP OVER SWAP DROP
      8 LIT 6 LIT SWAP
      OVER XOR 3 LIT AND AND
      $70 LIT +        \ 'r'
\ 't'-- prove BRANCH ?BRANCH
      iconst_0 if $3F LIT then
      -1 ldi if $74 LIT else $21 LIT then
\ 'h' -- @ ! test memeory address
      $68 LIT $30 LIT !
      $30 LIT @
\ 'M' -- prove >R R> R@
      $4D LIT >R R@ R> AND
\ 'l'  -- prove 'next' can run
      $61 LIT $A LIT for iconst_1 + next
\ 'S' -- prove 2!, 2@
      $50 LIT $3 LIT
      $30 LIT 2!
      $30 LIT 2@
      XOR
\ 'em' -- prove imul, idiv, irem
      $656D ldi $10000 ldi *
      DUP $1000000 ldi /
      swap $1000000 ldi MOD
      $10 LIT ishr
\ 'it' -- prove /, MOD
      $7469 ldi DUP $100 ldi MOD
      swap $100 ldi /
      ;;

:: cold ( -- )
   diagnose
   cr ."| $LIT eJ32 v1.01"
   cr quit

CRR ( conditionals ) CRR
(makehead) 0<
   ifneg iconst_0 else iconst_m1 then 
   return
(makehead) =
   ifeqq iconst_0 else iconst_m1 then 
   return
(makehead) >
   ifgreat iconst_0 else iconst_m1 then
   return
(makehead) <
   ifless iconst_0 else iconst_m1 then
   return
(makehead) ?dup
   dup if dup then return
(makehead) abs 
   dup ifneg else ineg then return

CRR .( Structures ) CRR
:: begin ( -- a ) here ;; IMMEDIATE
:: then  ( A -- ) begin SWAP W! ;; IMMEDIATE
:: for   ( -- a ) $CD LIT c, begin ;; IMMEDIATE
CRR
:: next  ( a -- ) $CA LIT c, w, ;; IMMEDIATE
:: until ( a -- ) $99 LIT c, w, ;; IMMEDIATE
:: again ( a -- ) $A7 LIT c, w, ;; IMMEDIATE
:: if    ( -- A ) $99 LIT c, begin 0 LIT w, ;; IMMEDIATE
:: ahead ( -- A ) $A7 LIT c, begin 0 LIT w, ;; IMMEDIATE
CRR
:: repeat ( A a -- ) again then ;; IMMEDIATE
:: aft  ( a -- a A ) DROP ahead begin SWAP ;; IMMEDIATE
:: else   ( A -- A ) ahead SWAP then ;; IMMEDIATE
:: while ( a -- A a) if SWAP ;; IMMEDIATE

CRR ( strings ) CRR
:: $," ( -- ) ( CHAR " )
   $22 LIT word DUP C@ + 1+ CP ! ;;
:: abort" ( -- ; <string> )
   $B6 LIT c, forth_' abort"| >body forth_@ ldi w,
   $," ;; IMMEDIATE
:: $" ( -- ; <string> )
   $B6 LIT c, forth_' $"| >body forth_@ ldi w,
   $," ;; IMMEDIATE
:: ." ( -- ; <string> ) 
   $B6 LIT c, forth_' ."| >body forth_@ ldi w,
   $," ;; IMMEDIATE

CRR ( defining ) CRR
:: docon popr @ ;;
:: dovar popr ;;
:: does ( -- ) popr LAST @ name> 1+ ! ;;
:: code ( -- ; <string> )
   token $,n overt ;;
:: create ( -- ; <string> ) 
   code $B6 LIT c, forth_' dovar >body forth_@ ldi w,
   CP @ DP ! ;;
:: variable ( -- ; <string> ) 
   create 0 LIT , CP @ DP ! ;;
:: constant ( n --; <string> )
   code $B6 LIT c, forth_' docon >body forth_@ ldi w,
   , CP @ DP ! ;;

CRR
(makehead) r> $CC LIT c, return IMMEDIATE
(makehead) r@ $CE LIT c, return IMMEDIATE
(makehead) >r $CD LIT c, return IMMEDIATE
(makehead) .( ( -- ) $29 LIT parse type ;; IMMEDIATE
(makehead) ( $29 LIT parse 2DROP ;; IMMEDIATE
(makehead) immediate $80 LIT LAST +! ;;

CRR ( primitives ) CRR
(makehead) exit return
(makehead) ! swap iastore return
(makehead) @ iaload return
(makehead) c! swap bastore return
(makehead) c@ baload return
(makehead) w! swap sastore return
(makehead) w@ saload return

(makehead) swap swap return
(makehead) drop pop return
(makehead) 2drop pop2 return
(makehead) over dup2 pop return
(makehead) 2dup dup2 return

(makehead) +  iadd return
(makehead) -  isub return
(makehead) *  imul return
(makehead) /  idiv return
(makehead) mod  irem return
(makehead) or  ior return
(makehead) and  iand return
(makehead) xor  ixor return
(makehead) not iconst_m1 ixor return
(makehead) negate ineg return
(makehead) 1- iconst_m1 iadd return
(makehead) 1+ iconst_1 iadd return
(makehead) 2- iconst_2 isub return
(makehead) 2+ iconst_2 iadd return
(makehead) cell- iconst_4 isub return
(makehead) cell+ iconst_4 iadd return

(makehead) bl $20 LIT return
(makehead) +!
   dup pushr iaload iadd 
   popr swap iastore return
(makehead) rot
   pushr swap popr swap return
(makehead) -rot
   dup_x2 pop return
(makehead) 2!
   dup2 swap iastore swap pop
   iconst_4 iadd swap iastore return
(makehead) 2@
   dup iaload swap iconst_4 iadd iaload swap
   return
(makehead) count 
   dup baload swap iconst_1 iadd swap return
(makehead) dup dup return

CRR

h forth_@ forth_dup forth_dup 

0 org 
cold 0 #, 0 #, 0 #, 0 #,

$40 org
$10 #,
$0  #, 
$0  #, 
$0  #,
lasth forth_@ $10 LSHIFT #,
( h )         #,
( h )         #,
( h )         #,
$0  #, 
$0  #,
$FFFFFFDF  #,
$1000 #,
$1400 #,


