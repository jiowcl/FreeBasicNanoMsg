'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

Declare Function NnSocket(Byval dllInstance As Any Ptr, Byval domain As Long, Byval protocol As Long) As Any Ptr
Declare Function NnClose(Byval dllInstance As Any Ptr, Byval socket As Any Ptr) As Long
Declare Function NnSetsockopt(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As UInteger) As Long
Declare Function NnGetsockopt(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval level As Long, Byval options As Long, Byref optval As String, Byval optvallen As UInteger) As Long
Declare Function NnBind(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval addr As Const ZString Ptr) As Long
Declare Function NnConnect(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval addr As Const ZString Ptr) As Long
Declare Function NnShutdown(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval how As Long) As Long
Declare Function NnSend(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval buf As Any Ptr, Byval buflen As UInteger, Byval flags As Long) As Long
Declare Function NnRecv(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval buf As Any Ptr, Byval buflen As UInteger, Byval flags As Long) As Long

' Nanomsg Function Declare

' <summary>
' NnSocket
' </summary>
' <param name="dllInstance"></param>
' <param name="domain"></param>
' <param name="protocol"></param>
' <returns>Returns any ptr.</returns>
Function NnSocket(Byval dllInstance As Any Ptr, Byval domain As Long, Byval protocol As Long) As Any Ptr
    Dim lResult As Any Ptr
    Dim pFuncCall As Function(Byval domain As Long, Byval protocol As Long) As Any Ptr
    
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
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <returns>Returns long.</returns>
Function NnClose(Byval dllInstance As Any Ptr, Byval socket As Any Ptr) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr) As Long
    
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
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <param name="level"></param>
' <param name="options"></param>
' <param name="optval"></param>
' <param name="optvallen"></param>
' <returns>Returns long.</returns>
Function NnSetsockopt(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As Uinteger) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As Uinteger) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_setsockopt")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, level, options, optval, optvallen)
        End If
    End If  
    
    Function = lResult
End Function

' <summary>
' NnGetsockopt
' </summary>
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <param name="level"></param>
' <param name="options"></param>
' <param name="optval"></param>
' <param name="optvallen"></param>
' <returns>Returns long.</returns>
Function NnGetsockopt(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval level As Long, Byval options As Long, Byref optval As String, Byval optvallen As Uinteger) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr, Byval level As Long, Byval options As Long, Byref optval As String, Byval optvallen As Uinteger) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_getsockopt")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, level, options, optval, optvallen)
        End If
    End If  
    
    Function = lResult
End Function

' <summary>
' NnBind
' </summary>
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <param name="addr"></param>
' <returns>Returns long.</returns>
Function NnBind(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval addr As Const ZString Ptr) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr, Byval addr As Const ZString Ptr) As Long
    
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
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <param name="addr"></param>
' <returns>Returns long.</returns>
Function NnConnect(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval addr As Const ZString Ptr) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr, Byval addr As Const ZString Ptr) As Long
    
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
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <param name="how"></param>
' <returns>Returns long.</returns>
Function NnShutdown(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval how As Long) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr, Byval how As Long) As Long
    
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
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <param name="buf"></param>
' <param name="buflen"></param>
' <param name="flags"></param>
' <returns>Returns long.</returns>
Function NnSend(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    
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
' <param name="dllInstance"></param>
' <param name="socket"></param>
' <param name="buf"></param>
' <param name="buflen"></param>
' <param name="flags"></param>
' <returns>Returns long.</returns>
Function NnRecv(Byval dllInstance As Any Ptr, Byval socket As Any Ptr, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    Dim lResult As Long
    Dim pFuncCall As Function(Byval socket As Any Ptr, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long
    
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_recv")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(socket, buf, buflen, flags)
        End If
    End If
    
    Function = lResult
End Function