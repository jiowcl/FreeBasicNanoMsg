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

Const lpszServerAddr As String = "tcp://127.0.0.1:1701"
Const RECV_BUFSIZE As Long = 256

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim Socket As Long
    Dim Rc As Long = NngPull0Open(hLibrary, @Socket)

    Rc = NngDial(hLibrary, Socket, lpszServerAddr)

    Print("Dial Server: " & lpszServerAddr)

    ' Use recv timeout instead of nn_poll (nng has no nn_poll equivalent).
    NngSocketSetMs(hLibrary, Socket, NNG_OPT_RECVTIMEO, 1000)

    While 1
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
        Dim sz As ULongInt = RECV_BUFSIZE

        Rc = NngRecv(hLibrary, Socket, lpszRecvBufferPtr, @sz, 0)

        If Rc = NNG_OK Then
            Print("Pulled: " & BytesToString(lpszRecvBufferPtr, Cast(Long, sz)))
        ElseIf Rc <> NNG_ETIMEDOUT Then
            Print("Recv error: " & *NngStrerror(hLibrary, Rc))
        End If

        Deallocate(lpszRecvBufferPtr)
        lpszRecvBufferPtr = 0
    Wend

    NngSocketClose(hLibrary, Socket)

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()
