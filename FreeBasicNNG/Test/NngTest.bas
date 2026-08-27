'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

' Deterministic, finite NNG tests. This file is intended for local checks and CI.
#Include "../Core/Nng.bi"

Const TEST_BUFFER_SIZE As Long = 256
Const SENTINEL_A As ULongInt = &h1122334455667788
Const SENTINEL_B As ULongInt = &h8877665544332211

Dim Shared gTestCount As Long
Dim Shared gFailureCount As Long

' <summary>
' Check
' </summary>
' <param name="condition">Integer</param>
' <param name="message">String</param>
Sub Check(Byval condition As Integer, Byval message As String)
    gTestCount = gTestCount + 1

    If condition Then
        Print("PASS: " & message)
    Else
        gFailureCount = gFailureCount + 1
        Print("FAIL: " & message)
    End If
End Sub

' <summary>
' ErrorText
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="errnum">Long</param>
' <returns>Returns string.</returns>
Function ErrorText(Byval dllInstance As Any Ptr, Byval errnum As Long) As String
    Dim errorPtr As Const ZString Ptr

    If (dllInstance > 0) Then
        errorPtr = NngStrerror(dllInstance, errnum)

        If (errorPtr <> 0) Then
            Function = *errorPtr
            Exit Function
        End If
    End If

    Function = Str(errnum)
End Function

' <summary>
' BufferToString
' nng_recv does not append a null terminator; copy by returned length.
' </summary>
' <param name="buf">Ptr</param>
' <param name="length">ULongInt</param>
' <returns>Returns string.</returns>
Function BufferToString(Byval buf As Any Ptr, Byval length As ULongInt) As String
    If (buf = 0) Or (length = 0) Then
        Function = ""
        Exit Function
    End If

    If (length > TEST_BUFFER_SIZE) Then
        Function = ""
        Exit Function
    End If

    Dim result As String = String(Cast(Long, length), 0)
    Dim src As UByte Ptr = Cast(UByte Ptr, buf)
    Dim dst As UByte Ptr = Cast(UByte Ptr, StrPtr(result))
    Dim i As Long

    For i = 0 To Cast(Long, length) - 1
        dst[i] = src[i]
    Next

    Function = result
End Function

' <summary>
' TestPair
' Tests protocol open, listen, dial, send, receive, timeout and size_t pointers.
' </summary>
' <param name="dllInstance">Ptr</param>
Sub TestPair(Byval dllInstance As Any Ptr)
    Const lpszAddr As String = "inproc://fb-nng-test-pair"

    Dim sockA As Long
    Dim sockB As Long
    Dim Rc As Long

    Rc = NngPair1Open(dllInstance, @sockA)
    Check(Rc = NNG_OK, "PAIR1 open socket A")

    Rc = NngPair1Open(dllInstance, @sockB)
    Check(Rc = NNG_OK, "PAIR1 open socket B")

    If (sockA = 0) Or (sockB = 0) Then
        If (sockA <> 0) Then NngSocketClose(dllInstance, sockA)
        If (sockB <> 0) Then NngSocketClose(dllInstance, sockB)
        Exit Sub
    End If

    Rc = NngSocketSetMs(dllInstance, sockA, NNG_OPT_RECVTIMEO, 100)
    Check(Rc = NNG_OK, "Set receive timeout")

    Dim timeoutValue As Long
    Rc = NngSocketGetMs(dllInstance, sockA, NNG_OPT_RECVTIMEO, @timeoutValue)
    Check((Rc = NNG_OK) And (timeoutValue = 100), "Get receive timeout")

    Dim expectedSize As ULongInt = 4096
    Rc = NngSocketSetSize(dllInstance, sockA, NNG_OPT_RECVMAXSZ, expectedSize)
    Check(Rc = NNG_OK, "Set 64-bit size option")

    Type SizeGuard
        value As ULongInt
        sentinel As ULongInt
    End Type

    Dim sizeGuard As SizeGuard
    sizeGuard.value = 0
    sizeGuard.sentinel = SENTINEL_A

    Rc = NngSocketGetSize(dllInstance, sockA, NNG_OPT_RECVMAXSZ, @sizeGuard.value)
    Check((Rc = NNG_OK) And (sizeGuard.value = expectedSize), "Get 64-bit size option")
    Check(sizeGuard.sentinel = SENTINEL_A, "Get size does not overwrite adjacent memory")

    Rc = NngListen(dllInstance, sockA, lpszAddr)
    Check(Rc = NNG_OK, "PAIR listen on inproc")

    Rc = NngDial(dllInstance, sockB, lpszAddr)
    Check(Rc = NNG_OK, "PAIR dial on inproc")

    Sleep(50)

    Dim buffer As Any Ptr = CAllocate(TEST_BUFFER_SIZE)
    Dim payload As String = "pair-payload"
    Dim sizeGuardRecv As SizeGuard
    Dim recvLength As ULongInt

    Rc = NngSend(dllInstance, sockA, StrPtr(payload), Len(payload), 0)
    Check(Rc = NNG_OK, "PAIR send")

    sizeGuardRecv.value = TEST_BUFFER_SIZE
    sizeGuardRecv.sentinel = SENTINEL_B
    Rc = NngRecv(dllInstance, sockB, buffer, @sizeGuardRecv.value, 0)
    recvLength = sizeGuardRecv.value
    Check(Rc = NNG_OK, "PAIR receive")
    Check(recvLength = Len(payload), "PAIR receive returns 64-bit size_t length")
    Check(BufferToString(buffer, recvLength) = payload, "PAIR payload matches")
    Check(sizeGuardRecv.sentinel = SENTINEL_B, "Receive size does not overwrite adjacent memory")

    payload = "pair-reply"
    Rc = NngSend(dllInstance, sockB, StrPtr(payload), Len(payload), 0)
    Check(Rc = NNG_OK, "PAIR reply send")

    recvLength = TEST_BUFFER_SIZE
    Rc = NngRecv(dllInstance, sockA, buffer, @recvLength, 0)
    Check(Rc = NNG_OK, "PAIR reply receive")
    Check(BufferToString(buffer, recvLength) = payload, "PAIR reply payload matches")

    recvLength = TEST_BUFFER_SIZE
    Rc = NngRecv(dllInstance, sockA, buffer, @recvLength, 0)
    Check(Rc = NNG_ETIMEDOUT, "PAIR receive timeout returns NNG_ETIMEDOUT")

    Deallocate(buffer)
    NngSocketClose(dllInstance, sockA)
    NngSocketClose(dllInstance, sockB)
End Sub

' <summary>
' TestReqRep
' Tests the request/reply protocol over inproc.
' </summary>
' <param name="dllInstance">Ptr</param>
Sub TestReqRep(Byval dllInstance As Any Ptr)
    Const lpszAddr As String = "inproc://fb-nng-test-reqrep"

    Dim reqSocket As Long
    Dim repSocket As Long
    Dim Rc As Long

    Rc = NngReq0Open(dllInstance, @reqSocket)
    Check(Rc = NNG_OK, "REQ0 open")

    Rc = NngRep0Open(dllInstance, @repSocket)
    Check(Rc = NNG_OK, "REP0 open")

    If (reqSocket = 0) Or (repSocket = 0) Then
        If (reqSocket <> 0) Then NngSocketClose(dllInstance, reqSocket)
        If (repSocket <> 0) Then NngSocketClose(dllInstance, repSocket)
        Exit Sub
    End If

    Rc = NngSocketSetMs(dllInstance, reqSocket, NNG_OPT_RECVTIMEO, 1000)
    Check(Rc = NNG_OK, "REQ set receive timeout")
    Rc = NngSocketSetMs(dllInstance, repSocket, NNG_OPT_RECVTIMEO, 1000)
    Check(Rc = NNG_OK, "REP set receive timeout")

    Rc = NngListen(dllInstance, repSocket, lpszAddr)
    Check(Rc = NNG_OK, "REP listen on inproc")
    Rc = NngDial(dllInstance, reqSocket, lpszAddr)
    Check(Rc = NNG_OK, "REQ dial on inproc")

    Sleep(50)

    Dim buffer As Any Ptr = CAllocate(TEST_BUFFER_SIZE)
    Dim request As String = "request"
    Dim reply As String = "reply"
    Dim recvLength As ULongInt = TEST_BUFFER_SIZE

    Rc = NngSend(dllInstance, reqSocket, StrPtr(request), Len(request), 0)
    Check(Rc = NNG_OK, "REQ send")

    Rc = NngRecv(dllInstance, repSocket, buffer, @recvLength, 0)
    Check((Rc = NNG_OK) And (BufferToString(buffer, recvLength) = request), "REP receive request")

    Rc = NngSend(dllInstance, repSocket, StrPtr(reply), Len(reply), 0)
    Check(Rc = NNG_OK, "REP send")

    recvLength = TEST_BUFFER_SIZE
    Rc = NngRecv(dllInstance, reqSocket, buffer, @recvLength, 0)
    Check((Rc = NNG_OK) And (BufferToString(buffer, recvLength) = reply), "REQ receive reply")

    Deallocate(buffer)
    NngSocketClose(dllInstance, reqSocket)
    NngSocketClose(dllInstance, repSocket)
End Sub

' <summary>
' TestPubSub
' Tests topic subscription and message delivery over inproc.
' </summary>
' <param name="dllInstance">Ptr</param>
Sub TestPubSub(Byval dllInstance As Any Ptr)
    Const lpszAddr As String = "inproc://fb-nng-test-pubsub"

    Dim pubSocket As Long
    Dim subSocket As Long
    Dim Rc As Long

    Rc = NngPub0Open(dllInstance, @pubSocket)
    Check(Rc = NNG_OK, "PUB0 open")
    Rc = NngSub0Open(dllInstance, @subSocket)
    Check(Rc = NNG_OK, "SUB0 open")

    If (pubSocket = 0) Or (subSocket = 0) Then
        If (pubSocket <> 0) Then NngSocketClose(dllInstance, pubSocket)
        If (subSocket <> 0) Then NngSocketClose(dllInstance, subSocket)
        Exit Sub
    End If

    Rc = NngSocketSetMs(dllInstance, subSocket, NNG_OPT_RECVTIMEO, 1000)
    Check(Rc = NNG_OK, "SUB set receive timeout")
    Rc = NngListen(dllInstance, pubSocket, lpszAddr)
    Check(Rc = NNG_OK, "PUB listen on inproc")
    Rc = NngDial(dllInstance, subSocket, lpszAddr)
    Check(Rc = NNG_OK, "SUB dial on inproc")

    Dim topic As String = "quotes"
    Rc = NngSub0Subscribe(dllInstance, subSocket, StrPtr(topic))
    Check(Rc = NNG_OK, "SUB subscribe")

    Sleep(100)

    Dim buffer As Any Ptr = CAllocate(TEST_BUFFER_SIZE)
    Dim payload As String = "quotes#test"
    Dim recvLength As ULongInt = TEST_BUFFER_SIZE
    Dim i As Long

    For i = 1 To 3
        Rc = NngSend(dllInstance, pubSocket, StrPtr(payload), Len(payload), 0)
        If Rc = NNG_OK Then Exit For
        Sleep(50)
    Next
    Check(Rc = NNG_OK, "PUB send subscribed message")

    Rc = NngRecv(dllInstance, subSocket, buffer, @recvLength, 0)
    Check((Rc = NNG_OK) And (BufferToString(buffer, recvLength) = payload), "SUB receive subscribed message")

    Rc = NngSub0Unsubscribe(dllInstance, subSocket, StrPtr(topic))
    Check(Rc = NNG_OK, "SUB unsubscribe")

    Deallocate(buffer)
    NngSocketClose(dllInstance, pubSocket)
    NngSocketClose(dllInstance, subSocket)
End Sub

Dim lpszCurrentDir As String = Curdir()
Dim lpszLibNngDir As String = "/Library/x64"
Dim lpszLibNngDll As String = lpszCurrentDir & lpszLibNngDir & "/nng.dll"

Chdir(lpszCurrentDir & lpszLibNngDir)

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary = 0) Then
    Print("FAIL: cannot load nng.dll")
    End 1
End If

Dim Rc As Long = NngInit(hLibrary)

If (Rc <> NNG_OK) Then
    Print("FAIL: nng_init: " & ErrorText(hLibrary, Rc))
    NngDllClose(hLibrary)
    End 1
End If

Print("NNG test suite started.")
TestPair(hLibrary)
TestReqRep(hLibrary)
TestPubSub(hLibrary)

NngFini(hLibrary)
NngDllClose(hLibrary)

Print("Tests: " & gTestCount & ", failures: " & gFailureCount)

If (gFailureCount = 0) Then
    Print("ALL TESTS PASSED")
    End 0
Else
    Print("TESTS FAILED")
    End 1
End If
