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

' nn_recv does not append a null terminator; copy by returned length.
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

Const lpszServerAddr As String = "tcp://*:1702"
Const RECV_BUFSIZE As Long = 256

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) = 0 Then
    Print("Failed to open nanomsg.dll: " & lpszLibNnDll)
    End 1
End If

Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_SURVEYOR)

If Socket < 0 Then
    Print("Socket failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    LibNanomsgWrapper.DllClose()
    End 1
End If

Dim Rc As Long

' Wait up to 2000 ms for respondent replies after each survey.
Rc = NnSocketRec.SetsockoptInt(Socket, NN_SURVEYOR, NN_SURVEYOR_DEADLINE, 2000)

If Rc < 0 Then
    Print("Setsockopt deadline failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    NnSocketRec.Close(Socket)
    LibNanomsgWrapper.DllClose()
    End 1
End If

Rc = NnSocketRec.Bind(Socket, StrPtr(lpszServerAddr))

If Rc < 0 Then
    Print("Bind failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    NnSocketRec.Close(Socket)
    LibNanomsgWrapper.DllClose()
    End 1
End If

Print("Bind an IP address: " & lpszServerAddr)

Dim lTotal As Long = 0

While 1
    lTotal = lTotal + 1

    Dim lpszSurvey As String = "Survey #" & lTotal

    If NnSocketRec.Send(Socket, StrPtr(lpszSurvey), Len(lpszSurvey), 0) < 0 Then
        Print("Send failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    Else
        Print("Survey sent: " & lpszSurvey)

        While 1
            Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
            Dim recvRc As Long = NnSocketRec.Recv(Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

            If recvRc >= 0 Then
                Print("Response: " & BytesToString(lpszRecvBufferPtr, recvRc))
                Deallocate(lpszRecvBufferPtr)
            Else
                Dim nnErr As Long = NnRuntime.Errno()

                If nnErr = ETIMEDOUT Then
                    Print("Survey deadline reached (ETIMEDOUT).")
                ElseIf nnErr = EFSM Then
                    Print("No survey pending (EFSM).")
                Else
                    Print("Recv error: " & *NnRuntime.Strerror(nnErr))
                End If

                Deallocate(lpszRecvBufferPtr)
                Exit While
            End If
        Wend
    End If

    Sleep(1000)
Wend

NnSocketRec.Close(Socket)
LibNanomsgWrapper.DllClose()
