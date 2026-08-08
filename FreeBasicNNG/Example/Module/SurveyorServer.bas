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

Dim NngSocketRec As LibNngSocket
Dim NngRuntime As LibNngRuntime

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim Socket As Long = NngSocketRec.SurveyorOpen()
    Dim Rc As Long

    ' Wait up to 2000 ms for respondent replies after each survey.
    Rc = NngSocketRec.SetMs(Socket, NNG_OPT_SURVEYOR_SURVEYTIME, 2000)
    Rc = NngSocketRec.Listen(Socket, lpszServerAddr)

    Print("Listen on address: " & lpszServerAddr)

    Dim lTotal As Long = 0

    While 1
        lTotal = lTotal + 1

        Dim lpszSurvey As String = "Survey #" & lTotal

        NngSocketRec.SendString(Socket, StrPtr(lpszSurvey), Len(lpszSurvey), 0)
        Print("Survey sent: " & lpszSurvey)

        ' Collect responses until the survey deadline (NNG_ETIMEDOUT).
        While 1
            Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
            Dim recvRc As Long = NngSocketRec.Recv(Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

            If recvRc >= 0 Then
                Print("Response: " & BytesToString(lpszRecvBufferPtr, recvRc))
                Deallocate(lpszRecvBufferPtr)
            Else
                Dim errnum As Long = LibNngRuntime.LastError()

                If errnum = NNG_ETIMEDOUT Then
                    Print("Survey deadline reached (NNG_ETIMEDOUT).")
                ElseIf errnum = NNG_ESTATE Then
                    Print("No survey pending (NNG_ESTATE).")
                Else
                    Print("Recv error: " & *NngRuntime.Strerror(errnum))
                End If

                Deallocate(lpszRecvBufferPtr)
                Exit While
            End If
        Wend

        Sleep(1000)
    Wend

    NngSocketRec.Close(Socket)

    LibNngWrapper.DllClose()
End If
