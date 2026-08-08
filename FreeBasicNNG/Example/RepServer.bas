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

Const lpszServerAddr As String = "tcp://0.0.0.0:1700"

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim Socket As Long
    Dim Rc As Long = NngRep0Open(hLibrary, @Socket)

    Rc = NngListen(hLibrary, Socket, lpszServerAddr)

    Print("Listen on address: " & lpszServerAddr)

    Dim lTotal As Integer = 0

    While 1
        lTotal = lTotal + 1

        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszSendMessage As String = "Hi " & lTotal
        Dim sz As UInteger = 32

        NngRecv(hLibrary, Socket, lpszRecvBufferPtr, @sz, 0)

        Sleep(2)

        Print("Received: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))

        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NngSend(hLibrary, Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)

        Deallocate(lpszRecvBufferPtr)
        Deallocate(lpszSendBufferPtr)

        lpszRecvBufferPtr = 0
        lpszSendBufferPtr = 0
    Wend

    NngSocketClose(hLibrary, Socket)

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If
