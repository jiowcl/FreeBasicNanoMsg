'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../../Core/Enums.bi"
#Include "../../Core/NngWrapper.bi"

Dim lpszCurrentDir As String = Curdir()

' NNG version (x64)
Dim lpszLibNngDir As String = "/Library/x64"
Dim lpszLibNngDll As String = lpszCurrentDir & lpszLibNngDir & "/nng.dll"

Chdir(lpszCurrentDir & lpszLibNngDir)

Const lpszServerAddr As String = "tcp://0.0.0.0:1701"

Dim NngSocketRec As LibNngSocket

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim Socket As Long = NngSocketRec.PushOpen()
    Dim Rc As Long = NngSocketRec.Listen(Socket, lpszServerAddr)

    Print("Listen on address: " & lpszServerAddr)

    Dim lTotal As Long = 0

    While 1
        lTotal = lTotal + 1

        Dim lpszMessage As String = "Task #" & lTotal

        NngSocketRec.SendString(Socket, StrPtr(lpszMessage), Len(lpszMessage), 0)
        Print("Pushed: " & lpszMessage)

        Sleep(500)
    Wend

    NngSocketRec.Close(Socket)

    LibNngWrapper.DllClose()
End If
