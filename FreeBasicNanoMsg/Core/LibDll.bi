'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' Function Declare
Declare Function NnDllOpen(Byval lpszDllPath As String) As Any Ptr
Declare Function NnDllClose(Byval dllInstance As Any Ptr) As Boolean

Declare Function SizeOfDefZStringPtr(Byval varToPtr As ZString Ptr) As Integer
Declare Function SizeOfDefWStringPtr(Byval varToPtr As WString Ptr) As Integer

' <summary>
' NnDllOpen
' </summary>
' <param name="lpszDllPath"></param>
' <returns>Returns any pty.</returns>
Function NnDllOpen(Byval lpszDllPath As String) As Any Ptr
    Function = DyLibLoad(lpszDllPath)
End Function

' <summary>
' NnDllClose
' </summary>
' <param name="dllInstance"></param>
' <returns>Returns boolean.</returns>
Function NnDllClose(Byval dllInstance As Any Ptr) As Boolean
    If (dllInstance > 0) Then
        DyLibFree(dllInstance)
    End If
  
    Function = True
End Function

' <summary>
' SizeOfDefZStringPtr
' </summary>
' <param name="varToPtr"></param>
' <returns>Returns integer.</returns>
Function SizeOfDefZStringPtr(Byval varToPtr As ZString Ptr) As Integer
    Function = SizeOf(*Cast(TypeOf(varToPtr), 0))
End Function

' <summary>
' SizeOfDefWStringPtr
' </summary>
' <param name="varToPtr"></param>
' <returns>Returns integer.</returns>
Function SizeOfDefWStringPtr(Byval varToPtr As WString Ptr) As Integer
    Function = SizeOf(*Cast(TypeOf(varToPtr), 0))
End Function