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

' Rnd with Range
' Source Code from: https://documentation.help/FreeBASIC/KeyPgRnd.html
Function RndRange(Byval first As Double, Byval last As Double) As Double
    Function = Rnd * (last - first) + first
End Function

Const lpszServerAddr As String = "tcp://*:1689"

Dim NnSocketRec As LibNanomsgSocket

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_PUB)
    Dim Rc As Long = NnSocketRec.Bind(Socket, lpszServerAddr)

    Print("Bind an IP address: " & lpszServerAddr)

    Randomize
    
    While 1
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszTopic As String = "quotes"
        Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(9000, 1000)) & ",Ask:" + Str(RndRange(9000, 1000))
       
        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NnSocketRec.Send(Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        Print("Published: " & lpszSendMessage)

        Deallocate(lpszSendBufferPtr)
        lpszSendBufferPtr = 0

        Sleep(500)
    Wend
    
    NnSocketRec.Close(Socket)
    
    LibNanomsgWrapper.DllClose()
End If
