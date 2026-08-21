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

' nn_recv does not append a null terminator; copy by returned length.
Function BytesToString(Byval buf As Any Ptr, Byval length As Long) As String
    If (buf = 0) Or (length <= 0) Then
        Function = ""
        Exit Function
    End If

    Dim result As String = String(length, 0)
    Dim src As UByte Ptr = Cast(UByte Ptr, buf)
    Dim dst As UByte Ptr = Cast(UByte Ptr, StrPtr(result))
    Dim i As Long

    For i = 0 To length - 1
        dst[i] = src[i]
    Next

    Function = result
End Function

Const lpszAddr As String = "inproc://fb-pair-smoke"

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) = 0 Then
    Print("Failed to open nanomsg.dll: " & lpszLibNnDll)
    End 1
End If

Dim sockA As Long = NnSocketRec.Socket(AF_SP, NN_PAIR)
Dim sockB As Long = NnSocketRec.Socket(AF_SP, NN_PAIR)
Dim Rc As Long
Dim ok As Integer = 1
Dim recvRc As Long

If (sockA < 0) Or (sockB < 0) Then
    Print("Socket failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    ok = 0
End If

If ok Then
    Rc = NnSocketRec.Bind(sockA, StrPtr(lpszAddr))
    If Rc < 0 Then
        Print("Bind failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        ok = 0
    End If
End If

If ok Then
    Rc = NnSocketRec.Connect(sockB, StrPtr(lpszAddr))
    If Rc < 0 Then
        Print("Connect failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        ok = 0
    End If
End If

Sleep(50)

Dim lpszPing As String = "ping"
Dim lpszPong As String = "pong"
Dim buffer As Any Ptr = CAllocate(64)

If ok Then
    If NnSocketRec.Send(sockA, StrPtr(lpszPing), Len(lpszPing), 0) < 0 Then
        Print("Send ping failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        ok = 0
    End If
End If

If ok Then
    recvRc = NnSocketRec.Recv(sockB, buffer, 64, 0)
    If recvRc < 0 Then
        Print("Recv ping failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        ok = 0
    Else
        Print("B received: " & BytesToString(buffer, recvRc))
    End If
End If

If ok Then
    If NnSocketRec.Send(sockB, StrPtr(lpszPong), Len(lpszPong), 0) < 0 Then
        Print("Send pong failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        ok = 0
    End If
End If

If ok Then
    recvRc = NnSocketRec.Recv(sockA, buffer, 64, 0)
    If recvRc < 0 Then
        Print("Recv pong failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        ok = 0
    Else
        Print("A received: " & BytesToString(buffer, recvRc))
    End If
End If

Deallocate(buffer)

If sockA >= 0 Then NnSocketRec.Close(sockA)
If sockB >= 0 Then NnSocketRec.Close(sockB)

If ok Then
    Print("PAIR inproc smoke test OK.")
Else
    Print("PAIR inproc smoke test FAILED.")
End If

Print("Press any key to continue...")
Sleep()

LibNanomsgWrapper.DllClose()

If ok = 0 Then End 1
