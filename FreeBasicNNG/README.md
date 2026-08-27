# FreeBasicNNG  

NNG (nanomsg-next-gen) Wrapper for FreeBasic Programming Language.  

![FreeBasic](https://img.shields.io/badge/language-FreeBasic-blue.svg)
![Dependency](https://img.shields.io/badge/Protocol-nng-3A3A3A?style=flat-square)

This package is the NNG counterpart of [FreeBasicNanoMsg](../FreeBasicNanoMsg).  
nanomsg is no longer maintained; new projects should prefer NNG. The two wrappers are **API-incompatible** and live side by side.

## Environment  

- Windows 7 above (recommend)  
- FreeBasic 1.10.1 above (recommend)  
- [NNG](https://github.com/nanomsg/nng)  

## How to Build  

Building requires FreeBasic Compiler and test under Windows 10.

Bundled runtime: `Library/x64/nng.dll` (x64 only).

Run examples with the working directory set to this package root (`FreeBasicNNG/`), so `Library/x64/nng.dll` resolves correctly:

```bash
cd FreeBasicNNG
fbc Example/Nng.bas -target win64
fbc Example/PubServer.bas -target win64
fbc Example/Module/PubServer.bas -target win64
fbc Test/NngTest.bas -target win64
```

## API Notes  

- Success is `NNG_OK` (`0`). Unlike nanomsg, most calls return an `nng_err` directly (no `nn_errno`).
- Create sockets with protocol helpers: `PubOpen`, `SubOpen`, `ReqOpen`, … (not `Socket(domain, protocol)`).
- Use `Listen` / `Dial` instead of nanomsg `Bind` / `Connect`.
- `Recv` (wrapper) returns the byte count as `LongInt` on success, or `-1` on failure; read `LibNngRuntime.LastError()` for the `nng_err`.
- Low-level `NngSend` / `NngRecv` use `ULongInt` for message lengths and the in/out size pointer, matching 64-bit Windows `size_t`.
- Socket options use string names (`NNG_OPT_RECVTIMEO`, …) with typed setters (`SetMs` / `SetInt` / `SetSize`).
- `SetSize` / `GetSize` use `ULongInt` because their C API type is `size_t`.
- SUB topics use `Subscribe` / `Unsubscribe` (`nng_sub0_socket_subscribe`).
- Call `nng_init` via `DllOpen` (wrapper) or `NngInit` (low-level); pair with `DllClose` / `NngFini`.
- There is no `nn_poll`; use `SetMs(..., NNG_OPT_RECVTIMEO, …)` or `GetRecvPollFd` with an OS poll.
- Socket ids are `Long` (matching C `nng_socket.id` / `uint32_t` on Win64).
- Listen with `tcp://0.0.0.0:port`; dial with `tcp://127.0.0.1:port`. This bundled NNG rejects nanomsg-style `tcp://*:port`, and `localhost` may resolve to IPv6.

## Example  

Publisher Server

```bash
fbc Example/Module/PubServer.bas -target win64
```

```freebasic
#Include "../../Core/Enums.bi"
#Include "../../Core/NngWrapper.bi"

Dim lpszCurrentDir As String = Curdir()

' NNG version (x64)
Dim lpszLibNngDir As String = "/Library/x64"
Dim lpszLibNngDll As String = lpszCurrentDir & lpszLibNngDir & "/nng.dll"

Chdir(lpszCurrentDir & lpszLibNngDir)

Const lpszServerAddr As String = "tcp://0.0.0.0:1689"

Dim NngSocketRec As LibNngSocket
Dim NngRuntime As LibNngRuntime

If LibNngWrapper.DllOpen(lpszLibNngDll) Then
    Dim Socket As Long = NngSocketRec.PubOpen()
    Dim Rc As Long = NngSocketRec.Listen(Socket, lpszServerAddr)

    If Rc <> NNG_OK Then
        Print("Listen failed: " & *NngRuntime.Strerror(Rc))
    End If

    ' ... publish loop ...

    NngSocketRec.Close(Socket)
    LibNngWrapper.DllClose()
End If
```

Subscribe Client

```freebasic
#Include "../../Core/Enums.bi"
#Include "../../Core/NngWrapper.bi"

' ... DllOpen as above ...

Dim Socket As Long = NngSocketRec.SubOpen()
NngSocketRec.Dial(Socket, "tcp://127.0.0.1:1689")
NngSocketRec.Subscribe(Socket, StrPtr("quotes"))

Dim lpszBuffer As Any Ptr = CAllocate(256)
Dim recvRc As Long = NngSocketRec.Recv(Socket, lpszBuffer, 256, 0)

If recvRc >= 0 Then
    ' copy recvRc bytes from lpszBuffer
End If
```

More samples under `Example`:

- PUB/SUB, REQ/REP, PUSH/PULL (recv-timeout instead of `nn_poll`)
- Survey (`SurveyorServer` / `RespondentClient`)
- PAIR + `inproc://` smoke test (`PairInproc`)

## Tests

`Test/NngTest.bas` is a finite test suite intended for local verification and CI. It uses
only `inproc://` endpoints, so no network service is required. It verifies:

- 64-bit `size_t` message lengths and option values
- protection against overwriting adjacent memory through `nng_recv` / `nng_socket_get_size`
- PAIR, REQ/REP and PUB/SUB communication
- receive timeout and subscription errors

Run it from the `FreeBasicNNG` package root:

```bash
fbc -w all Test/NngTest.bas -target win64 -x _build/NngTest.exe
_build/NngTest.exe
```

## Nanomsg vs NNG (quick map)  

| Nanomsg | NNG (this wrapper) |
|---------|--------------------|
| `nn_socket(AF_SP, NN_PUB)` | `PubOpen()` |
| `Bind` / `Connect` | `Listen` / `Dial` |
| `Rc < 0` failure | `Rc <> NNG_OK` failure |
| `nn_errno` | return code / `LastError()` |
| `SetsockoptInt(..., NN_RCVTIMEO, …)` | `SetMs(sock, NNG_OPT_RECVTIMEO, …)` |
| `SetsockoptString(..., NN_SUB_SUBSCRIBE, …)` | `Subscribe(sock, topic)` |

## License  

Copyright (c) 2026 Ji-Feng Tsai.  
Code released under the MIT license.

## TODO  

- `nng_msg_*` / `Sendmsg` / `Recvmsg`
- dialer / listener fine-grained control
- `nng_aio` asynchronous API
- Bus example

## Donation  

If this application help you reduce time to coding, you can give me a cup of coffee :)

[![paypal](https://www.paypalobjects.com/en_US/TW/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3RNMD6Q3B495N&source=url)

[Paypal Me](https://paypal.me/jiowcl?locale.x=zh_TW)
