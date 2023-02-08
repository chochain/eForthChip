( windows UI
  2002.4.02   high level WindowProc ok
  2002.4.04   Message dispatcher
  2002.4.09   remove dispatcher
)

5 CONSTANT #MESSAGEHANDLER
CREATE SBPARTS $100 , $180 , $200 , $280 , $300 , $380 , 
               $400 , $480 , $500 , $580 , $600 ,
CREATE RECT $20 ALLOT
CREATE MOUSEPOS 8 ALLOT 
: MOUSEPOS.X MOUSEPOS @ ;
: MOUSEPOS.Y MOUSEPOS CELL+ @ ;
: RECT.LEFT    RECT ;
: RECT.TOP     RECT CELL+ ;
: RECT.RIGHT   RECT CELL+ CELL+ ;
: RECT.BOTTOM  RECT CELL+ CELL+ CELL+ ;

: MESSAGEHANDLER: ( cfa -name- )
  4 SWAP CALLBACK: 
;
VARIABLE uMsg VARIABLE wParam VARIABLE lParam

: GETMSGWLPARAM  ( hWnd uMsg wParam lParam -- ) 
  lParam ! wParam ! uMsg !
;

: GETMOUSEPOS  ( lParam -- )
  DUP $FFFF AND MOUSEPOS !
     $FFFF0000 AND $10 RSHIFT  MOUSEPOS CELL+ !
;

: FORMCLASSNAMEA Z" WF2" ;
CREATE FORMCLASSNAMEW CHAR W C, 0 C, CHAR F C, 0 C, CHAR 2 C, 0 ,

&WINAPI DefWindowProcA CONSTANT &DefWindowProcA

0 $7F00 LoadCursorA CONSTANT cursor
CREATE FORMCLASS 
       $30 ,                        \ cbSizex
       $3 ,                         \ style = CS_HREDRAW + CS_VREDRAW
       &DefWindowProcA ,
       0 ,                          \ cbClsExtra
       $100 ,                       \ cbWndExtra 
       HINST @ ,                    \ hInstance
       HINST @ $1F4 LoadIconA ,
       cursor ,
       $1 ,                        \ hbrBackground COLOR_WINDOW
       0 ,                          \ lpszMenuName
       FORMCLASSNAMEW ,
       HINST @ $1F4 LoadIconA ,

FORMCLASS RegisterClassExW DROP

: GetUserData ( hWnd -- value )  
  GWL_USERDATA GetWindowLongA
;

: SetUserData ( hWnd value -- oldvalue )  
  GWL_USERDATA SWAP SetWindowLongA
;



VARIABLE LASTLINK
VARIABLE NEXTWND
: >LINK ( hWnd -- value )             \ get link field
  GetUserData
;

: LINK> ( hWnd -- hLinkBY )           \ find the window link to hWnd 
  DUP >LINK                           ( hWnd NextWnd -- )
  BEGIN      
    DUP NEXTWND !                     \ save NextWnd
    DUP 0 = IF EXIT THEN              \ in case of invalid link field
    >LINK OVER =                      ( hWnd T/F ) \ compare hWnd with NextWnd-link
    IF DROP NEXTWND @ EXIT THEN       \ found the window link to this window
    NEXTWND @ >LINK
  AGAIN
;


: LINK ( hWnd newwnd -- oldwnd )      \ link hWnd with newwnd, return oldvalue
  SetUserData 
;

: INSERTTOLINK ( hwnd linkpointer -- )   \ insert current window into link list
  LASTLINK !

  LASTLINK @ @ 0 = IF
    DUP LASTLINK @ !              \ handle first edit window
    DUP LASTLINK @ @ LINK DROP
  THEN
  ( hwnd -- )
  DUP LASTLINK @ @ OVER           ( newwnd newwnd lasteditor newwnd )
  LINK                               ( newwnd newwnd oldlink ) \ link lasteditor to newwindow   
  LINK DROP                          \ link newwindow to lasteditor-link
  
  LASTLINK @ !                \ set lasteditor to newwnd
  
;

: REMOVEFROMLINK  ( hWnd -- )           \ remove from link list, linkby->linkto 
  DUP LINK>                           ( hWnd linkby -- )
  SWAP >LINK                          ( linkby linkto -- )
  LINK DROP
;

: GetProperty: CREATE , ,
  DOES> R@ @ @       \ window handle
        R> CELL+ @   \ value offset
        GetWindowLongA ;
  
: SetProperty: CREATE , ,
  DOES> R@ @ @       \ window handle
        R> CELL+ @   \ value offset 
        ROT          \ new value
        SetWindowLongA DROP ;
        