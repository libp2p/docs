---
title : "What is Stream Multiplexing"
description: "Stream Multiplexing is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed so it can be output and used by separate applications."
weight: 150
aliases:
    - "/concepts/stream-multiplexing"
    - "/concepts/multiplex"
---

## Overview

Stream multiplexing (or stream muxing) is a method to send multiple streams of
data over a single communication link. It allows peers to use the same connection
across the lifetime of their interaction with another peer.

In particular, stream muxing is done to share a single connection between multiple
protocols used by applications to make connection and transmission more efficient.
This is especially useful when doing NAT traversal or hole punching,
as it allows for efficient use of limited resources. This is also used outside of
libp2p, for example, HTTP/2 introduced streams into HTTP, allowing for many HTTP
requests in parallel on the same connection.

## Muxers in libp2p

Establishing a libp2p connection can be expensive and take a few round-trips.
Peers therefore aim to establish a connection once, then run many streams over
the same connection. Opening has a low resource overhead and does not impose any
latency penalty.

Stream muxers are pluggable in libp2p. A given libp2p host can support several
muxers simultaneously. The stream muxer is negotiated between the two nodes during
the handshake. Having such a negotiation protocol in place allows libp2p to adopt
new muxers in the future while simultaneously keeping backward compatibility with
currently deployed muxers.

{{< alert icon="💡" context="info">}}
Developers writing libp2p applications rarely need to interact with stream
multiplexers directly, except during initial configuration to control which modules
are enabled. Some protocols have streams natively, and only pluggable muxers are
needed for protocols that don't.
{{< /alert >}}

libp2p supports two muxers, [mplex](mplex) and [yamux](yamux). libp2p also supports
transports that support native stream muxing, like [QUIC](../transports/quic).
