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
    Dim Socket As Long = NnSocket(hLibrary, AF_SP, NN_PUB)
    Dim Rc As Long = NnBind(hLibrary, Socket, lpszServerAddr)
    
    Print("Bind an IP address: " & lpszServerAddr)

    Randomize
    
    While 1
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszTopic As String = "quotes"
        Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(9000, 1000)) & ",Ask:" + Str(RndRange(9000, 1000))

        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NnSend(hLibrary, Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        Print("Published: " & lpszSendMessage)

        Deallocate(lpszSendBufferPtr)
        lpszSendBufferPtr = 0

        Sleep(500)
    Wend
    
    NnClose(hLibrary, Socket)
    
    NnDllClose(hLibrary)
End If
