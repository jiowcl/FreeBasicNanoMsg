'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nanomsg.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

Const lpszServerAddr As String = "tcp://localhost:1700"

Dim hLibrary As Any Ptr = NnDllOpen(lpszLibNnDll)

If hLibrary > 0 Then
    Dim Socket As Any Ptr = NnSocket(hLibrary, AF_SP, NN_REQ)
    Dim Rc As Long = NnConnect(hLibrary, Socket, lpszServerAddr)
    
    Print("Connect to Server: " & lpszServerAddr)
    
    Dim i As Integer
    
    For i = 0 To 10 
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendMessage As String = "From Client"

        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NnSend(hLibrary, Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        NnRecv(hLibrary, Socket, lpszRecvBufferPtr, 32, 0)
        
        Print("Reply From Server: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))
        
        Deallocate(lpszSendBufferPtr)
        Deallocate(lpszRecvBufferPtr) 

        lpszSendBufferPtr = 0
        lpszRecvBufferPtr = 0
    Next 
    
    NnClose(hLibrary, Socket)
       
    NnDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()