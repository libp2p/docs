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
over the lifetime of their interaction with another peer.

libp2p uses stream muxing to share a single connection between multiple
libp2p and application protocols.
This is especially useful when establishing the connection required a lot of effort,
e.g. when NAT hole punching was necessary to establish a direct connection to a peer.
libp2p, for example, HTTP/2 introduced streams into HTTP, allowing for many HTTP
requests in parallel on the same connection.

## Stream Multiplexers in libp2p

Establishing a libp2p connection can be expensive and take a few round-trips.
Peers therefore aim to establish a connection once, then run many streams over
the same connection. Opening has a low resource overhead and does not impose any
latency penalty.

Stream muxers are pluggable in libp2p. A given libp2p host can support several
muxers simultaneously. The stream muxer is negotiated between the two nodes during
the handshake. Having such a negotiation protocol in place allows libp2p to adopt
new muxers in the future, while simultaneously keeping backward compatibility with
currently deployed muxers.

{{< alert icon="💡" context="info">}}
Developers writing libp2p applications rarely need to interact with stream
multiplexers directly, except during initial configuration. A libp2p connection always
is a stream-multiplexed connection, and the libp2p stack takes care of negotiating and
setting up a stream multiplexer.
{{< /alert >}}

libp2p supports two muxers, [mplex](mplex) and [yamux](yamux). libp2p also supports
transports that support native stream muxing, like [QUIC](../transports/quic).
