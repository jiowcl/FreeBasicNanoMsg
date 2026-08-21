'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nanomsg.bi"

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

Dim hLibrary As Any Ptr = NnDllOpen(lpszLibNnDll)

If hLibrary = 0 Then
    Print("Failed to open nanomsg.dll: " & lpszLibNnDll)
    End 1
End If

Dim Socket As Long = NnSocket(hLibrary, AF_SP, NN_SURVEYOR)

If Socket < 0 Then
    Print("Socket failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    NnDllClose(hLibrary)
    End 1
End If

Dim Rc As Long

' Wait up to 2000 ms for respondent replies after each survey.
Rc = NnSetsockoptInt(hLibrary, Socket, NN_SURVEYOR, NN_SURVEYOR_DEADLINE, 2000)

If Rc < 0 Then
    Print("Setsockopt deadline failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    NnClose(hLibrary, Socket)
    NnDllClose(hLibrary)
    End 1
End If

Rc = NnBind(hLibrary, Socket, StrPtr(lpszServerAddr))

If Rc < 0 Then
    Print("Bind failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    NnClose(hLibrary, Socket)
    NnDllClose(hLibrary)
    End 1
End If

Print("Bind an IP address: " & lpszServerAddr)

Dim lTotal As Long = 0

While 1
    lTotal = lTotal + 1

    Dim lpszSurvey As String = "Survey #" & lTotal

    If NnSend(hLibrary, Socket, StrPtr(lpszSurvey), Len(lpszSurvey), 0) < 0 Then
        Print("Send failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    Else
        Print("Survey sent: " & lpszSurvey)

        ' Collect responses until the survey deadline (ETIMEDOUT).
        While 1
            Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
            Dim recvRc As Long = NnRecv(hLibrary, Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

            If recvRc >= 0 Then
                Print("Response: " & BytesToString(lpszRecvBufferPtr, recvRc))
                Deallocate(lpszRecvBufferPtr)
            Else
                Dim nnErr As Long = NnErrno(hLibrary)

                If nnErr = ETIMEDOUT Then
                    Print("Survey deadline reached (ETIMEDOUT).")
                ElseIf nnErr = EFSM Then
                    Print("No survey pending (EFSM).")
                Else
                    Print("Recv error: " & *NnStrerror(hLibrary, nnErr))
                End If

                Deallocate(lpszRecvBufferPtr)
                Exit While
            End If
        Wend
    End If

    Sleep(1000)
Wend

NnClose(hLibrary, Socket)
NnDllClose(hLibrary)
