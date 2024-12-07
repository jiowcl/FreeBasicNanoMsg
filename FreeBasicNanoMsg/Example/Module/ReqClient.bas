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

Const lpszServerAddr As String = "tcp://localhost:1700"

Dim NnSocketRec As LibNanomsgSocket

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Any Ptr = NnSocketRec.Socket(AF_SP, NN_REQ)
    Dim Rc As Long = NnSocketRec.Connect(Socket, lpszServerAddr)
    
    Print("Connect to Server: " & lpszServerAddr)
    
    Dim i As Integer
    
    For i = 0 To 10 
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendMessage As String = "From Client"

        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NnSocketRec.Send(Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        NnSocketRec.Recv(Socket, lpszRecvBufferPtr, 32, 0)
        
        Print("Reply From Server: ")
        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))
        
        Deallocate(lpszSendBufferPtr)
        Deallocate(lpszRecvBufferPtr) 

        lpszSendBufferPtr = 0
        lpszRecvBufferPtr = 0
    Next
    
    NnSocketRec.Close(Socket)
       
    LibNanomsgWrapper.DllClose()
End If

Print("Press any key to continue...")
Sleep()