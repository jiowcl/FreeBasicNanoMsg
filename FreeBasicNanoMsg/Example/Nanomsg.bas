'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nanomsg.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

Chdir(lpszCurrentDir & lpszLibNnDir)

Dim hLibrary As Any Ptr = NnDllOpen(lpszLibNnDll)

If hLibrary > 0 Then
    Dim errorNo As Long
    
    Dim nnSymbolIndex As Integer = 0
    Dim nnSymbolValue As Long

    While (nnSymbolIndex >= 0)
        Dim nnSymbolBufferPtr As Const ZString Ptr = NnSymbol(hLibrary, nnSymbolIndex, nnSymbolValue)
        Dim nnSymbolName As String = *CPtr(ZString Ptr, nnSymbolBufferPtr)

        If (Len(nnSymbolName) = 0) Then Exit While

        Print("NanoMsg Symbol: " & nnSymbolName & " " & nnSymbolValue)

        errorNo = NnErrno(hLibrary)

        nnSymbolIndex = nnSymbolIndex + 1

        nnSymbolBufferPtr = 0
    Wend

    Print("NanoMsg Error: " & errorNo)
    
    NnDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()