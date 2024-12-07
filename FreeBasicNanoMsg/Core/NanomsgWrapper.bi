'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Include Once "crt/long.bi"
#Include Once "crt/longdouble.bi"

#Include Once "LibDll.bi"
#Include Once "Enums.bi"
#Include Once "Runtime.bi"
#Include Once "Socket.bi"

#Pragma Once

' Declare Enum LIB_WRAPPER
Enum LIB_WRAPPER
    OPT_DLLOPEN  = 1
    OPT_DLLCLOSE = 2
    OPT_DLLLOAD  = 3
End Enum

' Declare Type LibNanomsgWrapper
Type LibNanomsgWrapper
public:
    Declare Static Function DllOpen(Byval lpszDllPath As String) As Any Ptr
    Declare Static Function DllClose() As Boolean
    Declare Static Function DllInstance() As Any Ptr
private:
    Declare Static Function Instance(Byval opt As Integer, Byval lpszDllPath As String = "") As Any Ptr
    Dim As Integer ErrorCode
End Type

' Declare Type LibNanomsgRuntime
Type LibNanomsgRuntime Extends LibNanomsgWrapper
public:
    Declare Function Errno() As Long
    Declare Function Strerror(Byval errnum As Integer) As Const ZString Ptr
    Declare Function Symbol(Byval index As Integer, Byref value As Long) As Const ZString Ptr
End Type

' Declare Type LibNanomsgSocket
Type LibNanomsgSocket Extends LibNanomsgWrapper
public:
    Declare Function Socket(Byval domain As Long, Byval protocol As Long) As Any Ptr
    Declare Function Close(Byval socket_ As Any Ptr) As Long
    Declare Function Setsockopt(Byval socket_ As Any Ptr, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As UInteger) As Long
    Declare Function Getsockopt(Byval socket_ As Any Ptr, Byval level As Long, Byval options As Long, Byref optval As String, Byval optvallen As UInteger) As Long
    Declare Function Bind(Byval socket_ As Any Ptr, Byval addr As Const ZString Ptr) As Long
    Declare Function Connect(Byval socket_ As Any Ptr, Byval addr As Const ZString Ptr) As Long
    Declare Function Shutdown(Byval socket_ As Any Ptr, Byval how As Long) As Long
    Declare Function Send(Byval socket_ As Any Ptr, Byval buf As Any Ptr, Byval buflen As UInteger, Byval flags As Long) As Long
    Declare Function Recv(Byval socket_ As Any Ptr, Byval buf As Any Ptr, Byval buflen As UInteger, Byval flags As Long) As Long
End Type

' Type LibNanomsgWrapper

' <summary>
' DllOpen
' </summary>
' <param name="lpszDllPath"></param>
' <returns>Returns any ptr.</returns>
Static Function LibNanomsgWrapper.DllOpen(Byval lpszDllPath As String) As Any Ptr
    Function = LibNanomsgWrapper.Instance(LIB_WRAPPER.OPT_DLLOPEN, lpszDllPath)
End Function

' <summary>
' DllClose
' </summary>
' <returns>Returns boolean.</returns>
Static Function LibNanomsgWrapper.DllClose() As Boolean
    Function = False

    If (LibNanomsgWrapper.Instance(LIB_WRAPPER.OPT_DLLCLOSE) = 0) Then
        Function = True
    End If
End Function

' <summary>
' DllInstance
' </summary>
' <returns>Returns any ptr.</returns>
Static Function LibNanomsgWrapper.DllInstance() As Any Ptr
    Function = LibNanomsgWrapper.Instance(LIB_WRAPPER.OPT_DLLLOAD)
End Function

' <summary>
' Instance
' </summary>
' <param name="opt"></param>
' <param name="lpszDllPath"></param>
' <returns>Returns any ptr.</returns>
Static Function LibNanomsgWrapper.Instance(Byval opt As Integer, Byval lpszDllPath As String = "") As Any Ptr
    Static LibDllPath As String
    Static LibDllInstancePtr As Any Ptr

    If (Opt = LIB_WRAPPER.OPT_DLLOPEN) Then
        If (Len(LibDllPath) = 0) Then
            If (Len(lpszDllPath) > 0) Then
                LibDllPath = lpszDllPath
            End If

            If (LibDllInstancePtr = 0) Then
                LibDllInstancePtr = DyLibLoad(lpszDllPath)
            End If
        End If
    End If

    If (Opt = LIB_WRAPPER.OPT_DLLCLOSE) Then
        If (LibDllInstancePtr > 0) Then
            DyLibFree(LibDllInstancePtr)

            LibDllPath = ""
            LibDllInstancePtr = 0
        End If
    End If

    If (Opt = LIB_WRAPPER.OPT_DLLLOAD) Then

    End If

    Function = LibDllInstancePtr
End Function

' Type LibNanomsgRuntime
' <summary>
' Errno
' </summary>
' <returns>Returns integer.</returns>
Function LibNanomsgRuntime.Errno() As Long 
    Function = NnErrno(LibNanomsgWrapper.DllInstance())
End Function

' <summary>
' Strerror
' </summary>
' <param name="errnum"></param>
' <returns>Returns zstring ptr.</returns>
Function LibNanomsgRuntime.Strerror(Byval errnum As Integer) As Const ZString Ptr
    Function = NnStrerror(LibNanomsgWrapper.DllInstance(), errnum)
End Function

' <summary>
' Symbol
' </summary>
' <param name="index"></param>
' <param name="value"></param>
' <returns>Returns zstring ptr.</returns>
Function LibNanomsgRuntime.Symbol(Byval index As Integer, Byref value As Long) As Const ZString Ptr 
    Function = NnSymbol(LibNanomsgWrapper.DllInstance(), index, value)
End Function

' Module LibNanomsgSocket

' <summary>
' Socket
' </summary>
' <param name="domain"></param>
' <param name="protocol"></param>
' <returns>Returns any ptr.</returns>
Function LibNanomsgSocket.Socket(Byval domain As Long, Byval protocol As Long) As Any Ptr
    Function = NnSocket(LibNanomsgWrapper.DllInstance(), domain, protocol)
End Function
  
' <summary>
' Close
' </summary>
' <param name="socket_"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Close(Byval socket_ As Any Ptr) As Long   
    Function = NnClose(LibNanomsgWrapper.DllInstance(), socket_)
End Function

' <summary>
' Setsockopt
' </summary>
' <param name="socket_"></param>
' <param name="level"></param>
' <param name="options"></param>
' <param name="optval"></param>
' <param name="optvallen"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Setsockopt(Byval socket_ As Any Ptr, Byval level As Long, Byval options As Long, Byval optval As Any Ptr, Byval optvallen As Uinteger) As Long   
    Function = NnSetsockopt(LibNanomsgWrapper.DllInstance(), socket_, level, options, optval, optvallen)
End Function

' <summary>
' Getsockopt
' </summary>
' <param name="socket_"></param>
' <param name="level"></param>
' <param name="options"></param>
' <param name="optval"></param>
' <param name="optvallen"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Getsockopt(Byval socket_ As Any Ptr, Byval level As Long, Byval options As Long, Byref optval As String, Byval optvallen As Uinteger) As Long   
    Function = NnGetsockopt(LibNanomsgWrapper.DllInstance(), socket_, level, options, optval, optvallen)
End Function

' <summary>
' Bind
' </summary>
' <param name="socket_"></param>
' <param name="addr"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Bind(Byval socket_ As Any Ptr, Byval addr As Const ZString Ptr) As Long   
    Function = NnBind(LibNanomsgWrapper.DllInstance(), socket_, addr)
End Function

' <summary>
' Connect
' </summary>
' <param name="socket_"></param>
' <param name="addr"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Connect(Byval socket_ As Any Ptr, Byval addr As Const ZString Ptr) As Long   
    Function = NnConnect(LibNanomsgWrapper.DllInstance(), socket_, addr)
End Function

' <summary>
' Shutdown
' </summary>
' <param name="socket_"></param>
' <param name="how"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Shutdown(Byval socket_ As Any Ptr, Byval how As Long) As Long   
    Function = NnShutdown(LibNanomsgWrapper.DllInstance(), socket_, how)
End Function

' <summary>
' Send
' </summary>
' <param name="socket_"></param>
' <param name="buf"></param>
' <param name="buflen"></param>
' <param name="flags"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Send(Byval socket_ As Any Ptr, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long    
    Function = NnSend(LibNanomsgWrapper.DllInstance(), socket_, buf, buflen, flags)
End Function

' <summary>
' Recv
' </summary>
' <param name="socket_"></param>
' <param name="buf"></param>
' <param name="buflen"></param>
' <param name="flags"></param>
' <returns>Returns long.</returns>
Function LibNanomsgSocket.Recv(Byval socket_ As Any Ptr, Byval buf As Any Ptr, Byval buflen As Uinteger, Byval flags As Long) As Long   
    Function = NnRecv(LibNanomsgWrapper.DllInstance(), socket_, buf, buflen, flags)
End Function