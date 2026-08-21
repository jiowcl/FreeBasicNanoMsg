'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' Declare Function
Declare Function NnErrno(Byval dllInstance As Any Ptr) As Long
Declare Function NnStrerror(Byval dllInstance As Any Ptr, Byval errnum As Integer) As Const ZString Ptr
Declare Function NnSymbol(Byval dllInstance As Any Ptr, Byval index As Integer, Byref value As Long) As Const ZString Ptr
Declare Function NnTerm(Byval dllInstance As Any Ptr) As Boolean

' NanoMsg Function Declare

' <summary>
' NnErrno
' </summary>
' <param name="dllInstance">Ptr</param>
' <returns>Returns integer.</returns>
Function NnErrno(Byval dllInstance As Any Ptr) As Long
    Dim lResult As Long
    Dim pFuncCall As Function Cdecl() As Long
  
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
' <param name="dllInstance">Ptr</param>
' <param name="errnum">Integer</param>
' <returns>Returns zstring ptr.</returns>
Function NnStrerror(Byval dllInstance As Any Ptr, Byval errnum As Integer) As Const ZString Ptr
    Dim lResult As Const ZString Ptr
    Dim pFuncCall As Function Cdecl(Byval errnum As Integer) As ZString Ptr
  
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
' <param name="dllInstance">Ptr</param>
' <param name="index">Integer</param>
' <param name="value">Long</param>
' <returns>Returns zstring ptr.</returns>
Function NnSymbol(Byval dllInstance As Any Ptr, Byval index As Integer, Byref value As Long) As Const ZString Ptr
    Dim lResult As Const ZString Ptr
    Dim pFuncCall As Function Cdecl(Byval index As Integer, Byval value As Long Ptr) As ZString Ptr
  
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_symbol")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(index, @value)
        End If
    End If
  
    Function = lResult
End Function

' <summary>
' NnTerm
' Helper for shutting down multi-threaded applications.
' </summary>
' <param name="dllInstance">Ptr</param>
' <returns>Returns true if nn_term was called.</returns>
Function NnTerm(Byval dllInstance As Any Ptr) As Boolean
    Dim pFuncCall As Sub Cdecl()

    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_term")

        If (pFuncCall > 0) Then
            pFuncCall()
            Function = True
            Exit Function
        End If
    End If

    Function = False
End Function
