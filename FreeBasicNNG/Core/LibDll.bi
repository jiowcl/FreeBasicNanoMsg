'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' Function Declare
Declare Function NngDllOpen(Byval lpszDllPath As String) As Any Ptr
Declare Function NngDllClose(Byval dllInstance As Any Ptr) As Boolean

Declare Function SizeOfDefZStringPtr(Byval varToPtr As ZString Ptr) As Integer
Declare Function SizeOfDefWStringPtr(Byval varToPtr As WString Ptr) As Integer

' <summary>
' NngDllOpen
' </summary>
' <param name="lpszDllPath">String</param>
' <returns>Returns any ptr.</returns>
Function NngDllOpen(Byval lpszDllPath As String) As Any Ptr
    Function = DyLibLoad(lpszDllPath)
End Function

' <summary>
' NngDllClose
' </summary>
' <param name="dllInstance">Ptr</param>
' <returns>Returns boolean.</returns>
Function NngDllClose(Byval dllInstance As Any Ptr) As Boolean
    If (dllInstance > 0) Then
        DyLibFree(dllInstance)
    End If
  
    Function = True
End Function

' <summary>
' SizeOfDefZStringPtr
' </summary>
' <param name="varToPtr">ZString Ptr</param>
' <returns>Returns integer.</returns>
Function SizeOfDefZStringPtr(Byval varToPtr As ZString Ptr) As Integer
    Function = SizeOf(*Cast(TypeOf(varToPtr), 0))
End Function

' <summary>
' SizeOfDefWStringPtr
' </summary>
' <param name="varToPtr">WString Ptr</param>
' <returns>Returns integer.</returns>
Function SizeOfDefWStringPtr(Byval varToPtr As WString Ptr) As Integer
    Function = SizeOf(*Cast(TypeOf(varToPtr), 0))
End Function
