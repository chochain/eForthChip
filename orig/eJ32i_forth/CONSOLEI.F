( constant value and api prototype )

LoadLibrary kernel32.dll CONSTANT kernel32
LoadLibrary user32.dll CONSTANT user32
LoadLibrary gdi32.dll CONSTANT gdi32
LoadLibrary comdlg32.dll CONSTANT comdlg32

$-15      CONSTANT GWL_USERDATA
$-4       CONSTANT GWL_WNDPROC
$E        CONSTANT WM_GETTEXTLENGTH
$B1       CONSTANT EM_SETSEL
$C2       CONSTANT EM_REPLACESEL
$102      CONSTANT WM_CHAR
$111      CONSTANT WM_COMMAND
$286      CONSTANT WM_IME_CHAR
$30       CONSTANT WM_SETFONT
$31       CONSTANT WM_GETFONT
$10       CONSTANT SYSTEM_FIXED_FONT
$80000000 CONSTANT CW_USEDEFAULT
$5        CONSTANT WM_SIZE
$6        CONSTANT WM_ACTIVATE
$10       CONSTANT WM_CLOSE
$2        CONSTANT WM_DESTROY
$221      CONSTANT WM_MDIDESTROY
$400      CONSTANT WM_USER
$133 CONSTANT WM_CTLCOLOREDIT                 
WM_USER $4 + CONSTANT SB_SETPARTS
WM_USER $1 + CONSTANT SB_SETTEXT
WM_USER $10 + CONSTANT SB_SETTIPTEXTA
$C        CONSTANT WM_SETTEXT
$1        CONSTANT WM_CREATE
$800000   CONSTANT WS_BORDER
$40000000 CONSTANT WS_CHILD
$20000000 CONSTANT WS_MINIMIZE
$10000000 CONSTANT WS_VISIBLE
$200000   CONSTANT WS_VSCROLL
$4000     CONSTANT LBS_NOSEL
$180      CONSTANT LB_ADDSTRING
$184      CONSTANT LB_RESETCONTENT
$18B      CONSTANT LB_GETCOUNT
$186      CONSTANT LB_SETCURSEL
0         CONSTANT SW_HIDE
$5        CONSTANT SW_SHOW
$7        CONSTANT CF_OEMTEXT

$8000     CONSTANT MEM_RELEASE
$1000     CONSTANT MEM_COMMIT
$2000     CONSTANT MEM_RESERVE
$40       CONSTANT PAGE_EXECUTE_READWRITE

$C user32 WINAPI: CreateWindowExA
$C user32 WINAPI: CreateWindowExW
$A user32 WINAPI: CreateMDIWindowA
$A user32 WINAPI: CreateMDIWindowW
$1 user32 WINAPI: IsWindowUnicode
$4 user32 WINAPI: DefWindowProcA
$4 user32 WINAPI: DefWindowProcW
$2 user32 WINAPI: LoadIconA
$2 user32 WINAPI: LoadCursorA
$1 user32 WINAPI: RegisterClassExA
$1 user32 WINAPI: RegisterClassExW
$3 user32 WINAPI: SetWindowLongA
$3 user32 WINAPI: SetWindowLongW
$2 user32 WINAPI: GetWindowLongA
$2 user32 WINAPI: GetWindowLongW
$1 user32 WINAPI: DestroyWindow
$3 kernel32 WINAPI: GetModuleFileNameA
$2 kernel32 WINAPI: GetCurrentDirectoryA
$1 kernel32 WINAPI: SetCurrentDirectoryA
$1 kernel32 WINAPI: Sleep
$4 user32 WINAPI: GetMessageA
$1 user32 WINAPI: TranslateMessage
$1 user32 WINAPI: DispatchMessageA
$1 user32 WINAPI: DispatchMessageW
$5 user32 WINAPI: CallWindowProcA
$5 user32 WINAPI: CallWindowProcW
$1 gdi32 WINAPI: GetStockObject
$2 user32 WINAPI: SetWindowTextA
$2 user32 WINAPI: SetWindowTextW
$0 user32 WINAPI: WaitMessage
$5 user32 WINAPI: PeekMessageA
$4 user32 WINAPI: SendMessageA
$4 user32 WINAPI: SendMessageW
$4 user32 WINAPI: PostMessageA
$4 user32 WINAPI: PostMessageW
$1 user32 WINAPI: SetFocus
0  user32 WINAPI: GetFocus
$2 user32 WINAPI: GetClientRect
$6 user32 WINAPI: MoveWindow
1 user32 WINAPI: GetParent
4 user32 WINAPI: DefMDIChildProcA
4 user32 WINAPI: DefMDIChildProcW
$4 user32 WINAPI: MessageBoxA
0 kernel32 WINAPI: GetLastError
2 user32 WINAPI: ShowWindow
2 kernel32 WINAPI: Beep
1 user32 WINAPI: OpenClipboard
0 user32 WINAPI: CloseClipboard
1 user32 WINAPI: GetClipboardData
2 user32 WINAPI: GetDlgItem
1 kernel32 WINAPI: CloseHandle
6 kernel32 WINAPI: CreateThread
2 kernel32 WINAPI: SetThreadPriority
4 kernel32 WINAPI: VirtualAlloc
3 kernel32 WINAPI: VirtualFree
2 user32 WINAPI: TranslateMDISysAccel
\ $4 user32 WINAPI: SetLayeredWindowAttributes
$2 gdi32 WINAPI: SelectObject
$1 user32 WINAPI: GetDC 
$2 user32 WINAPI: ReleaseDC
2 user32 WINAPI: GetWindowRect
: BUTTONCLASS Z" BUTTON" ;
: EDITCLASS Z" EDIT" ;

$2 CONSTANT PM_NOYIELD
$0 CONSTANT PM_NOREMOVE