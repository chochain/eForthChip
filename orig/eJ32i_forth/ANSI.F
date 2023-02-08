: <<ansi.f>> ;

: w, , -2 allot ; 
: w! dup @ $FFFF0000 and rot $FFFF and or swap ! ;
: w@ @ $FFFF and ;
: noop ;
: header bl word $,n ;
: false 0 ;
: true -1 ;
: nip swap drop ;
' [compile] alias postpone immediate
: (;code) r> ( ra )
  last @ name> ( ra ca )
  1+ swap over ( ca+1 ra ca+1 )
  cell+ - swap ! ;
: > SWAP < ;
: defer@ ' >body 'eval @ ['] $compile =
  if [compile] literal compile 
  then @ ; immediate
: 0= 0 = ;
: 0<> 0= not ;
: <> = not ;
: hide ;
' overt alias reveal
: CELL 4 ;
: cell/ cell / ;
: ON ( a -- ) -1 SWAP ! ; 
: OFF ( a -- ) 0 SWAP ! ;
: ERASE ( a n -- ) 0 FILL ;
