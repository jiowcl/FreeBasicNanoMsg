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

Const lpszServerAddr As String = "tcp://127.0.0.1:1700"
Const RECV_BUFSIZE As Long = 256

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim Socket As Long
    Dim Rc As Long = NngSub0Open(hLibrary, @Socket)

    If Rc <> NNG_OK Then
        Print("SubOpen failed: " & *NngStrerror(hLibrary, Rc))
    Else
        Rc = NngDial(hLibrary, Socket, lpszServerAddr)

        If Rc <> NNG_OK Then
            Print("Dial failed: " & *NngStrerror(hLibrary, Rc))
        Else
            Dim lpszSubscribe As String = "quotes"

            Rc = NngSub0Subscribe(hLibrary, Socket, StrPtr(lpszSubscribe))

            If Rc <> NNG_OK Then
                Print("Subscribe failed: " & *NngStrerror(hLibrary, Rc))
            Else
                While 1
                    Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
                    Dim recvRc As LongInt = NngRecvBuffer(hLibrary, Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

                    If recvRc >= 0 Then
                        Print(BytesToString(lpszRecvBufferPtr, recvRc))
                    End If

                    Deallocate(lpszRecvBufferPtr)
                    lpszRecvBufferPtr = 0
                Wend
            End If
        End If

        NngSocketClose(hLibrary, Socket)
    End If

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()
