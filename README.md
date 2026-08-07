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

' Rnd with Range
' Source Code from: https://documentation.help/FreeBASIC/KeyPgRnd.html
Function RndRange(Byval first As Double, Byval last As Double) As Double
    Function = Rnd * (last - first) + first
End Function

Const lpszServerAddr As String = "tcp://*:1689"

Dim NnSocketRec As LibNanomsgSocket

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_PUB)
    Dim Rc As Long = NnSocketRec.Bind(Socket, lpszServerAddr)

    Print("Bind an IP address: " & lpszServerAddr)

    Randomize
    
    While 1
        Dim lpszSendBufferPtr As ZString Ptr
        Dim lpszTopic As String = "quotes"
        Dim lpszSendMessage As String = lpszTopic & "#Bid: " & Str(RndRange(9000, 1000)) & ",Ask:" + Str(RndRange(9000, 1000))
       
        lpszSendBufferPtr = CAllocate(Len(lpszSendMessage), SizeOfDefZStringPtr(lpszSendBufferPtr))
        *lpszSendBufferPtr = lpszSendMessage

        NnSocketRec.Send(Socket, lpszSendBufferPtr, Len(lpszSendMessage), 0)
        Print("Published: " & lpszSendMessage)

        Deallocate(lpszSendBufferPtr)
        lpszSendBufferPtr = 0

        Sleep(500)
    Wend
    
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

Const lpszServerAddr As String = "tcp://localhost:1689"

Dim NnSocketRec As LibNanomsgSocket

If LibNanomsgWrapper.DllOpen(lpszLibNnDll) Then
    Dim Socket As Long = NnSocketRec.Socket(AF_SP, NN_SUB)
    Dim Rc As Long = NnSocketRec.Connect(Socket, lpszServerAddr)
    
    Dim lpszSubscribe As String = "quotes"

    NnSocketRec.SetsockoptString(Socket, NN_SUB, NN_SUB_SUBSCRIBE, StrPtr(lpszSubscribe))
    
    While 1
        Dim lpszRecvBufferPtr As Any Ptr = CAllocate(64)

        NnSocketRec.Recv(Socket, lpszRecvBufferPtr, 64, 0)

        Print(*CPtr(ZString Ptr, lpszRecvBufferPtr))
        
        Deallocate(lpszRecvBufferPtr)

        lpszRecvBufferPtr = 0
        
        Sleep(2)
    Wend
    
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
