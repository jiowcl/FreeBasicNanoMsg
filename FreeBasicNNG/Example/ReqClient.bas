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

Const lpszServerAddr As String = "tcp://127.0.0.1:1700"

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim Socket As Long
    Dim Rc As Long = NngReq0Open(hLibrary, @Socket)

    Rc = NngDial(hLibrary, Socket, lpszServerAddr)

    Print("Dial Server: " & lpszServerAddr)

    Dim i As Integer

    For i = 0 To 10
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendMessage As String = "From Client"
        Dim sz As ULongInt = 32

        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NngSend(hLibrary, Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        NngRecv(hLibrary, Socket, lpszRecvBufferPtr, @sz, 0)

        Print("Reply From Server: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))

        Deallocate(lpszSendBufferPtr)
        Deallocate(lpszRecvBufferPtr)

        lpszSendBufferPtr = 0
        lpszRecvBufferPtr = 0
    Next

    NngSocketClose(hLibrary, Socket)

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()
