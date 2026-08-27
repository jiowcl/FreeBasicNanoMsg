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

' inproc requires both endpoints in the same process.
Const lpszAddr As String = "inproc://fb-pair-smoke"

Dim NngSocketRec As LibNngSocket
Dim NngRuntime As LibNngRuntime

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim sockA As Long = NngSocketRec.PairOpen()
    Dim sockB As Long = NngSocketRec.PairOpen()
    Dim Rc As Long
    Dim ok As Integer = 1

    Rc = NngSocketRec.Listen(sockA, lpszAddr)
    Rc = NngSocketRec.Dial(sockB, lpszAddr)

    ' Give the inproc connection a moment to establish.
    Sleep(50)

    Dim lpszPing As String = "ping"
    Dim lpszPong As String = "pong"
    Dim buffer As Any Ptr = CAllocate(64)

    If NngSocketRec.SendString(sockA, StrPtr(lpszPing), Len(lpszPing), 0) <> NNG_OK Then
        Print("Send ping failed: " & *NngRuntime.Strerror(LibNngRuntime.LastError()))
        ok = 0
    End If

    If ok Then
        Dim recvRc As LongInt = NngSocketRec.Recv(sockB, buffer, 64, 0)

        If recvRc < 0 Then
            Print("Recv ping failed: " & *NngRuntime.Strerror(LibNngRuntime.LastError()))
            ok = 0
        Else
            Print("B received: " & BytesToString(buffer, recvRc))
        End If
    End If

    If ok Then
        If NngSocketRec.SendString(sockB, StrPtr(lpszPong), Len(lpszPong), 0) <> NNG_OK Then
            Print("Send pong failed: " & *NngRuntime.Strerror(LibNngRuntime.LastError()))
            ok = 0
        End If
    End If

    If ok Then
        Dim recvRc2 As LongInt = NngSocketRec.Recv(sockA, buffer, 64, 0)

        If recvRc2 < 0 Then
            Print("Recv pong failed: " & *NngRuntime.Strerror(LibNngRuntime.LastError()))
            ok = 0
        Else
            Print("A received: " & BytesToString(buffer, recvRc2))
        End If
    End If

    Deallocate(buffer)

    NngSocketRec.Close(sockA)
    NngSocketRec.Close(sockB)

    If ok Then
        Print("PAIR inproc smoke test OK.")
    Else
        Print("PAIR inproc smoke test FAILED.")
    End If

    LibNngWrapper.DllClose()
End If

Print("Press any key to continue...")
Sleep()
