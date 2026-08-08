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

' Rnd with Range (first = min, last = max)
' Source Code from: https://documentation.help/FreeBASIC/KeyPgRnd.html
Function RndRange(Byval first As Double, Byval last As Double) As Double
    Function = Rnd * (last - first) + first
End Function

Const lpszServerAddr As String = "tcp://*:1689"

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_PUB)
    Dim Rc As Long = NnSocketRec.Bind(Socket, lpszServerAddr)

    If Rc < 0 Then
        Print("Bind failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    Else
        Print("Bind an IP address: " & lpszServerAddr)

        Randomize
        
        While 1
            ' Prefix must match NN_SUB_SUBSCRIBE filter on the subscriber.
            Dim lpszTopic As String = "quotes"
            Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(1000, 9000)) & ",Ask:" & Str(RndRange(1000, 9000))

            Rc = NnSocketRec.Send(Socket, StrPtr(lpszSendMessage), Len(lpszSendMessage), 0)

            If Rc >= 0 Then
                Print("Published: " & lpszSendMessage)
            End If

            Sleep(500)
        Wend
    End If
    
    NnSocketRec.Close(Socket)
    
    LibNanomsgWrapper.DllClose()
End If
