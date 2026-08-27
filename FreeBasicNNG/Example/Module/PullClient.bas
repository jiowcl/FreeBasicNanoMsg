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

' nng_recv does not append a null terminator; copy by returned length.
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

Const lpszServerAddr As String = "tcp://127.0.0.1:1701"
Const RECV_BUFSIZE As Long = 256

Dim NngSocketRec As LibNngSocket
Dim NngRuntime As LibNngRuntime

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim Socket As Long = NngSocketRec.PullOpen()
    Dim Rc As Long = NngSocketRec.Dial(Socket, lpszServerAddr)

    Print("Dial Server: " & lpszServerAddr)

    ' Use recv timeout instead of nn_poll (nng has no nn_poll equivalent).
    NngSocketRec.SetMs(Socket, NNG_OPT_RECVTIMEO, 1000)

    While 1
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
        Dim recvRc As LongInt = NngSocketRec.Recv(Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

        If recvRc >= 0 Then
            Print("Pulled: " & BytesToString(lpszRecvBufferPtr, recvRc))
        ElseIf LibNngRuntime.LastError() <> NNG_ETIMEDOUT Then
            Print("Recv error: " & *NngRuntime.Strerror(LibNngRuntime.LastError()))
        End If

        Deallocate(lpszRecvBufferPtr)
        lpszRecvBufferPtr = 0
    Wend

    NngSocketRec.Close(Socket)

    LibNngWrapper.DllClose()
End If

Print("Press any key to continue...")
Sleep()
