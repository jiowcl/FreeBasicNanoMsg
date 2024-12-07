'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' Declare Function
Declare Function NnErrno(Byval dllInstance As Any Ptr) As Long
Declare Function NnStrerror(Byval dllInstance As Any Ptr, Byval errnum As Integer) As Const ZString Ptr
Declare Function NnSymbol(Byval dllInstance As Any Ptr, Byval index As Integer, Byref value As Long) As Const ZString Ptr

' NanoMsg Function Declare

' <summary>
' NnErrno
' </summary>
' <param name="dllInstance"></param>
' <returns>Returns integer.</returns>
Function NnErrno(Byval dllInstance As Any Ptr) As Long
    Dim lResult As Long
    Dim pFuncCall As Function() As Long
  
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_errno")

        If (pFuncCall > 0) Then
            lResult = pFuncCall()
        End If
    End If
  
    Function = lResult
End Function

' <summary>
' NnStrerror
' </summary>
' <param name="dllInstance"></param>
' <param name="errnum"></param>
' <returns>Returns zstring ptr.</returns>
Function NnStrerror(Byval dllInstance As Any Ptr, Byval errnum As Integer) As Const ZString Ptr
    Dim lResult As Const ZString Ptr
    Dim pFuncCall As Function(Byval errnum As Integer) As ZString Ptr
  
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_strerror")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(errnum)
        End If
    End If
  
    Function = lResult
End Function

' <summary>
' NnSymbol
' </summary>
' <param name="dllInstance"></param>
' <param name="index"></param>
' <param name="value"></param>
' <returns>Returns zstring ptr.</returns>
Function NnSymbol(Byval dllInstance As Any Ptr, Byval index As Integer, Byref value As Long) As Const ZString Ptr
    Dim lResult As Const ZString Ptr
    Dim pFuncCall As Function(Byval index As Integer, Byref value As Long) As ZString Ptr
  
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_symbol")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(index, value)
        End If
    End If
  
    Function = lResult
End Function