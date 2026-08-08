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

Const lpszServerAddr As String = "tcp://localhost:1689"
Const RECV_BUFSIZE As Long = 256

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_SUB)
    Dim Rc As Long = NnSocketRec.Connect(Socket, lpszServerAddr)

    If Rc < 0 Then
        Print("Connect failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    Else
        Dim lpszSubscribe As String = "quotes"

        Rc = NnSocketRec.SetsockoptString(Socket, NN_SUB, NN_SUB_SUBSCRIBE, StrPtr(lpszSubscribe))

        If Rc < 0 Then
            Print("Subscribe failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        Else
            While 1
                Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
                Dim recvRc As Long = NnSocketRec.Recv(Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

                If recvRc >= 0 Then
                    Print(BytesToString(lpszRecvBufferPtr, recvRc))
                End If

                Deallocate(lpszRecvBufferPtr)
                lpszRecvBufferPtr = 0
            Wend
        End If
    End If
    
    NnSocketRec.Close(Socket)
    
    LibNanomsgWrapper.DllClose()
End If

Print("Press any key to continue...")
Sleep()
