: <<bufferio.f>> ;
(
 2002.4.25 : fix consoleEMIT crash when buffer full. 
           : add copy and paste support.
)
VARIABLE LINEBUFLEN
VARIABLE LINEBUFEND
$200 CONSTANT LINEBUFMAXLEN
CREATE LINEBUF LINEBUFMAXLEN ALLOT 
LINEBUF LINEBUFMAXLEN 0 FILL
CREATE MSG 7 CELLS ALLOT
VARIABLE OUTPUT.EDIT CONSOLE.EDIT OUTPUT.EDIT !

\ paste text set clipboard>in = 1
\ if clipboard>in > 0 , one by one
VARIABLE .STATUSBAR
VARIABLE .DATASTACK
VARIABLE .WORDS
VARIABLE .SEE
VARIABLE .DUMP
VARIABLE .DUMPREFRESH
VARIABLE linebuflastbyte

VARIABLE thechar
VARIABLE lastlength

\ Flush output buffer to edit control
: FLUSH  (  -- )                                \ flush output buffer
 
  LINEBUFLEN @ 0 = IF EXIT THEN                \ nothing to flush
  LINEBUFLEN @ LINEBUF + LINEBUFEND !          \ point to last byte of linebuf

\ ensure linebuf ends with null
  LINEBUFEND @ C@ linebuflastbyte !            \ store in lastsave
  0 LINEBUFEND @ C!                            \ replace with null terminator

\ output linebuffer to edit control
  OUTPUT.EDIT @ WM_GETTEXTLENGTH 0  0         SendMessageA >R
  OUTPUT.EDIT @ EM_SETSEL        R@ R>        SendMessageA DROP
  OUTPUT.EDIT @ EM_REPLACESEL    0  LINEBUF   SendMessageA DROP

  linebuflastbyte @ LINEBUFEND @ C!             \ restore last byte
  0 LINEBUFLEN !                                \ reset linebuffer line
;

\ return control back to windows
: PAUSE

  .DUMP      @EXECUTE  

  FLUSH 
  SP@ (ebp) !
  
\ thread will stop at GetMessageA
\ until any message comes in (WM_CHAR, WM_PAINT , etc )  
  MSG 0 0 0 GetMessageA
  ?DUP IF
      MSG TranslateMessage DROP
      MSG DispatchMessageA DROP
  ELSE 
    BYE EXIT
  THEN
  
  (ebp) @ SP!
;

\ handle backspace for chinese character
: CONTROLCHARHANDLER  ( -- )
  thechar @ $A = IF EXIT THEN
  thechar @ $D = IF .DUMPREFRESH @EXECUTE THEN  \ copy to command buffer

  FLUSH
  &DefEditProc OUTPUT.EDIT @ WM_GETTEXTLENGTH 0 0 CallWindowProcA  lastlength !
  &DefEditProc OUTPUT.EDIT @ EM_SETSEL lastlength @ lastlength @ CallWindowProcA DROP
  &DefEditProc OUTPUT.EDIT @ WM_CHAR thechar @ 0 CallWindowProcA DROP

  &DefEditProc OUTPUT.EDIT @ WM_GETTEXTLENGTH 0 0 CallWindowProcA
  lastlength @ - lastlength !

\ DELTALEN = 0   normal state              ( after kTAP )
\ DELTALEN = -1  ascii character deleted   ( before kTAP)
\ DELTALEN = -2  chinese character deleted ( before kTAP)
  -1 DELTALEN @  < IF 
    lastlength @ DELTALEN !                \ update deltalength for first echo in BKSP
  THEN
;

: consoleEMIT  ( c -- )                    \ EMIT a char to buffer
  thechar !
  thechar @ $20 < IF CONTROLCHARHANDLER EXIT THEN
  
  LINEBUFMAXLEN 1- LINEBUFLEN @ < IF  FLUSH THEN      \ flush if buffer full

  LINEBUF LINEBUFLEN @ + LINEBUFEND !      \ pointer to last byte
    
  thechar @ $100 < IF                      \ single byte
    thechar @ LINEBUFEND @ C!
  ELSE                                     \ double byte chinese character
    thechar @ 8 RSHIFT LINEBUFEND @ C!     \ swap high low byte
    thechar @   LINEBUFEND @ 1+ C!
    1 LINEBUFLEN +!
  THEN
  1 LINEBUFLEN +!
;
\ check if data in CLIPBUF
\ if yes, set the lastkey and increase CLIPBOARD>IN
\ for last byte, insert an extra blank.
: CHECKCLIPBOARD
  CLIPBOARD>IN @ ?DUP IF
    CLIPBUF + 1- C@ ?DUP IF          \ check clipbuf
      $80 OVER < IF                  \ check if chinese character
        1 CLIPBOARD>IN +!            \ point to next char
        8 LSHIFT                     \ convert to high byte
        CLIPBOARD>IN @ CLIPBUF + C@  \ next byte as lowbyte
        +                            \ compose chinese character
      THEN
      lastkey !                      \ set to lastkey
      1 CLIPBOARD>IN +!              \ point to next char
      \ call wndproc to process the rest
       CONSOLE.EDIT WM_USER 0 0 PostMessageA DROP 
    ELSE
      $20 lastkey !       \ send a extra bl
      0 CLIPBOARD>IN !    \ reset 
    THEN
  THEN
;


: console?RX  ( -- c T | F )
  CHECKCLIPBOARD  
  lastkey @ ?DUP                           \ probe last key
  0 lastkey !                              \ clear last key
;

: console?KEY ( -- T |F )
  CHECKCLIPBOARD
  lastkey @ 
;
: consoleKEY ( -- c )
  .STATUSBAR @EXECUTE                      \ draw statusbar
  .DATASTACK @EXECUTE                      \ draw datastack window
  BEGIN PAUSE console?KEY UNTIL
  lastkey @ 0 lastkey !            \ infinite loop for keyboard input
;

' consoleEMIT DEF'EMIT !                    \ setup i/o vectors
' console?KEY DEF'?KEY !
' console?KEY '?KEY !
' consoleEMIT 'EMIT !
' consoleEMIT 'ECHO !
' consoleKEY 'KEY !