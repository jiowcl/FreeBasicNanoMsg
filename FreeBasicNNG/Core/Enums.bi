'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' NNG Library & API version (from nng.h)
Const NNG_MAJOR_VERSION As Long = 2
Const NNG_MINOR_VERSION As Long = 0
Const NNG_PATCH_VERSION As Long = 0

' Maximum length of a socket address (includes terminating NUL)
Const NNG_MAXADDRLEN As Long = 128

' Flags
Const NNG_FLAG_NONBLOCK As Long = 2

' Duration helpers (milliseconds)
Const NNG_DURATION_INFINITE As Long = -1
Const NNG_DURATION_DEFAULT  As Long = -2
Const NNG_DURATION_ZERO     As Long = 0

' Socket option names (string options used by nng_socket_set_* / get_*)
Const NNG_OPT_RECVBUF       As String = "recv-buffer"
Const NNG_OPT_SENDBUF       As String = "send-buffer"
Const NNG_OPT_RECVTIMEO     As String = "recv-timeout"
Const NNG_OPT_SENDTIMEO     As String = "send-timeout"
Const NNG_OPT_LOCADDR       As String = "local-address"
Const NNG_OPT_MAXTTL        As String = "ttl-max"
Const NNG_OPT_RECVMAXSZ     As String = "recv-size-max"
Const NNG_OPT_RECONNMINT    As String = "reconnect-time-min"
Const NNG_OPT_RECONNMAXT    As String = "reconnect-time-max"
Const NNG_OPT_TCP_NODELAY   As String = "tcp-nodelay"
Const NNG_OPT_TCP_KEEPALIVE As String = "tcp-keepalive"

' Protocol-specific option names
Const NNG_OPT_SUB_PREFNEW         As String = "sub:prefnew"
Const NNG_OPT_REQ_RESENDTIME      As String = "req:resend-time"
Const NNG_OPT_REQ_RESENDTICK      As String = "req:resend-tick"
Const NNG_OPT_SURVEYOR_SURVEYTIME As String = "surveyor:survey-time"
Const NNG_OPT_PAIR1_POLY          As String = "pair1:polyamorous"

' Error codes (nng_err)
Const NNG_OK           As Long = 0
Const NNG_EINTR        As Long = 1
Const NNG_ENOMEM       As Long = 2
Const NNG_EINVAL       As Long = 3
Const NNG_EBUSY        As Long = 4
Const NNG_ETIMEDOUT    As Long = 5
Const NNG_ECONNREFUSED As Long = 6
Const NNG_ECLOSED      As Long = 7
Const NNG_EAGAIN       As Long = 8
Const NNG_ENOTSUP      As Long = 9
Const NNG_EADDRINUSE   As Long = 10
Const NNG_ESTATE       As Long = 11
Const NNG_ENOENT       As Long = 12
Const NNG_EPROTO       As Long = 13
Const NNG_EUNREACHABLE As Long = 14
Const NNG_EADDRINVAL   As Long = 15
Const NNG_EPERM        As Long = 16
Const NNG_EMSGSIZE     As Long = 17
Const NNG_ECONNABORTED As Long = 18
Const NNG_ECONNRESET   As Long = 19
Const NNG_ECANCELED    As Long = 20
Const NNG_ENOFILES     As Long = 21
Const NNG_ENOSPC       As Long = 22
Const NNG_EEXIST       As Long = 23
Const NNG_EREADONLY    As Long = 24
Const NNG_EWRITEONLY   As Long = 25
Const NNG_ECRYPTO      As Long = 26
Const NNG_EPEERAUTH    As Long = 27
Const NNG_EBADTYPE     As Long = 30
Const NNG_ECONNSHUT    As Long = 31
Const NNG_ESTOPPED     As Long = 999
Const NNG_EINTERNAL    As Long = 1000
Const NNG_ESYSERR      As Long = &h10000000
Const NNG_ETRANERR     As Long = &h20000000

' Structure (matches struct nng_socket / nng_dialer / nng_listener / nng_ctx)
' On Windows x64 these are passed by value as a single uint32_t id.
Type NngSocket
    id As ULong
End Type

Type NngDialer
    id As ULong
End Type

Type NngListener
    id As ULong
End Type

Type NngCtx
    id As ULong
End Type
