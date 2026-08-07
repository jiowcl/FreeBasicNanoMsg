'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

Declare Function NnAllocmsg(Byval dllInstance As Any Ptr, Byval size As UInteger, Byval type_ As Long = 0) As Any Ptr
Declare Function NnReallocmsg(Byval dllInstance As Any Ptr, Byval msg As Any Ptr, Byval size As UInteger) As Any Ptr
Declare Function NnFreemsg(Byval dllInstance As Any Ptr, Byval msg As Any Ptr) As Long

' Nanomsg Function Declare

' <summary>
' NnAllocmsg
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="size">UInteger</param>
' <param name="type_">Long (0 = default)</param>
' <returns>Returns message buffer pointer, or 0 on error.</returns>
Function NnAllocmsg(Byval dllInstance As Any Ptr, Byval size As UInteger, Byval type_ As Long = 0) As Any Ptr
    Dim lResult As Any Ptr = 0
    Dim pFuncCall As Function Cdecl(Byval size As UInteger, Byval type_ As Long) As Any Ptr

    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_allocmsg")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(size, type_)
        End If
    End If

    Function = lResult
End Function

' <summary>
' NnReallocmsg
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="msg">Ptr</param>
' <param name="size">UInteger</param>
' <returns>Returns message buffer pointer, or 0 on error.</returns>
Function NnReallocmsg(Byval dllInstance As Any Ptr, Byval msg As Any Ptr, Byval size As UInteger) As Any Ptr
    Dim lResult As Any Ptr = 0
    Dim pFuncCall As Function Cdecl(Byval msg As Any Ptr, Byval size As UInteger) As Any Ptr

    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_reallocmsg")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(msg, size)
        End If
    End If

    Function = lResult
End Function

' <summary>
' NnFreemsg
' </summary>
' <param name="dllInstance">Ptr</param>
' <param name="msg">Ptr</param>
' <returns>Returns 0 on success, -1 on error.</returns>
Function NnFreemsg(Byval dllInstance As Any Ptr, Byval msg As Any Ptr) As Long
    Dim lResult As Long = -1
    Dim pFuncCall As Function Cdecl(Byval msg As Any Ptr) As Long

    If (dllInstance > 0) Then
        pFuncCall = DyLibSymbol(dllInstance, "nn_freemsg")

        If (pFuncCall > 0) Then
            lResult = pFuncCall(msg)
        End If
    End If

    Function = lResult
End Function
