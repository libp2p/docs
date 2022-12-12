---
title : "What is Stream Multiplexing"
description: "Stream Multiplexing is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed so it can be output and used by separate applications."
weight: 150
aliases:
    - "/concepts/stream-multiplexing"
    - "/concepts/multiplex"
---

## Overview

Stream multiplexing (or stream muxing) is a method to send multiple streams
of data over a single communication link. It combines multiple signals into one
unified signal. The unifed signal can then be demultiplexed (or demuxed), where
the output becomes available to use in an application.

Stream multiplexing is done to share a single TCP connection using unique port numbers
that distinguish streams between multiple processes (such as kademlia and gossipsub)
used by applications (such as IPFS) to make connection and transmission more efficient.

## Muxers in libp2p

Stream muxers are pluggable in libp2p. A given libp2p host can support several
muxers simultaneously. The stream muxer is negotiated between the two nodes during the handshake.
Having such a negotiation protocol in place allows libp2p to adopt new muxers in the future, while at
the same time keeping backwards-compatibility with currently deployed muxers.

With muxing, libp2p applications can have separate communication streams between peers
and multiple concurrent streams open simultaneously with a peer. Stream muxing
allows peers to initialize and use the same [transport](../../transports/overview)
connection across the lifetime of their interaction with another peer.

{{< alert icon="💡" context="info">}}
libp2p's multiplexing happens at the application layer, meaning the
operating system's network stack does not provide it. However, developers writing libp2p
applications rarely need to interact with stream multiplexers directly, except during
initial configuration to control which modules are enabled.
{{< /alert >}}

libp2p supports two muxers, [mplex](mplex) and [yamux](yamux). libp2p also supports
transports that support native stream muxing, like [QUIC](quic).
