'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include "../Core/Nng.bi"

Dim lpszCurrentDir As String = Curdir()

' NNG version (x64)
Dim lpszLibNngDir As String = "/Library/x64"
Dim lpszLibNngDll As String = lpszCurrentDir & lpszLibNngDir & "/nng.dll"

Chdir(lpszCurrentDir & lpszLibNngDir)

Dim hLibrary As Any Ptr = NngDllOpen(lpszLibNngDll)

If (hLibrary > 0) And (NngInit(hLibrary) = NNG_OK) Then
    Print("NNG loaded OK.")
    Print("NNG_OK = " & Str(NNG_OK))
    Print("Sample strerror(NNG_ETIMEDOUT): " & *NngStrerror(hLibrary, NNG_ETIMEDOUT))

    NngFini(hLibrary)
    NngDllClose(hLibrary)
End If

Print("Press any key to continue...")
Sleep()
