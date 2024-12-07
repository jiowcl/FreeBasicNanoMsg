'--------------------------------------------------------------------------------------------
'  Copyright (c) Ji-Feng Tsai. All rights reserved.
'  Code released under the MIT license.
'--------------------------------------------------------------------------------------------

#Pragma Once

' Version Macros for Compile-time API Version Detection 
Const NN_VERSION_CURRENT  As Long = 6
Const NN_VERSION_REVISION As Long = 0
Const NN_VERSION_AGE      As Long = 1

' Socket Types
Const NN_PROTO_REQREP     As Long = 3
Const NN_REQ              As Long = NN_PROTO_REQREP * 16 + 0
Const NN_REP              As Long = NN_PROTO_REQREP * 16 + 1

Const NN_REQ_RESEND_IVL   As Long = 1

Const NN_PROTO_PUBSUB     As Long = 2
Const NN_PUB              As Long = NN_PROTO_PUBSUB * 16 + 0
Const NN_SUB              As Long = NN_PROTO_PUBSUB * 16 + 1
Const NN_SUB_SUBSCRIBE    As Long = 1
Const NN_SUB_UNSUBSCRIBE  As Long = 2

' SP Address Families
Const AF_SP                As Long = 1
Const AF_SP_RAW            As Long = 2

' 
Const NN_TCP               As Long = -3
Const NN_TCP_NODELAY       As Long = 1

' Max Size of an SP Address
Const NN_SOCKADDR_MAX      As Long = 128

' Socket Option Levels
Const NN_SOL_SOCKET        As Long = 0

' Socket Options (NN_SOL_SOCKET level)
Const NN_LINGER            As Long = 1
Const NN_SNDBUF            As Long = 2
Const NN_RCVBUF            As Long = 3
Const NN_SNDTIMEO          As Long = 4
Const NN_RCVTIMEO          As Long = 5
Const NN_RECONNECT_IVL     As Long = 6
Const NN_RECONNECT_IVL_MAX As Long = 7
Const NN_SNDPRIO           As Long = 8
Const NN_RCVPRIO           As Long = 9
Const NN_SNDFD             As Long = 10
Const NN_RCVFD             As Long = 11
Const NN_DOMAIN            As Long = 12
Const NN_PROTOCOL          As Long = 13
Const NN_IPV4ONLY          As Long = 14
Const NN_SOCKET_NAME       As Long = 15
Const NN_RCVMAXSIZE        As Long = 16
Const NN_MAXTTL            As Long = 17

' Message Options

' Send/Recv Options
Const NN_DONTWAIT          As Long = 1

' Ancillary Data
Const PROTO_SP             As Long = 1
Const SP_HDR               As Long = 1

' Socket Mutliplexing Support
Const NN_POLLIN            As Long = 1
Const NN_POLLOUT           As Long = 2

' Transport Statistics 
Const NN_STAT_ESTABLISHED_CONNECTIONS As Long = 101
Const NN_STAT_ACCEPTED_CONNECTIONS    As Long = 102
Const NN_STAT_DROPPED_CONNECTIONS     As Long = 103
Const NN_STAT_BROKEN_CONNECTIONS      As Long = 104
Const NN_STAT_CONNECT_ERRORS          As Long = 105
Const NN_STAT_BIND_ERRORS             As Long = 106
Const NN_STAT_ACCEPT_ERRORS           As Long = 107

Const NN_STAT_CURRENT_CONNECTIONS     As Long = 201
Const NN_STAT_INPROGRESS_CONNECTIONS  As Long = 202
Const NN_STAT_CURRENT_EP_ERRORS       As Long = 203

' The Socket-internal Statistics 
Const NN_STAT_MESSAGES_SENT           As Long = 301
Const NN_STAT_MESSAGES_RECEIVED       As Long = 302
Const NN_STAT_BYTES_SENT              As Long = 303
Const NN_STAT_BYTES_RECEIVED          As Long = 304

' Protocol Statistics
Const NN_STAT_CURRENT_SND_PRIORITY    As Long = 401

' Errors
Const NN_HAUSNUMERO   As Long = 156384712
Const ENOTSUP         As Long = NN_HAUSNUMERO + 1
Const EPROTONOSUPPORT As Long = NN_HAUSNUMERO + 2
Const ENOBUFS         As Long = NN_HAUSNUMERO + 3
Const ENETDOWN        As Long = NN_HAUSNUMERO + 4
Const EADDRINUSE      As Long = NN_HAUSNUMERO + 5
Const EADDRNOTAVAIL   As Long = NN_HAUSNUMERO + 6
Const ECONNREFUSED    As Long = NN_HAUSNUMERO + 7
Const EINPROGRESS     As Long = NN_HAUSNUMERO + 8
Const ENOTSOCK        As Long = NN_HAUSNUMERO + 9
Const EAFNOSUPPORT    As Long = NN_HAUSNUMERO + 10
Const EPROTO          As Long = NN_HAUSNUMERO + 11
Const EAGAIN          As Long = NN_HAUSNUMERO + 12
Const EBADF           As Long = NN_HAUSNUMERO + 13
Const EINVAL          As Long = NN_HAUSNUMERO + 14
Const EMFILE          As Long = NN_HAUSNUMERO + 15
Const EFAULT          As Long = NN_HAUSNUMERO + 16
Const EACCES          As Long = NN_HAUSNUMERO + 17
Const ENETRESET       As Long = NN_HAUSNUMERO + 18
Const ENETUNREACH     As Long = NN_HAUSNUMERO + 19
Const EHOSTUNREACH    As Long = NN_HAUSNUMERO + 20
Const ENOTCONN        As Long = NN_HAUSNUMERO + 21
Const EMSGSIZE        As Long = NN_HAUSNUMERO + 22
Const ETIMEDOUT       As Long = NN_HAUSNUMERO + 23
Const ECONNABORTED    As Long = NN_HAUSNUMERO + 24
Const ECONNRESET      As Long = NN_HAUSNUMERO + 25
Const ENOPROTOOPT     As Long = NN_HAUSNUMERO + 26
Const EISCONN         As Long = NN_HAUSNUMERO + 27
Const ESOCKTNOSUPPORT As Long = NN_HAUSNUMERO + 28

' Native Nanomsg Error Codes
Const ETERM          As Long = NN_HAUSNUMERO + 53
Const EFSM           As Long = NN_HAUSNUMERO + 54

' Type
Type NnMsgT
    __(0 To 63) As UByte
End Type