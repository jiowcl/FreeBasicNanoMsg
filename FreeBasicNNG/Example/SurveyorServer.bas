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

' nng_recv does not append a null terminator; copy by returned length.
Function BytesToString(Byval buf As Any Ptr, Byval length As Long) As String
    If (buf = 0) Or (length <= 0) Then
        Function = ""
        Exit Function
    End If

    Dim result As String = String(length, 0)
    Dim src As UByte Ptr = Cast(UByte Ptr, buf)
    Dim dst As UByte Ptr = Cast(UByte Ptr, StrPtr(result))
    Dim i As Long

    For i = 0 To length - 1
        dst[i] = src[i]
    Next

    Function = result
End Function

Const lpszServerAddr As String = "tcp://0.0.0.0:1702"
Const RECV_BUFSIZE As Long = 256

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim Socket As Long
    Dim Rc As Long = NngSurveyor0Open(hLibrary, @Socket)

    ' Wait up to 2000 ms for respondent replies after each survey.
    Rc = NngSocketSetMs(hLibrary, Socket, NNG_OPT_SURVEYOR_SURVEYTIME, 2000)
    Rc = NngListen(hLibrary, Socket, lpszServerAddr)

    Print("Listen on address: " & lpszServerAddr)

    Dim lTotal As Long = 0

    While 1
        lTotal = lTotal + 1

        Dim lpszSurvey As String = "Survey #" & lTotal

        NngSend(hLibrary, Socket, StrPtr(lpszSurvey), Len(lpszSurvey), 0)
        Print("Survey sent: " & lpszSurvey)

        ' Collect responses until the survey deadline (NNG_ETIMEDOUT).
        While 1
            Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
            Dim sz As UInteger = RECV_BUFSIZE

            Rc = NngRecv(hLibrary, Socket, lpszRecvBufferPtr, @sz, 0)

            If Rc = NNG_OK Then
                Print("Response: " & BytesToString(lpszRecvBufferPtr, Cast(Long, sz)))
                Deallocate(lpszRecvBufferPtr)
            Else
                If Rc = NNG_ETIMEDOUT Then
                    Print("Survey deadline reached (NNG_ETIMEDOUT).")
                ElseIf Rc = NNG_ESTATE Then
                    Print("No survey pending (NNG_ESTATE).")
                Else
                    Print("Recv error: " & *NngStrerror(hLibrary, Rc))
                End If

                Deallocate(lpszRecvBufferPtr)
                Exit While
            End If
        Wend

        Sleep(1000)
    Wend

    NngSocketClose(hLibrary, Socket)

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If
