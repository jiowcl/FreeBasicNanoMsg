'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

Declare Function NnSocket(Byval dllInstance As Any Ptr, Byval domain As Long, Byval protocol As Long) As Long
Declare Function NnClose(Byval dllInstance As Any Ptr, Byval socket As Long) As Long
Declare Function NnSetsockopt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As UInteger) As Long
Declare Function NnSetsockoptString(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Const ZString Ptr) As Long
Declare Function NnSetsockoptInt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Long) As Long
Declare Function NnGetsockopt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As UInteger Ptr) As Long
Declare Function NnGetsockoptInt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byref optval As Long) As Long
Declare Function NnBind(Byval dllInstance As Any Ptr, Byval socket As Long, Byval addr As Const ZString Ptr) As Long
Declare Function NnConnect(Byval dllInstance As Any Ptr, Byval socket As Long, Byval addr As Const ZString Ptr) As Long
Declare Function NnShutdown(Byval dllInstance As Any Ptr, Byval socket As Long, Byval how As Long) As Long
Declare Function NnSend(Byval dllInstance As Any Ptr, Byval socket As Long, Byval buf As Any Ptr, Byval buflen As UInteger, Byval flags As Long) As Long
Declare Function NnRecv(Byval dllInstance As Any Ptr, Byval socket As Long, Byval buf As Any Ptr, Byval buflen As UInteger, Byval flags As Long) As Long
Declare Function NnPoll(Byval dllInstance As Any Ptr, Byval fds As Any Ptr, Byval nfds As Long, Byval timeout As Long) As Long
Declare Function NnGetStatistic(Byval dllInstance As Any Ptr, Byval socket As Long, Byval stat As Long) As ULongInt

' Nanomsg Function Declare

' <summary>
' NnSocket
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="domain">Long</param>
' <param name="protocol">Long</param>
' <returns>Returns socket handle (Long), or -1 on error.</returns>
Function NnSocket(Byval dllInstance As Any Ptr, Byval domain As Long, Byval protocol As Long) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval domain As Long, Byval protocol As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_socket")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(domain, protocol)
        End If
    End If
      
    Function = lResult
End Function

' <summary>
' NnClose
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <returns>Returns long.</returns>
Function NnClose(Byval dllInstance As Any Ptr, Byval socket As Long) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_close")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NnSetsockopt
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="level">Long</param>
' <param name="options">Long</param>
' <param name="optval">Ptr</param>
' <param name="optvallen">Uinteger</param>
' <returns>Returns long.</returns>
Function NnSetsockopt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As Uinteger) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As Uinteger) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_setsockopt")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, level, options, optval, optvallen)
        End If
    End If  
    
    Function = lResult
End Function

' <summary>
' NnSetsockoptString
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="level">Long</param>
' <param name="options">Long</param>
' <param name="optval">Const ZString Ptr</param>
' <returns>Returns long.</returns>
Function NnSetsockoptString(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Const ZString Ptr) As Long
    Dim optvallen As UInteger = 0

    If (optval <> 0) Then
        optvallen = Len(*optval)
    End If

    Function = NnSetsockopt(dllInstance, socket, level, options, Cast(Any Ptr, optval), optvallen)
End Function

' <summary>
' NnSetsockoptInt
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="level">Long</param>
' <param name="options">Long</param>
' <param name="optval">Long</param>
' <returns>Returns long.</returns>
Function NnSetsockoptInt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Long) As Long
    Dim value As Long = optval

    Function = NnSetsockopt(dllInstance, socket, level, options, @value, SizeOf(Long))
End Function

' <summary>
' NnGetsockopt
' Matches C: int nn_getsockopt(int s, int level, int option, void *optval, size_t *optvallen)
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="level">Long</param>
' <param name="options">Long</param>
' <param name="optval">Ptr</param>
' <param name="optvallen">UInteger Ptr (in/out length)</param>
' <returns>Returns long.</returns>
Function NnGetsockopt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As UInteger Ptr) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As UInteger Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_getsockopt")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, level, options, optval, optvallen)
        End If
    End If  
    
    Function = lResult
End Function

' <summary>
' NnGetsockoptInt
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="level">Long</param>
' <param name="options">Long</param>
' <param name="optval">Long (byref)</param>
' <returns>Returns long.</returns>
Function NnGetsockoptInt(Byval dllInstance As Any Ptr, Byval socket As Long, Byval level As Long, Byval options As Long, Byref optval As Long) As Long
    Dim optvallen As UInteger = SizeOf(Long)

    Function = NnGetsockopt(dllInstance, socket, level, options, @optval, @optvallen)
End Function

' <summary>
' NnBind
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="addr">ZString Ptr</param>
' <returns>Returns long.</returns>
Function NnBind(Byval dllInstance As Any Ptr, Byval socket As Long, Byval addr As Const ZString Ptr) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval addr As Const ZString Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_bind")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, addr)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NnConnect
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="addr">Const ZString Ptr</param>
' <returns>Returns long.</returns>
Function NnConnect(Byval dllInstance As Any Ptr, Byval socket As Long, Byval addr As Const ZString Ptr) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval addr As Const ZString Ptr) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_connect")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, addr)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NnShutdown
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="how">Long</param>
' <returns>Returns long.</returns>
Function NnShutdown(Byval dllInstance As Any Ptr, Byval socket As Long, Byval how As Long) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval how As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_shutdown")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, how)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NnSend
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="buf">Ptr</param>
' <param name="buflen">Uinteger</param>
' <param name="flags">Long</param>
' <returns>Returns long.</returns>
Function NnSend(Byval dllInstance As Any Ptr, Byval socket As Long, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_send")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, buf, buflen, flags)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NnRecv
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="buf">Ptr</param>
' <param name="buflen">Uinteger</param>
' <param name="flags">Long</param>
' <returns>Returns long.</returns>
Function NnRecv(Byval dllInstance As Any Ptr, Byval socket As Long, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_recv")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, buf, buflen, flags)
        End If
    End If
    
    Function = lResult
End Function

' <summary>
' NnPoll
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="fds">NnPollFd Ptr (or array)</param>
' <param name="nfds">Long</param>
' <param name="timeout">Long (ms; -1 = forever)</param>
' <returns>Returns count of ready fds, 0 on timeout, or -1 on error.</returns>
Function NnPoll(Byval dllInstance As Any Ptr, Byval fds As Any Ptr, Byval nfds As Long, Byval timeout As Long) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval fds As Any Ptr, Byval nfds As Long, Byval timeout As Long) As Long

    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_poll")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(fds, nfds, timeout)
        End If
    End If

    Function = lResult
End Function

' <summary>
' NnGetStatistic
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="socket">Long</param>
' <param name="stat">Long (NN_STAT_*)</param>
' <returns>Returns ULongInt statistic value.</returns>
Function NnGetStatistic(Byval dllInstance As Any Ptr, Byval socket As Long, Byval stat As Long) As ULongInt
    Dim lResult As ULongInt = 0
    Dim pFuncCall As Function Cdecl(Byval socket As Long, Byval stat As Long) As ULongInt

    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_get_statistic")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, stat)
        End If
    End If

    Function = lResult
End Function
