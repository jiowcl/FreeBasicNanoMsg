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

Const lpszServerAddr As String = "tcp://localhost:1700"
Const RECV_BUFSIZE As Long = 256

Dim hLibrary As Any Ptr = NnDllOpen(lpszLibNnDll)

If hLibrary > 0 Then
    Dim Socket As Long = NnSocket(hLibrary, AF_SP, NN_SUB)
    Dim Rc As Long = NnConnect(hLibrary, Socket, lpszServerAddr)

    If Rc < 0 Then
        Print("Connect failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
    Else
        Dim lpszSubscribe As String = "quotes"

        Rc = NnSetsockoptString(hLibrary, Socket, NN_SUB, NN_SUB_SUBSCRIBE, StrPtr(lpszSubscribe))

        If Rc < 0 Then
            Print("Subscribe failed: " & *NnStrerror(hLibrary, NnErrno(hLibrary)))
        Else
            While 1
                Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
                Dim recvRc As Long = NnRecv(hLibrary, Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

                If recvRc >= 0 Then
                    Print(BytesToString(lpszRecvBufferPtr, recvRc))
                End If

                Deallocate(lpszRecvBufferPtr)
                lpszRecvBufferPtr = 0
            Wend
        End If
    End If
    
    NnClose(hLibrary, Socket)
       
    NnDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()
