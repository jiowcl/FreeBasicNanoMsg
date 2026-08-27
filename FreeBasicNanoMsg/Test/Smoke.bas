'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'
'  Non-interactive smoke test for CI (no Sleep / key wait).
'  Run with working directory = FreeBasicNanoMsg package root (contains Library/).
'--------------------------------------------------------------------------------------------

#Include "../Core/Nanomsg.bi"
#Include "../Core/NanomsgWrapper.bi"

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

Dim pkgRoot As String = Curdir()
Dim lpszDll As String = pkgRoot & "/Library/x64/nanomsg.dll"

Print("Smoke: dll=" & lpszDll)

Dim h As Any Ptr = NnDllOpen(lpszDll)
If h = 0 Then
    Print("FAIL: DllOpen")
    End 1
End If

' --- symbols ---
Dim symbolCount As Long = 0
Dim nnSymbolIndex As Integer = 0
Dim nnSymbolValue As Long

While 1
    Dim nnSymbolBufferPtr As Const ZString Ptr = NnSymbol(h, nnSymbolIndex, nnSymbolValue)
    If nnSymbolBufferPtr = 0 Then Exit While

    Dim nnSymbolName As String = *CPtr(ZString Ptr, nnSymbolBufferPtr)
    If Len(nnSymbolName) = 0 Then Exit While

    symbolCount += 1
    nnSymbolIndex += 1
Wend

If symbolCount < 10 Then
    Print("FAIL: too few symbols (" & symbolCount & ")")
    NnDllClose(h)
    End 1
End If
Print("OK: symbols=" & symbolCount)

' --- message zero-copy helpers ---
Dim msg As Any Ptr = NnAllocmsg(h, 32, 0)
If msg = 0 Then
    Print("FAIL: Allocmsg")
    NnDllClose(h)
    End 1
End If
*CPtr(ZString Ptr, msg) = "ci-msg"
msg = NnReallocmsg(h, msg, 64)
If msg = 0 Then
    Print("FAIL: Reallocmsg")
    NnDllClose(h)
    End 1
End If
If NnFreemsg(h, msg) <> 0 Then
    Print("FAIL: Freemsg")
    NnDllClose(h)
    End 1
End If
Print("OK: Message API")

' --- PAIR inproc + poll + statistic ---
Dim s1 As Long = NnSocket(h, AF_SP, NN_PAIR)
Dim s2 As Long = NnSocket(h, AF_SP, NN_PAIR)
If (s1 < 0) Or (s2 < 0) Then
    Print("FAIL: Socket")
    NnDllClose(h)
    End 1
End If

Dim addr As String = "inproc://fb-ci-smoke"
If NnBind(h, s1, StrPtr(addr)) < 0 Then
    Print("FAIL: Bind " & *NnStrerror(h, NnErrno(h)))
    End 1
End If
If NnConnect(h, s2, StrPtr(addr)) < 0 Then
    Print("FAIL: Connect " & *NnStrerror(h, NnErrno(h)))
    End 1
End If

Sleep(50)

Dim ping As String = "ping"
If NnSend(h, s2, StrPtr(ping), Len(ping), 0) < 0 Then
    Print("FAIL: Send")
    End 1
End If

Dim pfd As NnPollFd
pfd.fd = s1
pfd.events = NN_POLLIN
pfd.revents = 0

Dim pollRc As Long = NnPoll(h, @pfd, 1, 1000)
If (pollRc < 1) Or ((pfd.revents And NN_POLLIN) = 0) Then
    Print("FAIL: Poll rc=" & pollRc & " revents=" & pfd.revents)
    End 1
End If

Dim buf As Any Ptr = CAllocate(64)
Dim recvRc As Long = NnRecv(h, s1, buf, 64, 0)
If (recvRc < 0) Or (BytesToString(buf, recvRc) <> "ping") Then
    Print("FAIL: Recv")
    End 1
End If
Deallocate(buf)

Dim sent As ULongInt = NnGetStatistic(h, s2, NN_STAT_MESSAGES_SENT)
If sent < 1 Then
    Print("FAIL: GetStatistic MESSAGES_SENT=" & Str(sent))
    End 1
End If
Print("OK: PAIR/Poll/Statistic")

NnClose(h, s1)
NnClose(h, s2)

If NnTerm(h) = 0 Then
    Print("FAIL: Term")
    End 1
End If
Print("OK: Term")
NnDllClose(h)

' --- wrapper facade ---
If LibNanomsgWrapper.DllOpen(lpszDll) = 0 Then
    Print("FAIL: Wrapper DllOpen")
    End 1
End If

Dim NnMsg As LibNanomsgMessage
Dim NnSock As LibNanomsgSocket
Dim NnRt As LibNanomsgRuntime

Dim m2 As Any Ptr = NnMsg.Allocmsg(16)
If m2 = 0 Then
    Print("FAIL: Wrapper Allocmsg")
    End 1
End If
If NnMsg.Freemsg(m2) <> 0 Then
    Print("FAIL: Wrapper Freemsg")
    End 1
End If

Dim ws As Long = NnSock.Socket(AF_SP, NN_PAIR)
If ws < 0 Then
    Print("FAIL: Wrapper Socket")
    End 1
End If
NnSock.Close(ws)

If NnRt.Term() = 0 Then
    Print("FAIL: Wrapper Term")
    End 1
End If
LibNanomsgWrapper.DllClose()
Print("OK: Wrapper")

Print("Smoke test PASSED")
End 0
