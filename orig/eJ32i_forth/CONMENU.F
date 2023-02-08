0 USER32 WINAPI: CreateMenu
1 USER32 WINAPI: GetMenu
2 USER32 WINAPI: SetMenu
4 USER32 WINAPI: AppendMenuA
1 USER32 WINAPI: DrawMenuBar
$800 CONSTANT MF_SEPARATOR
0 CONSTANT MF_ENABLED

$102 CONSTANT Menu.openfile
$103 CONSTANT Menu.sp1
$104 CONSTANT Menu.exit
$201 CONSTANT Menu.Cut
$202 CONSTANT Menu.Copy
$203 CONSTANT Menu.Paste
$204 CONSTANT Menu.SelectAll

$301 CONSTANT Menu.Dump
$302 CONSTANT Menu.Stack
$303 CONSTANT Menu.See
$304 CONSTANT Menu.Words
$401 CONSTANT Menu.Manual
$402 CONSTANT Menu.About
LoadLibrary Shell32.dll CONSTANT SHELL32
4 SHELL32 WINAPI: ShellAboutA
\ 2 USER32 WINAPI: LoadIconA

VARIABLE hPopup
VARIABLE hMainMenu
 
: consolemenu
  CreateMenu hMainMenu !
  CreateMenu hPopup !
  
  hPopup @ MF_ENABLED   Menu.openfile z" &Open File" AppendMenuA DROP
  hPopup @ MF_SEPARATOR Menu.sp1      z" -" AppendMenuA DROP
  hPopup @ MF_ENABLED   Menu.exit     z" &Exit" AppendMenuA DROP
  hMainMenu @  $10 hPopup @ z" &File" AppendMenuA DROP
  
  CreateMenu hPopup !
  hPopup @ MF_ENABLED Menu.Copy       z" &Copy	Ctrl+C" AppendMenuA DROP
  hPopup @ MF_ENABLED Menu.SelectAll  z" &Select All" AppendMenuA DROP
  hMainMenu @  $10 hPopup @ z" &Edit" AppendMenuA DROP


  CreateMenu hPopup !
  hPopup @ MF_ENABLED Menu.Dump   z" &Dump" AppendMenuA DROP
  hPopup @ MF_ENABLED Menu.Stack  z" Stac&k" AppendMenuA DROP
  hPopup @ MF_ENABLED Menu.See    z" &See" AppendMenuA DROP
  hPopup @ MF_ENABLED Menu.Words  z" &Words" AppendMenuA DROP
  hMainMenu @  $10 hPopup @ z" &Tools" AppendMenuA DROP
  
  CreateMenu hPopup !
  hPopup @ MF_ENABLED   Menu.Manual z" &Manual" AppendMenuA DROP
  hPopup @ MF_SEPARATOR Menu.sp1    z" -" AppendMenuA DROP
  hPopup @ MF_ENABLED   Menu.About  z" &About" AppendMenuA DROP
  hMainMenu @  $10 hPopup @ z" &Help" AppendMenuA DROP
  
  hConsole @ hMainMenu @ SetMenu DROP
  hConsole @ DrawMenuBar DROP
  
;

: ProcessMenuCommand  ( menuid -- )

  DUP Menu.About = IF
    hConsole @ z" FSharp" z" Version 2.20" $400000 $1F4 LoadIconA ShellAboutA DROP
  THEN
  
  DUP Menu.Copy = IF
    CONSOLE.EDIT $301 0 0 SendMessageA DROP
  THEN
  
  DUP Menu.SelectAll = IF
    CONSOLE.EDIT $B1 0 -1 SendMessageA DROP
  THEN
  
  DUP Menu.openfile = IF
    $" EDIT" DROP 1- NAME? IF EXECUTE THEN
  THEN
  
  DUP Menu.Dump = IF
    $" newdumpview" DROP 1- NAME? IF EXECUTE THEN
  THEN
  DUP Menu.Stack = IF
    $" newstackview" DROP 1- NAME? IF EXECUTE THEN
  THEN
  
  DUP Menu.See = IF
    0 z" not yet implement" z" Error" 0 MessageBoxA DROP
  THEN

  DUP Menu.Words = IF
    0 z" not yet implement" z" Error" 0 MessageBoxA DROP
  THEN
    
  DUP Menu.Manual = IF
    $" readme.txt" DROP 1- $" EDITFILE" DROP 1- NAME? IF EXECUTE ELSE DROP THEN
  THEN    
  
  DUP Menu.exit = IF
    BYE
  THEN  
  
  DROP
;