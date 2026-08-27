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

' Declare Type LibNngWrapper
Type LibNngWrapper
public:
    Declare Static Function DllOpen(Byval lpszDllPath As String) As Any Ptr
    Declare Static Function DllClose() As Boolean
    Declare Static Function DllInstance() As Any Ptr
private:
    Declare Static Function Instance(Byval opt As Integer, Byval lpszDllPath As String = "") As Any Ptr
    Dim As Integer ErrorCode
End Type

' Declare Type LibNngRuntime
Type LibNngRuntime Extends LibNngWrapper
public:
    ' Last nng_err from wrapper convenience helpers (nng has no nn_errno).
    Declare Static Function LastError() As Long
    Declare Static Function SetLastError(Byval errnum As Long) As Long
    Declare Function Init() As Long
    Declare Function Fini() As Boolean
    Declare Function Strerror(Byval errnum As Long) As Const ZString Ptr
End Type

' Declare Type LibNngSocket
Type LibNngSocket Extends LibNngWrapper
public:
    Declare Function PubOpen() As Long
    Declare Function SubOpen() As Long
    Declare Function ReqOpen() As Long
    Declare Function RepOpen() As Long
    Declare Function PushOpen() As Long
    Declare Function PullOpen() As Long
    Declare Function PairOpen() As Long
    Declare Function Pair0Open() As Long
    Declare Function SurveyorOpen() As Long
    Declare Function RespondentOpen() As Long
    Declare Function BusOpen() As Long
    Declare Function Close(Byval sock As Long) As Long
    Declare Function Listen(Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
    Declare Function Dial(Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
    Declare Function Send(Byval sock As Long, Byval buf As Any Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
    Declare Function SendString(Byval sock As Long, Byval buf As Const ZString Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
    Declare Function Recv(Byval sock As Long, Byval buf As Any Ptr, Byval leng As ULongInt, Byval flags As Long) As LongInt
    Declare Function SetMs(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    Declare Function GetMs(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    Declare Function SetInt(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    Declare Function GetInt(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    Declare Function SetSize(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt) As Long
    Declare Function GetSize(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt Ptr) As Long
    Declare Function Subscribe(Byval sock As Long, Byval topic As Const ZString Ptr) As Long
    Declare Function Unsubscribe(Byval sock As Long, Byval topic As Const ZString Ptr) As Long
    Declare Function GetRecvPollFd(Byval sock As Long, Byval fdp As Long Ptr) As Long
    Declare Function GetSendPollFd(Byval sock As Long, Byval fdp As Long Ptr) As Long
private:
    Declare Function StoreLastError(Byval rc As Long) As Long
    Declare Function OpenFromResult(Byval rc As Long, Byval sock As Long) As Long
End Type

' Type LibNngWrapper

' <summary>
' DllOpen
' </summary>
' <param name="lpszDllPath">String</param>
' <returns>Returns any ptr.</returns>
Static Function LibNngWrapper.DllOpen(Byval lpszDllPath As String) As Any Ptr
    Dim dllPtr As Any Ptr = LibNngWrapper.Instance(LIB_WRAPPER.OPT_DLLLOAD)

    If (dllPtr > 0) Then
        Function = dllPtr
        Exit Function
    End If

    dllPtr = LibNngWrapper.Instance(LIB_WRAPPER.OPT_DLLOPEN, lpszDllPath)

    If (dllPtr > 0) Then
        If (NngInit(dllPtr) <> NNG_OK) Then
            LibNngWrapper.Instance(LIB_WRAPPER.OPT_DLLCLOSE)
            Function = 0
            Exit Function
        End If
    End If

    Function = dllPtr
End Function

' <summary>
' DllClose
' </summary>
' <returns>Returns boolean.</returns>
Static Function LibNngWrapper.DllClose() As Boolean
    Dim dllPtr As Any Ptr = LibNngWrapper.Instance(LIB_WRAPPER.OPT_DLLLOAD)

    If (dllPtr > 0) Then
        NngFini(dllPtr)
    End If

    Function = False

    If (LibNngWrapper.Instance(LIB_WRAPPER.OPT_DLLCLOSE) = 0) Then
        Function = True
    End If
End Function

' <summary>
' DllInstance
' </summary>
' <returns>Returns any ptr.</returns>
Static Function LibNngWrapper.DllInstance() As Any Ptr
    Function = LibNngWrapper.Instance(LIB_WRAPPER.OPT_DLLLOAD)
End Function

' <summary>
' Instance
' </summary>
' <param name="opt">Integer</param>
' <param name="lpszDllPath">String</param>
' <returns>Returns any ptr.</returns>
Static Function LibNngWrapper.Instance(Byval opt As Integer, Byval lpszDllPath As String = "") As Any Ptr
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

' Type LibNngRuntime

' <summary>
' LastError
' </summary>
' <returns>Returns long (nng_err).</returns>
Static Function LibNngRuntime.LastError() As Long
    Function = LibNngRuntime.SetLastError(-1)
End Function

' <summary>
' SetLastError
' Internal helper: pass errnum >= 0 to store; pass -1 to read.
' </summary>
' <param name="errnum">Long</param>
' <returns>Returns long (nng_err).</returns>
Static Function LibNngRuntime.SetLastError(Byval errnum As Long) As Long
    Static storedError As Long

    If (errnum >= 0) Then
        storedError = errnum
    End If

    Function = storedError
End Function

' <summary>
' Init
' </summary>
' <returns>Returns long (nng_err).</returns>
Function LibNngRuntime.Init() As Long
    Function = NngInit(LibNngWrapper.DllInstance())
End Function

' <summary>
' Fini
' </summary>
' <returns>Returns boolean.</returns>
Function LibNngRuntime.Fini() As Boolean
    Function = NngFini(LibNngWrapper.DllInstance())
End Function

' <summary>
' Strerror
' </summary>
' <param name="errnum">Long</param>
' <returns>Returns zstring ptr.</returns>
Function LibNngRuntime.Strerror(Byval errnum As Long) As Const ZString Ptr
    Function = NngStrerror(LibNngWrapper.DllInstance(), errnum)
End Function

' Type LibNngSocket

' <summary>
' StoreLastError
' </summary>
' <param name="rc">Long</param>
' <returns>Returns long.</returns>
Function LibNngSocket.StoreLastError(Byval rc As Long) As Long
    LibNngRuntime.SetLastError(rc)
    Function = rc
End Function

' <summary>
' OpenFromResult
' </summary>
' <param name="rc">Long</param>
' <param name="sock">Long</param>
' <returns>Returns long socket id, or 0 on failure.</returns>
Function LibNngSocket.OpenFromResult(Byval rc As Long, Byval sock As Long) As Long
    StoreLastError(rc)

    If (rc = NNG_OK) Then
        Function = sock
        Exit Function
    End If

    Function = 0
End Function

' <summary>
' PubOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.PubOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngPub0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' SubOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.SubOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngSub0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' ReqOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.ReqOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngReq0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' RepOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.RepOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngRep0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' PushOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.PushOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngPush0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' PullOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.PullOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngPull0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' PairOpen (PAIR1)
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.PairOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngPair1Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' Pair0Open
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.Pair0Open() As Long
    Dim sock As Long
    Dim rc As Long = NngPair0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' SurveyorOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.SurveyorOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngSurveyor0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' RespondentOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.RespondentOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngRespondent0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' BusOpen
' </summary>
' <returns>Returns long.</returns>
Function LibNngSocket.BusOpen() As Long
    Dim sock As Long
    Dim rc As Long = NngBus0Open(LibNngWrapper.DllInstance(), @sock)

    Function = OpenFromResult(rc, sock)
End Function

' <summary>
' Close
' </summary>
' <param name="sock">Long</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.Close(Byval sock As Long) As Long
    Function = StoreLastError(NngSocketClose(LibNngWrapper.DllInstance(), sock))
End Function

' <summary>
' Listen
' </summary>
' <param name="sock">Long</param>
' <param name="addr">Const ZString Ptr</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.Listen(Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
    Function = StoreLastError(NngListen(LibNngWrapper.DllInstance(), sock, addr, flags))
End Function

' <summary>
' Dial
' </summary>
' <param name="sock">Long</param>
' <param name="addr">Const ZString Ptr</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.Dial(Byval sock As Long, Byval addr As Const ZString Ptr, Byval flags As Long = 0) As Long
    Function = StoreLastError(NngDial(LibNngWrapper.DllInstance(), sock, addr, flags))
End Function

' <summary>
' Send
' </summary>
' <param name="sock">Long</param>
' <param name="buf">Ptr</param>
' <param name="leng">ULongInt</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.Send(Byval sock As Long, Byval buf As Any Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
    Function = StoreLastError(NngSend(LibNngWrapper.DllInstance(), sock, buf, leng, flags))
End Function

' <summary>
' SendString
' </summary>
' <param name="sock">Long</param>
' <param name="buf">Const ZString Ptr</param>
' <param name="leng">ULongInt</param>
' <param name="flags">Long</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.SendString(Byval sock As Long, Byval buf As Const ZString Ptr, Byval leng As ULongInt, Byval flags As Long) As Long
    Function = StoreLastError(NngSendString(LibNngWrapper.DllInstance(), sock, buf, leng, flags))
End Function

' <summary>
' Recv
' Returns received byte count on success, or -1 on failure.
' Use LibNngRuntime.LastError() for the nng_err code.
' </summary>
' <param name="sock">Long</param>
' <param name="buf">Ptr</param>
' <param name="leng">ULongInt</param>
' <param name="flags">Long</param>
' <returns>Returns long.</returns>
Function LibNngSocket.Recv(Byval sock As Long, Byval buf As Any Ptr, Byval leng As ULongInt, Byval flags As Long) As LongInt
    Dim sz As ULongInt = leng
    Dim rc As Long = NngRecv(LibNngWrapper.DllInstance(), sock, buf, @sz, flags)

    StoreLastError(rc)

    If (rc = NNG_OK) Then
        Function = Cast(LongInt, sz)
        Exit Function
    End If

    Function = -1
End Function

' <summary>
' SetMs
' </summary>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.SetMs(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    Function = StoreLastError(NngSocketSetMs(LibNngWrapper.DllInstance(), sock, opt, optval))
End Function

' <summary>
' GetMs
' </summary>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.GetMs(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    Function = StoreLastError(NngSocketGetMs(LibNngWrapper.DllInstance(), sock, opt, optval))
End Function

' <summary>
' SetInt
' </summary>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.SetInt(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long) As Long
    Function = StoreLastError(NngSocketSetInt(LibNngWrapper.DllInstance(), sock, opt, optval))
End Function

' <summary>
' GetInt
' </summary>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.GetInt(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As Long Ptr) As Long
    Function = StoreLastError(NngSocketGetInt(LibNngWrapper.DllInstance(), sock, opt, optval))
End Function

' <summary>
' SetSize
' </summary>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">ULongInt</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.SetSize(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt) As Long
    Function = StoreLastError(NngSocketSetSize(LibNngWrapper.DllInstance(), sock, opt, optval))
End Function

' <summary>
' GetSize
' </summary>
' <param name="sock">Long</param>
' <param name="opt">Const ZString Ptr</param>
' <param name="optval">ULongInt Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.GetSize(Byval sock As Long, Byval opt As Const ZString Ptr, Byval optval As ULongInt Ptr) As Long
    Function = StoreLastError(NngSocketGetSize(LibNngWrapper.DllInstance(), sock, opt, optval))
End Function

' <summary>
' Subscribe
' </summary>
' <param name="sock">Long</param>
' <param name="topic">Const ZString Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.Subscribe(Byval sock As Long, Byval topic As Const ZString Ptr) As Long
    Function = StoreLastError(NngSub0Subscribe(LibNngWrapper.DllInstance(), sock, topic))
End Function

' <summary>
' Unsubscribe
' </summary>
' <param name="sock">Long</param>
' <param name="topic">Const ZString Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.Unsubscribe(Byval sock As Long, Byval topic As Const ZString Ptr) As Long
    Function = StoreLastError(NngSub0Unsubscribe(LibNngWrapper.DllInstance(), sock, topic))
End Function

' <summary>
' GetRecvPollFd
' </summary>
' <param name="sock">Long</param>
' <param name="fdp">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.GetRecvPollFd(Byval sock As Long, Byval fdp As Long Ptr) As Long
    Function = StoreLastError(NngSocketGetRecvPollFd(LibNngWrapper.DllInstance(), sock, fdp))
End Function

' <summary>
' GetSendPollFd
' </summary>
' <param name="sock">Long</param>
' <param name="fdp">Long Ptr</param>
' <returns>Returns long (nng_err).</returns>
Function LibNngSocket.GetSendPollFd(Byval sock As Long, Byval fdp As Long Ptr) As Long
    Function = StoreLastError(NngSocketGetSendPollFd(LibNngWrapper.DllInstance(), sock, fdp))
End Function
