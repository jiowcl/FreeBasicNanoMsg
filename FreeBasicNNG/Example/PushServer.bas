'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nng.bi"

Dim lpszCurrentDir As String = Curdir()

' NNG version (x64)
Dim lpszLibNngDir As String = "/Library/x64"
Dim lpszLibNngDll As String = lpszCurrentDir & lpszLibNngDir & "/nng.dll"

Chdir(lpszCurrentDir & lpszLibNngDir)

Const lpszServerAddr As String = "tcp://0.0.0.0:1701"

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim Socket As Long
    Dim Rc As Long = NngPush0Open(hLibrary, @Socket)

    Rc = NngListen(hLibrary, Socket, lpszServerAddr)

    Print("Listen on address: " & lpszServerAddr)

    Dim lTotal As Long = 0

    While 1
        lTotal = lTotal + 1

        Dim lpszMessage As String = "Task #" & lTotal

        NngSend(hLibrary, Socket, StrPtr(lpszMessage), Len(lpszMessage), 0)
        Print("Pushed: " & lpszMessage)

        Sleep(500)
    Wend

    NngSocketClose(hLibrary, Socket)

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If
