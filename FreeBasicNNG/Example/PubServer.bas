'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nng.bi"

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

Const lpszServerAddr As String = "tcp://0.0.0.0:1700"

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim Socket As Long
    Dim Rc As Long = NngPub0Open(hLibrary, @Socket)

    If Rc <> NNG_OK Then
        Print("PubOpen failed: " & *NngStrerror(hLibrary, Rc))
    Else
        Rc = NngListen(hLibrary, Socket, lpszServerAddr)

        If Rc <> NNG_OK Then
            Print("Listen failed: " & *NngStrerror(hLibrary, Rc))
        Else
            Print("Listen on address: " & lpszServerAddr)

            Randomize

            While 1
                ' Prefix must match Subscribe filter on the subscriber.
                Dim lpszTopic As String = "quotes"
                Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(1000, 9000)) & ",Ask:" & Str(RndRange(1000, 9000))

                Rc = NngSend(hLibrary, Socket, StrPtr(lpszSendMessage), Len(lpszSendMessage), 0)

                If Rc = NNG_OK Then
                    Print("Published: " & lpszSendMessage)
                End If

                Sleep(500)
            Wend
        End If

        NngSocketClose(hLibrary, Socket)
    End If

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If
