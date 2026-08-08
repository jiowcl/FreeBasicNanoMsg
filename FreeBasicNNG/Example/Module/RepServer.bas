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

Const lpszServerAddr As String = "tcp://0.0.0.0:1700"

Dim NngSocketRec As LibNngSocket

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim Socket As Long = NngSocketRec.RepOpen()
    Dim Rc As Long = NngSocketRec.Listen(Socket, lpszServerAddr)

    Print("Listen on address: " & lpszServerAddr)

    Dim lTotal As Integer = 0

    While 1
        lTotal = lTotal + 1

        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszSendMessage As String = "Hi " & lTotal

        NngSocketRec.Recv(Socket, lpszRecvBufferPtr, 32, 0)

        Sleep(2)

        Print("Received: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))

        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NngSocketRec.Send(Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)

        Deallocate(lpszRecvBufferPtr)
        Deallocate(lpszSendBufferPtr)

        lpszRecvBufferPtr = 0
        lpszSendBufferPtr = 0
    Wend

    NngSocketRec.Close(Socket)

    LibNngWrapper.DllClose()
End If
