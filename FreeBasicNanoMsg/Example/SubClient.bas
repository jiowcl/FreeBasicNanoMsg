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
    Dim Socket As Any Ptr = NnSocket(hLibrary, AF_SP, NN_SUB)
    Dim Rc As Long = NnConnect(hLibrary, Socket, lpszServerAddr)
    
    Dim lpszSubscribePtr As ZString Ptr
    Dim lpszSubscribe As String = "quotes"

    lpszSubscribePtr = CAllocate(Len(lpszSubscribe), SizeOfDefZStringPtr(lpszSubscribePtr))
    *lpszSubscribePtr = lpszSubscribe

    NnSetsockopt(hLibrary, Socket, NN_SUB, NN_SUB_SUBSCRIBE, lpszSubscribePtr, Len(lpszSubscribe))
    
    While 1
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(64)
        Dim lpszSendMessage As String

        NnRecv(hLibrary, Socket, lpszRecvBufferPtr, 64, 0)

        lpszSendMessage = *CPtr(ZString Ptr, lpszRecvBufferPtr)

        Print(lpszSendMessage)
        
        Deallocate(lpszRecvBufferPtr)

        lpszRecvBufferPtr = 0
        
        Sleep(2)
    Wend

    Deallocate(lpszSubscribePtr)

    lpszSubscribePtr = 0
    
    NnClose(hLibrary, Socket)
       
    NnDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()