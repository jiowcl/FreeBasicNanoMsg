'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' nng_socket / nng_dialer / nng_listener are single uint32_t wrappers;
' Win64 passes them by value as a 32-bit integer (Long / ULong).

Declare Function NngOpenByName(Byval dllInstance As Any Ptr, Byval lpszFuncName As String, Byval sock As Long Ptr) As Long
Declare Function NngPub0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngSub0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngReq0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngRep0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngPush0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngPull0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngPair1Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngPair0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngSurveyor0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngRespondent0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngBus0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
Declare Function NngSocketClose(Byval dllInstance As Any Ptr, Byval sock As Long) As Long
Declare Function NngListen(Byval dllInstance As Any Ptr, Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
Declare Function NngDial(Byval dllInstance As Any Ptr, Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
Declare Function NngSend(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Any Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
Declare Function NngSendString(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Const ZString Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
Declare Function NngRecv(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Any Ptr, Byval sz As ULongInt Ptr, Byval flags As Long) As Long
Declare Function NngRecvBuffer(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Any Ptr, Byval buflen As ULongInt, Byval flags As Long) As LongInt
Declare Function NngSocketSetMs(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
Declare Function NngSocketGetMs(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
Declare Function NngSocketSetInt(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
Declare Function NngSocketGetInt(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
Declare Function NngSocketSetSize(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt) As Long
Declare Function NngSocketGetSize(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt Ptr) As Long
Declare Function NngSub0Subscribe(Byval dllInstance As Any Ptr, Byval sock As Long, Byval topic As Const ZString Ptr) As Long
Declare Function NngSub0Unsubscribe(Byval dllInstance As Any Ptr, Byval sock As Long, Byval topic As Const ZString Ptr) As Long
Declare Function NngSocketGetRecvPollFd(Byval dllInstance As Any Ptr, Byval sock As Long, Byval fdp As Long Ptr) As Long
Declare Function NngSocketGetSendPollFd(Byval dllInstance As Any Ptr, Byval sock As Long, Byval fdp As Long Ptr) As Long

' NNG Function Declare

' <summary>
' NngOpenByName
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="lpszFuncName">String</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngOpenByName(Byval dllInstance As Any Ptr, Byval lpszFuncName As String, Byval sock As Long Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, lpszFuncName)

        If (pFuncCall > 0) Then
            *sock = 0
            lResult = pFuncCall(sock)
        End If
    End If
      
    Function = lResult
End Function

' <summary>
' NngPub0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngPub0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_pub0_open", sock)
End Function

' <summary>
' NngSub0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSub0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_sub0_open", sock)
End Function

' <summary>
' NngReq0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngReq0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_req0_open", sock)
End Function

' <summary>
' NngRep0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngRep0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_rep0_open", sock)
End Function

' <summary>
' NngPush0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngPush0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_push0_open", sock)
End Function

' <summary>
' NngPull0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngPull0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_pull0_open", sock)
End Function

' <summary>
' NngPair1Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngPair1Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_pair1_open", sock)
End Function

' <summary>
' NngPair0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngPair0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_pair0_open", sock)
End Function

' <summary>
' NngSurveyor0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSurveyor0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_surveyor0_open", sock)
End Function

' <summary>
' NngRespondent0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngRespondent0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_respondent0_open", sock)
End Function

' <summary>
' NngBus0Open
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngBus0Open(Byval dllInstance As Any Ptr, Byval sock As Long Ptr) As Long
    Function = NngOpenByName(dllInstance, "nng_bus0_open", sock)
End Function

' <summary>
' NngSocketClose
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketClose(Byval dllInstance As Any Ptr, Byval sock As Long) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_close")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngListen
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="addr">Const ZString Ptr</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function NngListen(Byval dllInstance As Any Ptr, Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval addr As Const ZString Ptr, Byval listener As Any Ptr, Byval flags As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_listen")

        If (pFuncCall > 0) Then
            ' Pass NULL listener when the caller does not need the endpoint handle.
            lResult = pFuncCall(sock, addr, 0, flags)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngDial
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="addr">Const ZString Ptr</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function NngDial(Byval dllInstance As Any Ptr, Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval addr As Const ZString Ptr, Byval dialer As Any Ptr, Byval flags As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_dial")

        If (pFuncCall > 0) Then
            ' Pass NULL dialer when the caller does not need the endpoint handle.
            lResult = pFuncCall(sock, addr, 0, flags)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSend
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="buf">Ptr</param>
' <param name="leng">ULongInt</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function NngSend(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Any Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval buf As Any Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_send")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, buf, leng, flags)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSendString
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="buf">Const ZString Ptr</param>
' <param name="leng">ULongInt</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function NngSendString(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Const ZString Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
    Function = NngSend(dllInstance, sock, Cast(Any Ptr, buf), leng, flags)
End Function

' <summary>
' NngRecv
' Matches C: int nng_recv(nng_socket s, void *buf, size_t *sz, int flags)
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="buf">Ptr</param>
' <param name="sz">ULongInt Ptr (in/out size)</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function NngRecv(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Any Ptr, Byval sz As ULongInt Ptr, Byval flags As Long) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval buf As Any Ptr, Byval sz As ULongInt Ptr, Byval flags As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_recv")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, buf, sz, flags)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngRecvBuffer
' Convenience helper: returns received byte count on success, or -1 on failure.
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="buf">Ptr</param>
' <param name="buflen">ULongInt</param>
' <param name="flags">Long</param>
' <returns>Returns long.</returns>
Function NngRecvBuffer(Byval dllInstance As Any Ptr, Byval sock As Long, Byval buf As Any Ptr, Byval buflen As ULongInt, Byval flags As Long) As LongInt
    Dim sz As ULongInt = buflen
    Dim lResult As Long = NngRecv(dllInstance, sock, buf, @sz, flags)

    If (lResult = NNG_OK) Then
        Function = Cast(LongInt, sz)
        Exit Function
    End If

    Function = -1
End Function

' <summary>
' NngSocketSetMs
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long (milliseconds)</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketSetMs(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_set_ms")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, opt, optval)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSocketGetMs
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketGetMs(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_get_ms")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, opt, optval)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSocketSetInt
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketSetInt(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_set_int")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, opt, optval)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSocketGetInt
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketGetInt(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_get_int")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, opt, optval)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSocketSetSize
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">ULongInt</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketSetSize(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_set_size")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, opt, optval)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSocketGetSize
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">ULongInt Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketGetSize(Byval dllInstance As Any Ptr, Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_get_size")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, opt, optval)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSub0Subscribe
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="topic">Const ZString Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSub0Subscribe(Byval dllInstance As Any Ptr, Byval sock As Long, Byval topic As Const ZString Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval buf As Any Ptr, Byval sz As ULongInt) As Long
    Dim topicLen As ULongInt = 0

    If (topic <> 0) Then
        topicLen = Len(*topic)
    End If
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_sub0_socket_subscribe")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, Cast(Any Ptr, topic), topicLen)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSub0Unsubscribe
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="topic">Const ZString Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSub0Unsubscribe(Byval dllInstance As Any Ptr, Byval sock As Long, Byval topic As Const ZString Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval buf As Any Ptr, Byval sz As ULongInt) As Long
    Dim topicLen As ULongInt = 0

    If (topic <> 0) Then
        topicLen = Len(*topic)
    End If
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_sub0_socket_unsubscribe")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, Cast(Any Ptr, topic), topicLen)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSocketGetRecvPollFd
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="fdp">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketGetRecvPollFd(Byval dllInstance As Any Ptr, Byval sock As Long, Byval fdp As Long Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval fdp As Long Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_get_recv_poll_fd")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, fdp)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NngSocketGetSendPollFd
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="sock">Long</param>
' <param name="fdp">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngSocketGetSendPollFd(Byval dllInstance As Any Ptr, Byval sock As Long, Byval fdp As Long Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval sock As Long, Byval fdp As Long Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_socket_get_send_poll_fd")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(sock, fdp)
        End If
    End If
    
    Function = lResult
End Function
