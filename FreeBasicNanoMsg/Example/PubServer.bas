'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nanomsg.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

' Rnd with Range
' Source Code from: https://documentation.help/FreeBASIC/KeyPgRnd.html
Function RndRange(Byval first As Double, Byval last As Double) As Double
    Function = Rnd * (last - first) + first
End Function

Const lpszServerAddr As String = "tcp://*:1700"

Dim hLibrary As Any Ptr = NnDllOpen(lpszLibNnDll)

If hLibrary > 0 Then
    Dim Socket As Any Ptr = NnSocket(hLibrary, AF_SP, NN_PUB)
    Dim Rc As Long = NnBind(hLibrary, Socket, lpszServerAddr)
    
    Print("Bind an IP address: " & lpszServerAddr)

    Randomize
    
    While 1
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(32)
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszTopic As String = "quotes"
        Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(9000, 1000)) & ",Ask:" + Str(RndRange(9000, 1000))

        NnRecv(hLibrary, Socket, lpszRecvBufferPtr, 32, 0)
        
        Sleep(2)
        
        Dim lpszReturnMessage As String = *CPtr(ZString Ptr, lpszRecvBufferPtr)
        
        If lpszReturnMessage <> "" Then
            Print("Received: ")
            Print(lpszReturnMessage)
        End If

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