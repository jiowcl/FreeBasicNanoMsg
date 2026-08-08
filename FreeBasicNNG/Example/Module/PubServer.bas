'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../../Core/Enums.bi"
#Include "../../Core/NngWrapper.bi"

Dim lpszCurrentDir As String = Curdir()

' NNG version (x64)
Dim lpszLibNngDir As String = "/Library/x64"
Dim lpszLibNngDll As String = lpszCurrentDir & lpszLibNngDir & "/nng.dll"

Chdir(lpszCurrentDir & lpszLibNngDir)

' Rnd with Range (first = min, last = max)
' Source Code from: https://documentation.help/FreeBASIC/KeyPgRnd.html
Function RndRange(Byval first As Double, Byval last As Double) As Double
    Function = Rnd * (last - first) + first
End Function

Const lpszServerAddr As String = "tcp://0.0.0.0:1689"

Dim NngSocketRec As LibNngSocket
Dim NngRuntime As LibNngRuntime

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim Socket As Long = NngSocketRec.PubOpen()
    Dim Rc As Long = NngSocketRec.Listen(Socket, lpszServerAddr)

    If Rc <> NNG_OK Then
        Print("Listen failed: " & *NngRuntime.Strerror(Rc))
    Else
        Print("Listen on address: " & lpszServerAddr)

        Randomize

        While 1
            ' Prefix must match Subscribe filter on the subscriber.
            Dim lpszTopic As String = "quotes"
            Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(1000, 9000)) & ",Ask:" & Str(RndRange(1000, 9000))

            Rc = NngSocketRec.Send(Socket, StrPtr(lpszSendMessage), Len(lpszSendMessage), 0)

            If Rc = NNG_OK Then
                Print("Published: " & lpszSendMessage)
            End If

            Sleep(500)
        Wend
    End If

    NngSocketRec.Close(Socket)

    LibNngWrapper.DllClose()
End If
