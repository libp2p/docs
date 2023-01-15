---
title: "libp2p Host"
description: "A libp2p host is a program or process that runs on a peer and allows it to participate in a libp2p network."
weight: 4
---

A libp2p host is a program or process that allows a peer to participate
in the libp2p network and defines the peer's properties. In the context of
libp2p, a host is a specific implementation of a node that has been configured
to use the libp2p stack.

A libp2p host can provide more control over a node's
configuration through the use of options such as customizing the
[host's identity](core-abstractions/peers.md#peer-id),
[listen to addresses](core-abstractions/addressing.md),
[transport protocols](../transports/overview.md) to use a transport
like [QUIC](../transports/quic.md),
[security protocols](../secure-comm/overview.md) to use
[Noise](../secure-comm/noise.md) or [TLS](../secure-comm/tls.md),
[connection manager](core-abstractions/connections.md##connection-and-stream-management),
[NAT port mapping](../nat/overview.md##automatic-router-configuration),
and [routing](../discovery-routing/overview.md) to use a routing protocol
like [DHT](../discovery-and-routing/kaddht.md).
