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

Const lpszServerAddr As String = "tcp://*:1700"

Dim NnSocketRec As LibNanomsgSocket

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Any Ptr = NnSocketRec.Socket(AF_SP, NN_REP)
    Dim Rc As Long = NnSocketRec.Bind(Socket, lpszServerAddr)
    
    Print("Bind an IP address: " & lpszServerAddr)
    
    Dim lTotal As Integer = 0
    
    While 1
        lTotal = lTotal + 1
        
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszSendMessage As String = "Hi " & lTotal

        NnSocketRec.Recv(Socket, lpszRecvBufferPtr, 32, 0)
        
        Sleep(2)
        
        Print("Received: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))
        
        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NnSocketRec.Send(Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        
        Deallocate(lpszRecvBufferPtr) 
        Deallocate(lpszSendBufferPtr) 

        lpszRecvBufferPtr = 0
        lpszSendBufferPtr = 0
    Wend
    
    NnSocketRec.Close(Socket)
    
    LibNanomsgWrapper.DllClose()
End If