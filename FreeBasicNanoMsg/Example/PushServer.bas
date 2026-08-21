'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nanomsg.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

Chdir(lpszCurrentDir & lpszLibNnDir)

Const lpszServerAddr As String = "tcp://*:1701"

Dim hLibrary As Any Ptr = NnDllOpen(lpszLibNnDll)

If hLibrary = 0 Then
    Print("Failed to open nanomsg.dll: " & lpszLibNnDll)
    End 1
End If

Dim Socket As Long = NnSocket(hLibrary, AF_SP, NN_PUSH)

If Socket < 0 Then
    Print("Socket failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    NnDllClose(hLibrary)
    End 1
End If

Dim Rc As Long = NnBind(hLibrary, Socket, StrPtr(lpszServerAddr))

If Rc < 0 Then
    Print("Bind failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    NnClose(hLibrary, Socket)
    NnDllClose(hLibrary)
    End 1
End If

Print("Bind an IP address: " & lpszServerAddr)

Dim lTotal As Long = 0

While 1
    lTotal = lTotal + 1

    Dim lpszMessage As String = "Task #" & lTotal

    If NnSend(hLibrary, Socket, StrPtr(lpszMessage), Len(lpszMessage), 0) < 0 Then
        Print("Send failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    Else
        Print("Pushed: " & lpszMessage)
    End If

    Sleep(500)
Wend

NnClose(hLibrary, Socket)
NnDllClose(hLibrary)
