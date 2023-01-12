---
title: "What is a libp2p Protocol"
description: "There are protocols everywhere you look when you're writing network applications, and libp2p is especially thick with them."
weight: 20
aliases:
    - "/concepts/protocols"
    - "/concepts/fundamentals/protocols"
---

libp2p is composed of various core abstractions, such as
[peer identity](../core-abstractions/peers.md#peer-id),
and [addressing](../core-abstractions/addressing.md/), and
relies on protocols to facilitate communication between peers.
These protocols are networking protocol that follows certain conventions
to allow for peer-to-peer networking.

### Protocol IDs

Each protocol has a unique string identifier called a protocol ID,
which negotiates the use of the protocol during the establishment
of a new stream between two peers.

Protocol IDs typically follow a path-like structure with a version number
as the final component.

```shell
/my-app/amazing-protocol/1.0.1
```

A new stream passes through a protocol multiplexer called
[Multistream-select](multistream.md), which routes the stream to the appropriate
protocol handler based on the protocol ID.

### Handler functions

A handler function handles each libp2p protocol, responsible
for defining the protocol's behavior once the stream has been established.
The handler function is invoked when an incoming stream is received with a
registered protocol ID.

The handler function can also specify a match function,
which allows for the acceptance of non-exact string matches for protocol IDs.

A libp2p application will define a stream handler that takes over the
stream after protocol negotiation. Everything is sent and received after the
application protocol defines the negotiation phase.

### Binary streams

The medium over which a protocol operates is a bi-directional
binary stream. This stream provides the following features:

- **Bidirectional, reliable delivery of binary data**: Both peers can read and write
  from the stream at any time, and data is read in the same order as it was written.
  The stream can also be "half-closed", meaning it can be closed for writing while
  still open for reading or closed for reading while still open for writing.
- **Supports backpressure**: Eager writers cannot flood readers with data, as the
  stream automatically regulates data flow to prevent overload.

Behind the scenes, libp2p also ensures that the stream is securely encrypted and
efficiently multiplexed, allowing multiple logical streams to be multiplexed over
a single underlying connection. These details are transparent to the protocol handler,
which reads and writes unencrypted binary data over the stream.

## Life cycle of a stream

The life cycle of a libp2p stream involves the following steps:

- **Dialing out**: When a peer wants to initiate a new stream with another peer,
  it sends the protocol ID of the protocol it wants to use over the connection.
- **Protocol negotiation**: The listening peer on the other end checks the incoming
  protocol ID against its list of registered protocol handlers. Suppose it does not
  support the requested protocol. In that case, it sends "na" (not available) on the stream.
  The dialing peer can try again with a different protocol or a fallback
  version of the initially requested protocol. If the protocol is supported, the
  listening peer echoes the protocol ID as a signal that future data sent over
  the stream will use the agreed-upon protocol semantics.
- **Stream establishment**: Once peers agree on the protocol ID, the stream is
  established, and the designated invokes the handler function to take over the stream.
  Everything sent and received over the stream from this point on is defined by the
  application-level protocol.
- **Stream closure**: When either peer finishes using the stream, it can be closed
  by either side. If the stream is half-closed, the other side can continue to read
  or write until it is closed.

## Core libp2p protocols

In addition to the protocols written when developing a libp2p application, libp2p defines
several foundational protocols used for core features.

{{< alert icon="" context="note">}}
Check out the [libp2p implementations page](https://libp2p.io/implementations/) for
updates on all the libp2p implementations.
{{< /alert >}}

| **Specification**                                                                          | **Protocol ID**                    |
|--------------------------------------------------------------------------------------------|------------------------------------|
| [AutoNAT](https://github.com/libp2p/specs/blob/master/autonat/README.md#autonat-protocol)  | `/libp2p/autonat/1.0.0`            |
| [Circuit Relay v2 (hop)](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md) | `/libp2p/circuit/relay/0.2.0/hop`  |
| [Circuit Relay v2 (stop)](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md) | `/libp2p/circuit/relay/0.2.0/stop` |
| [DCUtR](https://github.com/libp2p/specs/blob/master/relay/DCUtR.md)                        | `/libp2p/dcutr/1.0.0`              |
| [Fetch](https://github.com/libp2p/specs/tree/master/fetch)                                 | `/libp2p/fetch/0.0.1`              |
| [GossipSub v1.0](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub)             | `/libp2p/gossipsub/1.0.0`          |
| [GossipSub v1.1](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub)             | `/libp2p/gossipsub/1.1.0`          |
| [Identify](https://github.com/libp2p/specs/blob/master/identify/README.md)                 | `/ipfs/id/1.0.0`                   |
| [Identify (push)](https://github.com/libp2p/specs/blob/master/identify/README.md)          | `/ipfs/id/push/1.0.0`              |
| [Kademlia DHT](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)              | `/ipfs/kad/1.0.0`                  |
| [Ping](https://github.com/libp2p/specs/blob/master/ping/ping.md)                                                                                       | `/ipfs/ping/1.0.0`                 |
| [Rendezvous](https://github.com/libp2p/specs/blob/master/rendezvous/README.md)             | `/libp2p/rendezvous/1.0.0`         |
