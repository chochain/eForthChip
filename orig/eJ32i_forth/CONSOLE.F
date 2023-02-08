ANEW <<CONSOLE>>
( FORTH CONSOLE 
 2002.4.22 move EMIT,KEY,?KEY to bufferio.f
 2002.4.23 add PAGE
           EDIT will get focus when switch back with "Alt-Tab"
 2002.4.25 Copy and paste ok
           child controls use GetDlgItem instead 
           of handle to access
)

VARIABLE lastkey
VARIABLE hConsole
VARIABLE STACKVIEWWIDTH $80 STACKVIEWWIDTH !
CREATE CURRENTDIR $200 ALLOT
CURRENTDIR $200 0 FILL
  $201 CONSTANT EDITID
\ $202 CONSTANT LISTBOXID
  $206 CONSTANT STATUSBARID
 $1000 CONSTANT CLIPBUFSIZE
CREATE CLIPBUF  CLIPBUFSIZE ALLOT
: CONSOLECHILD: CREATE , 
  DOES> [ here ] hConsole @ R> @ GetDlgItem ;
  constant doCONSOLECHILD MakeCLink

EDITID		CONSOLECHILD: CONSOLE.EDIT
STATUSBARID	CONSOLECHILD: CONSOLE.STATUS
\ LISTBOXID	CONSOLECHILD: CONSOLE.LISTBOX

: &DefEditProc
  CONSOLE.EDIT GWL_USERDATA GetWindowLongA
;
: REFRESHCAPTION
  0 CURRENTDIR $FF  GetModuleFileNameA
  CURRENTDIR + 
  DUP $20202020 SWAP ! CELL+    \ spaces
  DUP $72727543 SWAP ! CELL+    \ curr
  DUP $20746E65 SWAP ! CELL+    \ ent
  DUP $3D726964 SWAP ! CELL+    \ dir:
  $FF SWAP GetCurrentDirectoryA DROP
  hConsole @ CURRENTDIR SetWindowTextA DROP
; 

: CD ( --path -- )
  BL WORD COUNT DROP SetCurrentDirectoryA DROP
  REFRESHCAPTION
;

: INSERTCOMMAND  ( str n -- ) \ insert a command string to console
  CLIPBUF SWAP 1+ CMOVE
  1 CLIPBOARD>IN !
;

\ copy data in clipboard to CLIPBUF
\ set CLIPBOARD>IN to 1

: GETCLIPBOARD
  0 OpenClipboard DROP
  CF_OEMTEXT GetClipBoardData
  ZCOUNT ?DUP 
  IF CLIPBUF SWAP 1+ 
     CLIPBUFSIZE MIN           \ check if exceed clipbufsize
     CMOVE                     \ copy clipboard and last null byte to 
                               \ second byte of CLIPBUF,
                               \ CLIPBOARD>IN start from 1
     1 CLIPBOARD>IN !
  ELSE DROP
  THEN CloseClipboard DROP
;

\ EDIT message handler
: EDITPROC ( hWnd uMsg wParam lParam -- res )
  GETMSGWLPARAM DROP
  
  \ chinese character input
  uMsg @ WM_IME_CHAR = 
  IF wParam @ lastkey ! EXIT
  THEN

\  uMsg @ WM_KEYDOWN = IF
\    wParam @ $26 = IF
\      \ copy command buffer and paste 
\    THEN
\  THEN
  
  \ normal ascii input
  uMsg @ WM_CHAR = IF 
  
     wParam @ $16 = 
     IF GETCLIPBOARD EXIT 
     THEN 
     
     wParam @ $18 = 
     IF 0 EXIT 
     THEN 
     
     
     wParam @ $3 = 
     IF   \ do not process CTRL+C
     ELSE wParam @ lastkey ! 0 EXIT
     THEN
  THEN &DefEditProc CONSOLE.EDIT uMsg @ wParam @ lParam @ CallWindowProcA
;

' EDITPROC MESSAGEHANDLER: &EDITPROC

\ create child controls
: CONSOLEONCREATE ( -- )
  0 Z" EDIT" 0
  $50200104     \ WS_CHILD+WS_VISIBLE+WS_VSCROLL+ES_NOHIDESEL+ES_MULTILINE
  0 0 $200 $200
  hConsole @ EDITID HINST @ 0
  CreateWindowExA DROP
 
  CONSOLE.EDIT GWL_USERDATA
  CONSOLE.EDIT GWL_WNDPROC GetWindowLongA SetWindowLongA DROP
  CONSOLE.EDIT GWL_WNDPROC &EDITPROC SetWindowLongA DROP
  CONSOLE.EDIT SetFocus DROP
  CONSOLE.EDIT WM_SETFONT SYSTEM_FIXED_FONT GetStockObject 0 SendMessageA DROP

  0 Z" msctls_statusbar32" 0
  WS_CHILD WS_VISIBLE OR
  CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT
  hConsole @ STATUSBARID HINST @ 0
  CreateWindowExA DROP
  
\  0 Z" LISTBOX" 0
\  WS_VISIBLE WS_CHILD LBS_NOSEL WS_VSCROLL OR OR OR
\  CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT
\  hConsole @ LISTBOXID HINST @ 0
\  CreateWindowExA DROP
;
cr
FLOAD .\conmenu.f

\ message handler for main console window
: CONSOLEPROC ( hWnd uMsg wParam lParam -- res )
  GETMSGWLPARAM hConsole !
  
  GetFocus hConsole @ = IF
    CONSOLE.EDIT SetFocus DROP
  THEN
\ adjust size of child control  
  uMsg @ WM_SIZE = IF
    hConsole @ RECT GetClientRect DROP
    CONSOLE.EDIT 0 0  RECT.RIGHT @  RECT.BOTTOM @ $14 - -1 MoveWindow DROP
\    CONSOLE.LISTBOX RECT.RIGHT @ STACKVIEWWIDTH @ - 1- 0  STACKVIEWWIDTH @ RECT.BOTTOM @ $14 - -1 MoveWindow DROP
    CONSOLE.STATUS 0 RECT.BOTTOM @ $14 - RECT.RIGHT @ RECT.BOTTOM @ -1 MoveWindow DROP
  THEN 
  uMsg @ WM_COMMAND = IF
    wParam @ ProcessMenuCommand
  THEN
  
  uMsg @ WM_CLOSE = IF
    hConsole @ DestroyWindow DROP
  THEN
  uMsg @ WM_CTLCOLOREDIT = IF
    2 GetStockObject EXIT    \ light gray background
  THEN
  uMsg @ WM_DESTROY = IF
    BYE
  THEN  
  hConsole @ uMsg @ wParam @ lParam @ DefWindowProcA 
;


' CONSOLEPROC MESSAGEHANDLER: &CONSOLEPROC



: NEWCONSOLE
  0 \ $80000
  FORMCLASSNAMEA
  Z" Console"                                 \ filename  as caption
  $10CF0180                                   \ WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN
  CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT CW_USEDEFAULT \ $380 $200
  0 0                                         \ no parent, no menu
  HINST @
  0
  CreateWindowExA hConsole ! 
  CONSOLEONCREATE
  hConsole @ GWL_WNDPROC &CONSOLEPROC SetWindowLongA DROP
  hConsole @ WM_SIZE 0 0 SendMessageA DROP
  
  hConsole @ 0 = IF 
    BYE 
  THEN
  
 consolemenu
; 

: PAGE   \ blank page
  &DefEditProc CONSOLE.EDIT EM_SETSEL     0 -1  CallWindowProcA DROP
  &DefEditProc CONSOLE.EDIT EM_REPLACESEL 0 Z" " CallWindowProcA DROP
;

\ open console window
NEWCONSOLE REFRESHCAPTION

FLOAD .\bufferio.f

\ from now on, EMIT will output to console window
\ copy boot message to edit window

&DefEditProc CONSOLE.EDIT EM_SETSEL        0 0         CallWindowProcA DROP 
&DefEditProc CONSOLE.EDIT EM_REPLACESEL    0 BOOTMSG  @ CallWindowProcA DROP

\ handle data stack and statusbar


.(  Console Code Size: ) HERE ' <<CONSOLE>> - DECIMAL . .(  bytes) HEX  


\ : setalpha >R hConsole @ 0 R> 2 SetLayeredWindowAttributes DROP
\ ;

\ $FF  setalpha
