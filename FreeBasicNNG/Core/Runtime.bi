'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' Declare Function
Declare Function NngInit(Byval dllInstance As Any Ptr) As Long
Declare Function NngFini(Byval dllInstance As Any Ptr) As Boolean
Declare Function NngStrerror(Byval dllInstance As Any Ptr, Byval errnum As Long) As Const ZString Ptr

' NNG Function Declare

' <summary>
' NngInit
' </summary>
' <param name="dllInstance">Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function NngInit(Byval dllInstance As Any Ptr) As Long
    Dim lResult As Long = NNG_EINVAL
    Dim pFuncCall As Function Cdecl(Byval params As Any Ptr) As Long
  
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_init")

        If (pFuncCall > 0) Then
            ' Pass NULL for default init parameters.
            lResult = pFuncCall(0)
        End If
    End If
  
    Function = lResult
End Function

' <summary>
' NngFini
' </summary>
' <param name="dllInstance">Ptr</param>
' <returns>Returns boolean.</returns>
Function NngFini(Byval dllInstance As Any Ptr) As Boolean
    Dim pFuncCall As Sub Cdecl()
  
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_fini")

        If (pFuncCall > 0) Then
            pFuncCall()
            Function = True
            Exit Function
        End If
    End If
  
    Function = False
End Function

' <summary>
' NngStrerror
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="errnum">Long</param>
' <returns>Returns zstring ptr.</returns>
Function NngStrerror(Byval dllInstance As Any Ptr, Byval errnum As Long) As Const ZString Ptr
    Dim lResult As Const ZString Ptr
    Dim pFuncCall As Function Cdecl(Byval errnum As Long) As ZString Ptr
  
    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nng_strerror")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(errnum)
        End If
    End If
  
    Function = lResult
End Function
