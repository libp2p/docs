---
title : "What is Stream Multiplexing"
description: "Stream Multiplexing is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed so it can be output and used by separate applications."
weight: 150
aliases:
    - "/concepts/stream-multiplexing"
    - "/concepts/multiplex"
---

## Overview

libp2p is built on top of a stream abstraction and uses a bi-directional message stream to send data between peers.
However, relying on a single message
stream over a connection between two peers can result in scalability issues and bottlenecks.
Each peer on either side of the connection may run multiple applications sending and waiting for data over the stream.
A single stream would block applications on one another, as one application would
need to wait for another to finish utilizing the stream before being able to send
and receive its own messages.

To overcome this issue, libp2p enables applications to employ stream multiplexing.
Multiplexing allows
for the creation of multiple "virtual" connections within a single connection. This
enables nodes to send multiple streams of messages over separate virtual connections,
providing a scalable solution that eliminates the bottleneck created by a
single stream.
Two libp2p peers may have a single TCP connection and use different port numbers to distinguish streams.
Then different applications/processes like Kademlia or GossipSub used by an application like IPFS would get their own stream of data and make transmission more efficient.
Stream multiplexing makes it so that applications or protocols running on top of libp2p think that they’re the only ones running on that connection.
Another example is when HTTP/2 introduced streams into HTTP,
allowing for many HTTP requests in parallel on the same connection.

In summary, stream muxing can be used by applications on top of libp2p to share a single connection between various protocols,
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

Currently, libp2p supports two stream muxers, [mplex]({{< ref "/concepts/multiplex/mplex.md" >}})
and [yamux]({{< ref "/concepts/multiplex/yamux.md" >}}). However, many of the
[transport protocols]({{< ref "/concepts/transports/overview.md" >}}) available in the libp2p stack
come with native streams, such as [QUIC]({{< ref "/concepts/transports/quic.md" >}}),
[WebTransport]({{< ref "/concepts/transports/webtransport.md" >}}), and
[WebRTC]({{< ref "/concepts/transports/webrtc.md" >}}), and in these cases, libp2p
**does not need to perform stream multiplexing** as the protocol already provides it.
