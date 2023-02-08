( meta32g.f for eJ32g, 17nov21cht )

HEX
VARIABLE debugging?
\ 1 debugging? ! 

: .head ( addr -- addr )
   SPACE >IN @ 20 WORD COUNT TYPE >IN !
   DUP .
   ;

: cr CR
   debugging? @
   IF .S KEY 0D = ABORT" DONE"
   THEN
   ;

: forth_' ' ;
: forth_dup DUP ;
: forth_drop DROP ;
: forth_over OVER ;
: forth_swap SWAP ;
: forth_@ @ ;
: forth_! ! ;
: forth_and AND ;
: forth_+ + ;
: forth_- - ;
: forth_word WORD ;
: forth_words WORDS ;
: forth_.s .S ;
: CRR cr ;
: forth_.( [COMPILE] .( ;
: forth_count COUNT ;
: forth_r> R> ;
: -or   XOR ;
: >body 5 + ;
: forth_forget FORGET ;

CREATE ram  2000 ALLOT
: reset  ram 2000 0 FILL ; 
: ram@   ram +  count >r count >r count >r c@ r> r> r>
         8 lshift + 8 lshift + 8 lshift +  ;
: ram!   ram +  2dup 3 + c! swap 8 rshift swap 2dup 2+ c! 
         swap 8 rshift swap 2dup 1+ c!
         swap 8 rshift swap c! ;
: ramw@  ram +  count 8 lshift swap c@ + ;
: ramw!  ram +  2dup 1+ c! swap 8 rshift swap c! ;
: ramc@  ram +  c@ ;
: ramc!  ram +  c! ;
: binary 2 BASE ! ;
: FOUR   (  a -- a+16 ) 10 FOR AFT  DUP RAMC@ 3 U.R  1 + THEN NEXT
      10 - SPACE 10 FOR AFT  DUP RAMC@ 20 MAX 7E MIN EMIT 1 + THEN NEXT ;
: SHOW ( a -- a+256 )   10 FOR AFT  CR  DUP 7 .R SPACE
      FOUR THEN NEXT ;
: showram 0 $E FOR AFT SHOW THEN NEXT DROP ;

VARIABLE hFile
CREATE CRLF-ARRAY 0D C, 0A C,
: CRLF   
      hFile @ 
      CRLF-ARRAY 2
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   ;

: open-mif-file
   Z" ej32i.mif" 
   $40000000 ( GENERIC_WRITE )
   0 ( share mode )
   0 ( security attribute )
   2 ( CREATE_ALWAYS )
   $80 ( FILE_ATTRIBUTE_NORMAL )
   0 ( hTemplateFile )
   CreateFileA hFile !
   ;
: write-mif-line
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   CRLF
   ;
: write-mif-header
   CRLF
      hFile @ 
      $" WIDTH=8;" 
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   CRLF
      hFile @ 
      $" DEPTH=8192;" 
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   CRLF
      hFile @ 
      $" ADDRESS_RADIX=HEX;" 
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   CRLF
      hFile @ 
      $" DATA_RADIX=HEX;" 
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   CRLF
      hFile @ 
      $" CONTENT BEGIN;" 
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   ;

: write-mif-data
   0 ( initial ram location )
   $2000 FOR AFT
      CRLF
      hFile @ 
      OVER
      <# 3A HOLD 20 HOLD 3 FOR # NEXT 20 HOLD #>
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
      hFile @ 
      OVER ramc@ 
      <# 3B HOLD # # 20 HOLD #>
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
      1+
   THEN NEXT
   DROP ( discard ram location )
   ;

: close-mif-file
   CRLF
      hFile @ 
      $" END;" 
      PAD ( lpWrittenBytes )
      0 ( lpOverlapped )
      WriteFile
      IF ELSE ." write error" QUIT THEN
   CRLF
   hFile @ CloseHandle DROP
   ;

: write-mif-file
   open-mif-file
   write-mif-header
   write-mif-data
   close-mif-file
   ;

VARIABLE tests
VARIABLE tests-addr
VARIABLE tests-len
VARIABLE tests-end
VARIABLE tests-match
VARIABLE hFiletests
VARIABLE hMaptests
VARIABLE testsFileLength 0 ,
VARIABLE hFileEXT
VARIABLE EXTpointer ( extgp string at PAD )
VARIABLE EXTlength
VARIABLE WritenLength

20 constant tests-limit
0 tests-match !

: testsopen
  z" tests.txt"
  GENERIC_READ GENERIC_WRITE OR 
  FILE_SHARE_READ
  0
  OPEN_EXISTING
  FILE_ATTRIBUTE_ARCHIVE
  0
  CreateFileA hFiletests !
  
  hFiletests @
  testsFileLength cell+
  GetFileSize testsFileLength !
  
  hFiletests @
  0
  PAGE_READWRITE
  0
  0
  0
  CreateFileMappingA hMaptests !
  
  hMaptests @ 
  FILE_MAP_READ FILE_MAP_WRITE OR
  0  \ file offset high
  0  \ file offset low
  0  \ #byte to map 0 = all
  MapViewOfFile tests !
;

: testsclose
  tests @ UnmapViewOfFile DROP
  hMaptests @ CloseHandle DROP
  hFiletests @ CloseHandle DROP
;

 testsopen 
 tests @ ram $1000 + testsFileLength @ cmove 
 testsclose
 
FLOAD asm32i.f 
$100 org
FLOAD kern32i.f
FLOAD ef32i.f
write-mif-file
FLOAD sim32i.f


