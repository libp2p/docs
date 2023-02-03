---
title : "What is Stream Multiplexing"
description: "Stream Multiplexing is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed so it can be output and used by separate applications."
weight: 150
aliases:
    - "/concepts/stream-multiplexing"
    - "/concepts/multiplex"
---

## Overview

Network protocols often use bi-directional message streams built on top of a stream
abstraction to transmit data between nodes. However, relying on a single message
stream can result in scalability issues and bottlenecks, as one application would
need to wait for another to finish utilizing the stream before being able to send
and receive its own messages.

To overcome this issue, network connections employ stream multiplexing, which allows
for the creation of multiple virtual connections within a single connection. This
enables nodes to send multiple streams of messages over separate virtual connections,
providing a scalable solution that eliminates the bottleneck created by a
single stream. An example is when HTTP/2 introduced streams into HTTP,
allowing for many HTTP requests in parallel on the same connection.

In libp2p, stream muxing is used to share a single connection between various protocols,
providing a more efficient solution, particularly when establishing the connection is
resource-intensive, such as when NAT hole punching is necessary. By establishing a
connection once and running multiple streams over the same connection, libp2p can reduce
the resource overhead and latency penalty associated with frequent connection establishment.

## Stream Multiplexers in libp2p

Stream muxers are a key component of the libp2p stack, providing pluggable multiplexing
capabilities for peers. libp2p hosts can support multiple muxers simultaneously, and the
choice of muxer is negotiated between the nodes during the initial connection handshake.
This negotiation protocol allows libp2p to adopt new muxers in the future while
maintaining backward compatibility with existing muxers.

{{< alert icon="💡" context="info">}}
For developers building libp2p applications, interaction with stream muxers is typically
limited to the initial configuration phase. The libp2p stack automatically handles the
negotiation and setup of the muxer, ensuring that all connections are stream-multiplexed
and allowing for the seamless transmission of multiple streams of data over a single
connection.
{{< /alert >}}

Currently, libp2p supports two stream muxers, [mplex](/concepts/multiplex/mplex)
and [yamux](/concepts/multiplex/yamux). However, many of the
[transport protocols](/concepts/transports/overview) available in the libp2p stack
come with native streams, such as [QUIC](/concepts/transports/quic),
[WebTransport](/concepts/transports/webtransport), and
[WebRTC](/concepts/transports/webrtc), and in these cases, libp2p
**does not need to perform stream multiplexing** as the protocol already provides it.
