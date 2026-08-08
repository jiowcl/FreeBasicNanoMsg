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

' inproc requires both endpoints in the same process.
Const lpszAddr As String = "inproc://fb-pair-smoke"

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Dim sockA As Long
    Dim sockB As Long
    Dim Rc As Long
    Dim ok As Integer = 1

    Rc = NngPair1Open(hLibrary, @sockA)
    Rc = NngPair1Open(hLibrary, @sockB)

    Rc = NngListen(hLibrary, sockA, lpszAddr)
    Rc = NngDial(hLibrary, sockB, lpszAddr)

    ' Give the inproc connection a moment to establish.
    Sleep(50)

    Dim lpszPing As String = "ping"
    Dim lpszPong As String = "pong"
    Dim buffer As Any Ptr = CAllocate(64)
    Dim sz As UInteger

    If NngSend(hLibrary, sockA, StrPtr(lpszPing), Len(lpszPing), 0) <> NNG_OK Then
        Print("Send ping failed: " & *NngStrerror(hLibrary, Rc))
        ok = 0
    End If

    If ok Then
        sz = 64
        Rc = NngRecv(hLibrary, sockB, buffer, @sz, 0)

        If Rc <> NNG_OK Then
            Print("Recv ping failed: " & *NngStrerror(hLibrary, Rc))
            ok = 0
        Else
            Print("B received: " & BytesToString(buffer, Cast(Long, sz)))
        End If
    End If

    If ok Then
        If NngSend(hLibrary, sockB, StrPtr(lpszPong), Len(lpszPong), 0) <> NNG_OK Then
            Print("Send pong failed.")
            ok = 0
        End If
    End If

    If ok Then
        sz = 64
        Rc = NngRecv(hLibrary, sockA, buffer, @sz, 0)

        If Rc <> NNG_OK Then
            Print("Recv pong failed: " & *NngStrerror(hLibrary, Rc))
            ok = 0
        Else
            Print("A received: " & BytesToString(buffer, Cast(Long, sz)))
        End If
    End If

    Deallocate(buffer)

    NngSocketClose(hLibrary, sockA)
    NngSocketClose(hLibrary, sockB)

    If ok Then
        Print("PAIR inproc smoke test OK.")
    Else
        Print("PAIR inproc smoke test FAILED.")
    End If

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()
