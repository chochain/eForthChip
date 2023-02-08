\ file I/O

7 kernel32 WINAPI: CreateFileA \ make CreateFileA as a FORTH word
\ CreateFileA ( lpFileName dwDesiredAccess dwShareMode lpSecurityAttributes
\               dwCreationDisposition dwFlagsAndAttributes hTemplateFile
\               -- ReturnValue )
\   The CreateFileA function creates or opens the following objects and
\   returns a handle that can be used to access the object: 
\     files, pipes, mailslots, consoles, communications resources,
\     disk devices (Windows NT only), and directories (open only) 
\ HANDLE CreateFile(
\   LPCTSTR lpFileName,          // pointer to name of the file
\   DWORD dwDesiredAccess,       // access (read-write) mode
\   DWORD dwShareMode,           // share mode
\   LPSECURITY_ATTRIBUTES lpSecurityAttributes,
\                                // pointer to security attributes
\   DWORD dwCreationDisposition, // how to create
\   DWORD dwFlagsAndAttributes,  // file attributes
\   HANDLE hTemplateFile         // handle to file with attributes to copy
\ );

: hOpen     ( zStrFileName -- handle true | false )
  $80000000 \ GENERIC_READ 
  1 0       \ FILE_SHARE_READ & non-inherited 
  3         \ OPEN_EXISTING
  $80       \ FILE_ATTRIBUTE_NORMAL 
  0         \ no_template 
  CreateFileA ;

: hCreate   ( zStrFileName -- handle true | false )
  $40000000 \ GENERIC_WRITE 
  0 0       \ non-share & non-inherited 
  2         \ CREATE_ALWAYS
  $80       \ FILE_ATTRIBUTE_NORMAL 
  0         \ no_template 
  CreateFileA ;

5 kernel32 WINAPI: WriteFile \ make WriteFile as a FORTH word
\ WriteFile ( hFile lpBuffer nNumberOfBytesToWrite lpNumberOfBytesWritten
\             lpOverlapped -- ReturnValue )
\   The WriteFile function writes data to a file and is designed for
\   both synchronous and asynchronous operation. The function starts
\   writing data to the file at the position indicated by the file
\   pointer. After the write operation has been completed, the file
\   pointer is adjusted by the number of bytes actually written, except
\   when the file is opened with FILE_FLAG_OVERLAPPED. If the file handle
\   was created for overlapped input and output (I/O), the application
\   must adjust the position of the file pointer after the write
\   operation is finished. 
\ BOOL WriteFile(
\   HANDLE hFile,                    // handle to file to write to
\   LPCVOID lpBuffer,                // pointer to data to write to file
\   DWORD nNumberOfBytesToWrite,     // number of bytes to write
\   LPDWORD lpNumberOfBytesWritten,  // pointer to number of bytes written
\   LPOVERLAPPED lpOverlapped        // pointer to structure for overlapped I/O
\ );

  VARIABLE #ByteWritten ( -- #Byte )

: hWrite   ( handle buffer Length -- true | false )
  #ByteWritten 0 WriteFile ;

5 kernel32 WINAPI: ReadFile \ make ReadFile as a FORTH word
\ ReadFile ( hFile lpBuffer nNumberOfBytesToRead lpNumberOfBytesRead
\            lpOverlapped -- ReturnValue )
\   The ReadFile function reads data from a file, starting at the
\   position indicated by the file pointer. After the read operation
\   has been completed, the file pointer is adjusted by the number of
\   bytes actually read, unless the file handle is created with the
\   overlapped attribute. If the file handle is created for overlapped
\   input and output (I/O), the application must adjust the position
\   of the file pointer after the read operation. 
\ BOOL ReadFile(
\   HANDLE hFile,                // handle of file to read
\   LPVOID lpBuffer,             // pointer to buffer that receives data
\   DWORD nNumberOfBytesToRead,  // number of bytes to read
\   LPDWORD lpNumberOfBytesRead, // pointer to number of bytes read
\   LPOVERLAPPED lpOverlapped    // pointer to structure for data
\ );

  VARIABLE #ByteRead ( -- #Byte )

: hRead     ( handle buffer maxLength -- true | false )
  #ByteRead 0 ReadFile ;
  
' CLoseHandle ALIAS hClose ( handle -- true | false )
