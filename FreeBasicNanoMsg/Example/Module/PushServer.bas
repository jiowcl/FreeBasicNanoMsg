'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../../Core/Enums.bi"
#Include "../../Core/NanomsgWrapper.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

Chdir(lpszCurrentDir & lpszLibNnDir)

Const lpszServerAddr As String = "tcp://*:1701"

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) = 0 Then
    Print("Failed to open nanomsg.dll: " & lpszLibNnDll)
    End 1
End If

Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_PUSH)

If Socket < 0 Then
    Print("Socket failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    LibNanomsgWrapper.DllClose()
    End 1
End If

Dim Rc As Long = NnSocketRec.Bind(Socket, StrPtr(lpszServerAddr))

If Rc < 0 Then
    Print("Bind failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    NnSocketRec.Close(Socket)
    LibNanomsgWrapper.DllClose()
    End 1
End If

Print("Bind an IP address: " & lpszServerAddr)

Dim lTotal As Long = 0

While 1
    lTotal = lTotal + 1

    Dim lpszMessage As String = "Task #" & lTotal

    If NnSocketRec.Send(Socket, StrPtr(lpszMessage), Len(lpszMessage), 0) < 0 Then
        Print("Send failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    Else
        Print("Pushed: " & lpszMessage)
    End If

    Sleep(500)
Wend

NnSocketRec.Close(Socket)
LibNanomsgWrapper.DllClose()
