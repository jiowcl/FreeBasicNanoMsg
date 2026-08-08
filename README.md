# FreeBasicNanoMsg

Nanomsg Wrapper for FreeBasic Programming Language.

![GitHub](https://img.shields.io/github/license/jiowcl/FreeBasicNanoMsg.svg)
![FreeBasic](https://img.shields.io/badge/language-FreeBasic-blue.svg)

## Environment

- Windows 7 above (recommend)  
- FreeBasic 1.10.1 above (recommend)  
- [Nanomsg](https://github.com/nanomsg)  

## How to Build

Building requires FreeBasic Compiler and test under Windows 10.  

## API Notes

- Socket handles are `Long` (matching C `int`), not pointers.
- Protocols: `NN_PAIR`, `NN_PUB`/`NN_SUB`, `NN_REQ`/`NN_REP`, `NN_PUSH`/`NN_PULL`, `NN_SURVEYOR`/`NN_RESPONDENT`, `NN_BUS`.
- Transports: `NN_INPROC`, `NN_IPC`, `NN_TCP`, `NN_WS` (plus `NN_TCP_NODELAY`, `NN_IPC_*`, `NN_WS_MSG_TYPE*`).
- `NnSetsockopt` / `LibNanomsgSocket.Setsockopt` take a pointer (`Any Ptr`) and length.
- Use `NnSetsockoptString` / `SetsockoptString` for topic strings (`NN_SUB_SUBSCRIBE`).
- Use `NnSetsockoptInt` / `SetsockoptInt` for integer options (`NN_RCVTIMEO`, `NN_SURVEYOR_DEADLINE`, …).
- `NnGetsockopt` requires `optval As Any Ptr` and `optvallen As UInteger Ptr` (in/out length), matching the C API.
- Use `NnGetsockoptInt` / `GetsockoptInt` for integer options.
- Zero-copy: `NnAllocmsg` / `NnReallocmsg` / `NnFreemsg` (or `LibNanomsgMessage`), with size sentinel `NN_MSG` on send/recv.
- Poll struct: `NnPollFd` (`NN_POLLIN` / `NN_POLLOUT`).

## Example

Publisher Server

```bash
fbc PubServer.bas -target win64
```

```freebasic
#Include "../../Core/Enums.bi"
#Include "../../Core/NanomsgWrapper.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

Chdir(lpszCurrentDir & lpszLibNnDir)

' Rnd with Range (first = min, last = max)
' Source Code from: https://documentation.help/FreeBASIC/KeyPgRnd.html
Function RndRange(Byval first As Double, Byval last As Double) As Double
    Function = Rnd * (last - first) + first
End Function

Const lpszServerAddr As String = "tcp://*:1689"

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_PUB)
    Dim Rc As Long = NnSocketRec.Bind(Socket, lpszServerAddr)

    If Rc < 0 Then
        Print("Bind failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    Else
        Print("Bind an IP address: " & lpszServerAddr)

        Randomize
        
        While 1
            ' Prefix must match NN_SUB_SUBSCRIBE filter on the subscriber.
            Dim lpszTopic As String = "quotes"
            Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(1000, 9000)) & ",Ask:" & Str(RndRange(1000, 9000))

            Rc = NnSocketRec.Send(Socket, StrPtr(lpszSendMessage), Len(lpszSendMessage), 0)

            If Rc >= 0 Then
                Print("Published: " & lpszSendMessage)
            End If

            Sleep(500)
        Wend
    End If
    
    NnSocketRec.Close(Socket)
    
    LibNanomsgWrapper.DllClose()
End If
```

Subscribe Client

```bash
fbc SubClient.bas -target win64
```

```freebasic
#Include "../../Core/Enums.bi"
#Include "../../Core/NanomsgWrapper.bi"

Dim lpszCurrentDir As String = Curdir()

' Nanomsg version (x64)
Dim lpszLibNnDir As String = "/Library/x64"
Dim lpszLibNnDll As String = lpszCurrentDir & lpszLibNnDir & "/nanomsg.dll"

Chdir(lpszCurrentDir & lpszLibNnDir)

' nn_recv does not append a null terminator; copy by returned length.
Function BytesToString(Byval buf As Any Ptr, Byval length As Long) As String
    If (buf = 0) Or (length <= 0) Then
        Function = ""
        Exit Function
    End If

    Dim result As String = String(length, 0)
    Dim src As UByte Ptr = Cast(UByte Ptr, buf)
    Dim dst As UByte Ptr = Cast(UByte Ptr, StrPtr(result))
    Dim i As Long

    For i = 0 To length - 1
        dst[i] = src[i]
    Next

    Function = result
End Function

Const lpszServerAddr As String = "tcp://localhost:1689"
Const RECV_BUFSIZE As Long = 256

Dim NnSocketRec As LibNanomsgSocket
Dim NnRuntime As LibNanomsgRuntime

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_SUB)
    Dim Rc As Long = NnSocketRec.Connect(Socket, lpszServerAddr)

    If Rc < 0 Then
        Print("Connect failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
    Else
        Dim lpszSubscribe As String = "quotes"

        Rc = NnSocketRec.SetsockoptString(Socket, NN_SUB, NN_SUB_SUBSCRIBE, StrPtr(lpszSubscribe))

        If Rc < 0 Then
            Print("Subscribe failed: " & *NnRuntime.Strerror(NnRuntime.Errno()))
        Else
            While 1
                Dim lpszRecvBufferPtr As Any Ptr = CAllocate(RECV_BUFSIZE)
                Dim recvRc As Long = NnSocketRec.Recv(Socket, lpszRecvBufferPtr, RECV_BUFSIZE, 0)

                If recvRc >= 0 Then
                    Print(BytesToString(lpszRecvBufferPtr, recvRc))
                End If

                Deallocate(lpszRecvBufferPtr)
                lpszRecvBufferPtr = 0
            Wend
        End If
    End If
    
    NnSocketRec.Close(Socket)
    
    LibNanomsgWrapper.DllClose()
End If

Print("Press any key to continue...")
Sleep()
```

## License

Copyright (c) 2017-2026 Ji-Feng Tsai.  
Code released under the MIT license.  

## TODO

- More examples  

## Donation

If this application help you reduce time to coding, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/TW/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3RNMD6Q3B495N&source=url)

[Paypal Me](https://paypal.me/jiowcl?locale.x=zh_TW)
