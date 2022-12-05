---
title : "What are Secure Channels"
description: "Before two peers can transmit data, the communication channel they established with a transport protocol should be secure. Learn about secure channels in libp2p."
weight: 120
aliases:
    - "/concepts/secure-comm"
---

## Overview

Before two peers can transmit data, the communication channel they
establish with a transport protocol should be secure. By design,
libp2p promotes modularity, meaning that different types of transports
can be used as part of the networking stack to power communication across
system or application. Some transports include native channel encryption,
like [QUIC](../transports/quic), while other transports that establish a
raw connection, like TCP sockets, lack native security and require a channel
upgrade.

## Secure channels in libp2p

A channel is upgraded with a component that layers security (and
[stream multiplexing](../multiplex/overview)) over "raw" connections, known
as a transport upgrader. In libp2p, a transport upgrader uses a protocol
called **multistream-select** to negotiate the security and multiplexing protocols
to use between two peers. Security is always established first over the "raw"
connection. More information on **multistream-select** is available
[here](https://github.com/libp2p/specs/blob/master/connections/README.md#multistream-select).
Libp2p supports two security protocols, [TLS 1.3](tls) and [Noise](noise).
