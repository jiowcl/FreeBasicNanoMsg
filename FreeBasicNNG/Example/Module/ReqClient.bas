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

Const lpszServerAddr As String = "tcp://127.0.0.1:1700"

Dim NngSocketRec As LibNngSocket

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim Socket As Long = NngSocketRec.ReqOpen()
    Dim Rc As Long = NngSocketRec.Dial(Socket, lpszServerAddr)

    Print("Dial Server: " & lpszServerAddr)

    Dim i As Integer

    For i = 0 To 10
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendMessage As String = "From Client"

        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NngSocketRec.Send(Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        NngSocketRec.Recv(Socket, lpszRecvBufferPtr, 32, 0)

        Print("Reply From Server: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))

        Deallocate(lpszSendBufferPtr)
        Deallocate(lpszRecvBufferPtr)

        lpszSendBufferPtr = 0
        lpszRecvBufferPtr = 0
    Next

    NngSocketRec.Close(Socket)

    LibNngWrapper.DllClose()
End If

Print("Press any key to continue...")
Sleep()
