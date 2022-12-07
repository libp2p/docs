---
title : "What are Secure Channels"
description: "Before two peers can transmit data, the communication channel they established with a transport protocol should be secure. Learn about secure channels in libp2p."
weight: 120
aliases:
    - "/concepts/secure-comm"
---

## Overview

Before two peers can transmit data, the communication channel they
establish needs to be secured. By design,
libp2p supports many different transports (TCP, QUIC, WebSocket, WebTransport, etc.).
Some transports have built-in encryption at the transport layer (e.g. QUIC)
like [QUIC](../transports/quic), while other transports (e.g. TCP, WebSocket) lack native security 
and require a security handshake after the connection has been established.

## Secure channels in libp2p

A channel is upgraded with a component that layers security (and
[stream multiplexing](../multiplex/overview)) over "raw" connections, known
as a transport upgrader. In libp2p, a transport upgrader uses a protocol
called **multistream-select** to negotiate the security and multiplexing protocols
to use between two peers. Security is always established first over the "raw"
connection. More information on **multistream-select** is available
[here](https://github.com/libp2p/specs/blob/master/connections/README.md#multistream-select).
Libp2p supports two security protocols, [TLS 1.3](tls) and [Noise](noise).
