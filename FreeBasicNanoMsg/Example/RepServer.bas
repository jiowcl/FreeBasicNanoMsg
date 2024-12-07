'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nanomsg.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

Const lpszServerAddr As String = "tcp://*:1700"

Dim hLibrary As Any Ptr = NnDllOpen(lpszLibNnDll)

If hLibrary > 0 Then
    Dim Socket As Any Ptr = NnSocket(hLibrary, AF_SP, NN_REP)
    Dim Rc As Long = NnBind(hLibrary, Socket, lpszServerAddr)

    Print("Bind an IP address: " & lpszServerAddr)
    
    Dim lTotal As Integer = 0

    While 1
        lTotal = lTotal + 1

        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszSendMessage As String = "Hi " & lTotal

        NnRecv(hLibrary, Socket, lpszRecvBufferPtr, 32, 0)
        
        Sleep(2)
        
        Print("Received: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))
        
        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NnSend(hLibrary, Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        
        Deallocate(lpszRecvBufferPtr) 
        Deallocate(lpszSendBufferPtr) 

        lpszRecvBufferPtr = 0
        lpszSendBufferPtr = 0
    Wend

    NnClose(hLibrary, Socket)
    
    NnDllClose(hLibrary)
End If