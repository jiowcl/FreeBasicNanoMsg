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

Const lpszServerAddr As String = "tcp://localhost:1701"
Const RECV_BUFSIZE As Long = 256

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) = 0 Then
    Print("Failed to open nanomsg.dll: " & lpszLibNnDll)
    End 1
End If

Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_PULL)

If Socket < 0 Then
    Print("Socket failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    LibNanomsgWrapper.DllClose()
    End 1
End If

Dim Rc As Long = NnSocketRec.Connect(Socket, StrPtr(lpszServerAddr))

If Rc < 0 Then
    Print("Connect failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    NnSocketRec.Close(Socket)
    LibNanomsgWrapper.DllClose()
    End 1
End If

Print("Connect to Server: " & lpszServerAddr)

Dim pfd As NnPollFd

While 1
    pfd.fd = Socket
    pfd.events = NN_POLLIN
    pfd.revents = 0

    Rc = NnSocketRec.Poll(@pfd, 1, 1000)

    If Rc < 0 Then
        Print("Poll failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    ElseIf (Rc > 0) And ((pfd.revents And NN_POLLIN) <> 0) Then
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
        Dim recvRc As Long = NnSocketRec.Recv(Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

        If recvRc >= 0 Then
            Print("Pulled: " & BytesToString(lpszRecvBufferPtr, recvRc))
        Else
            Print("Recv failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        End If

        Deallocate(lpszRecvBufferPtr)
    End If
Wend

NnSocketRec.Close(Socket)
Print("Press any key to continue...")
Sleep()
LibNanomsgWrapper.DllClose()
