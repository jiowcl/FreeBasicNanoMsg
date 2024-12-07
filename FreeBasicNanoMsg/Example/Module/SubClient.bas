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

Const lpszServerAddr As String = "tcp://localhost:1689"

Dim NnSocketRec As LibNanomsgSocket

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Any Ptr = NnSocketRec.Socket(AF_SP, NN_SUB)
    Dim Rc As Long = NnSocketRec.Connect(Socket, lpszServerAddr)
    
    Dim lpszSubscribePtr As ZString Ptr
    Dim lpszSubscribe As String = "quotes"

    lpszSubscribePtr = CAllocate(Len(lpszSubscribe), SizeOfDefZStringPtr(lpszSubscribePtr))
    *lpszSubscribePtr = lpszSubscribe

    NnSocketRec.Setsockopt(Socket, NN_SUB, NN_SUB_SUBSCRIBE, lpszSubscribePtr, Len(lpszSubscribe))
    
    While 1
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(64)

        NnSocketRec.Recv(Socket, lpszRecvBufferPtr, 64, 0)

        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))
        
        Deallocate(lpszRecvBufferPtr)

        lpszRecvBufferPtr = 0
        
        Sleep(2)
    Wend

    Deallocate(lpszSubscribePtr)

    lpszSubscribePtr = 0
    
    NnSocketRec.Close(Socket)
    
    LibNanomsgWrapper.DllClose()
End If

Print("Press any key to continue...")
Sleep()