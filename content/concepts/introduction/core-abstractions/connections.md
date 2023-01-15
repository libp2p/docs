---
title: "Connections"
description: "A libp2p connection allows two peers to read and write data to each other."
weight: 33
---

## Background

A libp2p connection allows two peers to read and write data to each other.
Peers connect over [transport protocols](../transports/overview.md), which are
core abstractions of libp2p and offer extensibility.
This document does not cover establishing "transport level" connections, for example,
opening "raw" TCP sockets, as those semantics are specific to each transport. Rather,
this document explains the process that occurs after making the initial transport-level
connection, up to the point where "application level" streams are opened.
Learn about transport protocols in libp2p in the [transport section](../transports/overview/).

## Life of a libp2p connection

The following points present an overview for a standard libp2p connection; we'll then dive
more into the various components later in the document.

- A libp2p node (peer) initiates a connection with another node by sending
  a request over the underlying transport protocol (e.g., TCP). This request
  is referred to as "dialing", and the peer is referred to as the "dialer."
- The receiving node, known as the "listener", accepts the incoming connection
  request and responds with a handshake message to initiate the protocol negotiation
  process.
- Both nodes exchange protocol information and select the protocols to use for the
  connection, including protocols for [security](../secure-comm/overview.md) and
  [stream multiplexing](../multiplex/overview.md) if necessary.
  The [multistream-select](https://github.com/multiformats/multistream-select) is used
  for this negotiation process.
- If the underlying transport protocol does not natively support security and multiplexing,
  a connection upgrade is performed to add these capabilities to the raw transport connection.
- The peers may use NAT traversal techniques such as
  [UPnP](https://en.wikipedia.org/wiki/Universal_Plug_and_Play) or
  [hole punching](../nat/hole-punching.md) to allow nodes behind NAT devices to establish
  connections.
- Once the connection is established, and protocols are selected, the nodes can open multiple
  streams over the connection for various interactions, each using its own protocol.
- Data is exchanged over the streams using the negotiated protocols.
- Based on the transport being used, when a node wants to close the connection or a stream,
  it can send a "close" message to the other.
  node, which responds with an "acknowledgment" message.
- Once both nodes have sent and received the close message and acknowledgment, the connection
  or stream is closed.

### Connection and stream management

libp2p handles the management of connections and streams in a few ways:

- **Tracking**: libp2p keeps track of which connections and streams are open and updates
  this information as connections and streams are opened or closed.
- **Timeouts and retries**: When a connection or stream fails, the application would be notified
  and it is expected to handle the reconnection process. It is possible to handle the reconnection
  logic by writing a custom reconnection manager. This manager can listen for closed stream events,
  and when a stream is closed, it can attempt to reconnect to the peer. Additionally, you can add
  your own retry and timeout logic.
- **Opening and closing**: libp2p applications can specify when to open and close connections
  and streams based on their specific requirements. For example, an application may open a new
  stream for each file transfer rather than reusing a single stream.
  > Implementations may include a connection manager (like in go-libp2p), which is is responsible
  > for maintaining the number of connections to other peers within a specific range, known as the
  > low and high watermark. The low watermark is the minimum number of connections that the connection
  > manager tries to maintain, while the high watermark is the maximum number of connections that the
  > connection manager allows.
  > There is also functionality for connection protection, which is used to protect certain connections
  > from being closed by the connection manager. When a connection is protected, the connection manager
  > will not close it, even if the number of connections exceeds the high watermark. This allows for
  > important connections, such as those used for critical communication or for relaying traffic, to be
  > preserved.

### NAT traversal

NAT traversal allows nodes behind NAT devices (e.g., routers) to establish connections with
nodes on the public internet or other nodes behind NATs. Some transport protocols and connection
upgrade protocols in libp2p have built-in NAT traversal capabilities, while others require additional
mechanisms such as UPnP or hole punching. Learn more about NAT traversal in the
[NAT section](../nat/overview.md).

### Multiplexing and performance

Stream multiplexing allows multiple streams to share a single connection, which can be more
efficient than opening a separate connection for each stream. This can be especially helpful
in applications that simultaneously maintain many connections or streams, such as a peer-to-peer
file-sharing application. Multiplexing also allows for better utilization of network resources
and can improve overall performance. For example, if one stream is idle while another stream
is receiving a burst of data, the idle stream will not block the active stream from using the
connection.

### Protocol support

libp2p supports a variety of protocols for security and stream multiplexing, including:

- Security protocols:
  - [noise](../../secure-comm/noise.md): Provides encryption, authentication, and forward secrecy for libp2p connections.
  - [tls](../../secure-comm/tls.md): Provides encryption, authentication, and forward secrecy for libp2p connections.

Learn more about secure connections in the
[secure communications section](../secure-comm/overview.md).

- Stream multiplexing protocols:
  - [yamux](../../multiplex/yamux.md): Provides multiplexing of streams over a single connection and backpressue.
  - [mplex](../../multiplex/mplex.md): Provides multiplexing of streams over a single connection.

Learn more about multiplexing in the
[stream multiplexing section](../multiplex/overview.md).

New protocols can be added to libp2p as needed. When adding a new protocol, it is
important to consider compatibility with existing protocols, performance, and security.

### Upgrading connections

libp2p is designed to support a variety of transport protocols, including those that do
not natively support the core libp2p capabilities of security and stream multiplexing.
The process of layering capabilities onto "raw" transport connections is known as
"upgrading" the connection.

Eventually, the listener's multiaddr will determine the security protocol to be used on a
connection ([see the specification](https://github.com/libp2p/specs/pull/353)). The
multiplexing protocol is determined using protocol negotiation, with the multistream-select
protocol used for this negotiation process (as described in the
[Protocol Negotiation section](#protocol-negotiation)). When raw connections need both
security and multiplexing, security is always established first, and the negotiation for
stream multiplexing takes place over the encrypted channel.

Here is an example of the connection upgrade process:

- The dialing peer sends a request to initiate a connection to the listening
  peer over the underlying transport protocol (e.g., TCP).
- The listening peer accepts the incoming connection request and sends the security
  protocol ID (e.g., Noise) using multistream-select to indicate the security protocol
  to use.
- The dialing peer responds with the security handshake message to initiate the Noise
  protocol.
- If the security handshake is successful, the peers exchange the multistream protocol
  ID to establish that they will use multistream-select to negotiate protocols for the
  connection upgrade.
- The peers negotiate which stream multiplexer to use by proposing and responding with
  protocol IDs. If a proposed multiplexer is unsupported, the listening peer responds
  with "na". In some cases, the peer may include the stream muxer in the security handshake to
  save this roundtrip. This is known as
  [early multiplexer negotiation](../../multiplex/early-negotiation).
- Once security and stream multiplexing are established, the connection upgrade process
  is complete, and both peers can use the resulting libp2p connection to open new secure
  multiplexed streams.

> In the case where both peers initially act as initiators, e.g., during NAT hole punching,
> tie-breaking is done via the
> [multistream-select](https://github.com/libp2p/specs/tree/master/connections#multistream-select)
> simultaneous open protocol extension.

### Protocol negotiation

One of libp2p's core design goals is to be adaptable to many network environments,
including those that still need to be created. To provide this flexibility, the connection
upgrade process supports multiple protocols for connection security and stream multiplexing
and allows peers to select which to use for each connection.

The process of selecting protocols is called protocol negotiation. In addition to its role in
the connection upgrade process, protocol negotiation is used whenever a new stream is opened
over an existing connection. This allows libp2p applications to route application-specific
protocols to the correct handler functions.

Each protocol supported by a peer is identified using a unique string called a protocol ID.
While any string can be used, the conventional format is a path-like structure containing a
short name and a version number, separated by "/" characters.

For example: `/yamux/1.0.0` identifies version `1.0.0` of yamux. multistream-select itself has
a protocol ID of `/multistream/1.0.0`. Including a version number in the protocol ID simplifies
the case where you want to concurrently support multiple protocol versions, perhaps a stable
version and an in-development version. By default, libp2p peers should support the latest protocol
version, but they may also choose to support older versions for compatibility. More information on
protocols is available on the [protocols document](protocols.md).

Protocol negotiation works by one peer sending a message containing the protocol ID of the
protocol it wishes to use, and the other either echoing back the same ID if it supports
the protocol or sending a different ID if it does not. This process continues until both
peers agree on a common protocol to use or determine that no common protocol is available.

For example, consider a case where two libp2p nodes are attempting to upgrade a
raw transport connection to a secure libp2p connection using the Noise protocol:

- The dialing peer sends a message containing the protocol ID `/noise/1.0.0` to
  indicate its desire to use the Noise protocol.
- The listening peer supports the Noise protocol, which echoes the same protocol ID.
- Both peers perform the Noise handshake to establish a secure connection.

> If the listening peer did not support the Noise protocol, it would have responded
> with "na" to indicate that no common protocol could be found. The dialing peer could
> then try a different protocol or terminate the connection attempt. More details are
> available [here](https://github.com/libp2p/specs/tree/master/connections#multistream-select).

### Opening new streams over a connection

Once a libp2p connection is established, either through a new connection or
by upgrading a raw transport connection, new streams can be opened over the
connection as needed. The protocol negotiation process described above is used to
identify the protocol for each stream and route the stream data to the appropriate
handler functions.

For example, consider a libp2p node that wants to send a file to another node over
a libp2p connection. The sending node might open a new stream and negotiate the
`/filetransfer/1.0.0` protocol with the receiving node to handle the file transfer.
The receiving node would then route the stream data to its file transfer handler
function.

### Closing connections and streams

Connections and streams can be closed by the dialing or listening node by sending
a close message. The close message indicates that the sender will not send more data
on the connection or stream, but it may still receive data until the other peer
closes the connection or stream. Once both peers have closed a connection or stream,
the connection or stream is considered fully closed, and all resources can be released.

{{< alert icon="" context="">}}
It is important to properly close connections and streams to free up resources and avoid
resource leaks. However, it is also essential to implement timeouts and retries to handle
cases where a close message may not be received due to network issues.
{{< /alert >}}

{{< alert icon="💡" context="note" text="See the connections <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/connections\">technical specification</a> for more details." />}}
