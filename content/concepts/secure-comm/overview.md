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
LibP2P promotes modularity, meaning that different types of transports
can be used as part of the networking stack to power communication across
system or application. Some transports can include native channel encryption,
like QUIC, while other transports that establish a raw connection, like TCP
sockets, lack native security and require a channel upgrade.

## Secure channels in LibP2P

A channel is upgraded with a component that layers security (and
[stream multiplexing](../multiplex/overview)) over "raw" connections, known
as a transport upgrader. A transport upgrader uses a protocol called **multistream-select**
to negotiate the security and multiplexing protocols to use between two peers. Security
is always established first over the "raw" connection. More information on **multistream-select**
is available
[here](https://github.com/libp2p/specs/blob/master/connections/README.md#multistream-select).
LibP2P supports two security protocols, both with the technical
specifications: [Noise](https://github.com/libp2p/specs/blob/master/noise/README.md)
and [TLS 1.3](https://github.com/libp2p/specs/blob/master/tls/tls.md).

Get introduced to TLS 1.3 by viewing the [TLS document](tls).
Get introduced to Noise by viewing the [Noise document](noise).
