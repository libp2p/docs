---
title: Introduction to libp2p Protocols
menuTitle: Protocols
weight: 1
---

This article is concerned with protocols that compose libp2p
using core libp2p abstractions like the [transport](/concepts/transport), 
[peer identity](/concepts/peers#peer-id/), [addressing](/concepts/addressing/) 
abstractions to name a few. 

## What is a libp2p protocol?

A libp2p protocol is a network protocol that includes
the key features mentioned below.

#### Protocol IDs

libp2p protocols have unique string identifiers, which are used in the 
[protocol negotiation](#protocol-negotiation) process when streams are first opened.

Historically, the IDs of many protocols in use by libp2p have a path-like structure, 
with a version number as the final component:

```
/my-app/amazing-protocol/1.0.1
```

Breaking changes to a protocol's wire format or semantics should result in a new 
version number. See the [protocol negotiation section](#protocol-neotiation) for more 
information about how version selection works during the dialing and listening.

#### Handler functions

A libp2p application will define a stream handler that takes over the 
stream after protocol negotiation. Everything sent and received after the
negotiation phase is then defined by the application protocol.

The handler function is invoked when an incoming stream is received with 
the registered protocol ID. If you register a handler with a 
[match function](#matching-protocol-ids-and-versions), you can choose whether
to accept non-exact string matches for protocol ids, for example, to match 
on [semantic major versions](#match-using-semver).

#### Binary streams

The "medium" over which a libp2p protocol transpires is a bi-directional binary stream 
with the following properties:

- Bidirectional, reliable delivery of binary data
  - Each side can read and write from the stream at any time
  - Data is read in the same order as it was written
  - Can be "half-closed", that is, closed for writing and open for reading, or closed 
    for reading and open for writing
- Supports backpressure
  - Eager writers can't flood readers

Behind the scenes, libp2p will also ensure that the stream is 
[secure](/concepts/secure-comms/) and efficiently
[multiplexed](/concepts/stream-multiplexing/). This is transparent to the protocol 
handler, which reads and writes unencrypted binary data over the stream.

The protocol determines the binary data format and the transport mechanics. 
For inspiration, some [common patterns](#common-patterns) that are used in libp2p's 
internal protocols are outlined below.

## Protocol Negotiation

When dialing out to initiate a new stream, libp2p sends the protocol ID of the 
protocol you want to use. The listening peer on the other end checks the incoming 
protocol ID against the registered protocol handlers.

If the listening peer does not support the requested protocol, it will send "na" on the stream
and the dialing peer can try again with a different protocol or possibly a fallback 
version of the initially requested protocol.

If the protocol is supported, the listening peer will echo back the protocol ID as 
a signal that future data sent over the stream will use the agreed protocol semantics.

This process of reaching an agreement about what protocol to use for a given stream 
or connection is called **protocol negotiation**.

### Matching protocol IDs and versions

There are different ways to register a protocol handler. For instance, a match function 
is a flexible method for protocol registration. A match function
takes three arguments: the protocol ID, a protocol match function, 
and the handler function as arguments.

### Dialing a specific protocol

When opening a new stream on a connection, the initiating peer sends the protocol 
ID it would like to use. The remote peer will use the matching logic described above to 
accept or reject the protocol. If the protocol is rejected, the dialing peer can try again.

When opening a new stream, the initiator can optionally provide a list of protocol IDs instead 
of a single ID. When you provide multiple protocol IDs, they will each is tried in succession, 
and the first successful match will be used if at least one of the protocols is supported by the 
remote peer. This can be useful if you support a range of protocol versions since you can 
propose the most recent version and fallback to older versions if the remote hasn't adopted 
the latest version yet.

## Core libp2p protocols

In addition to the protocols written when developing a libp2p application, libp2p defines 
several foundational protocols used for core features.

### Common patterns

The protocols described below all use 
[protocol buffers](https://developers.google.com/protocol-buffers/) 
(aka protobuf) to define message schemas.

Messages are exchanged over the wire using a straightforward convention that prefixes 
binary message payloads with an integer representing the payload's length in bytes. The
length is encoded as a 
[protobuf varint](https://developers.google.com/protocol-buffers/docs/encoding#varints) 
(variable-length integer).

### Protocol list

{{% notice "note" %}}
Check out the [libp2p implementations page](https://libp2p.io/implementations/) for 
updates on all the libp2p implementations.
{{% /notice %}}

| **Specification**                                                                          | **Protocol ID**                    |
|--------------------------------------------------------------------------------------------|------------------------------------|
| [AutoNAT](https://github.com/libp2p/specs/blob/master/autonat/README.md#autonat-protocol)  | `/libp2p/autonat/1.0.0`            |
| [Circuit Relay v2 (hop) ](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md) | `/libp2p/circuit/relay/0.2.0/hop`  |
| [Circuit Relay v2 (stop)](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md) | `/libp2p/circuit/relay/0.2.0/stop` |
| [DCUtR](https://github.com/libp2p/specs/blob/master/relay/DCUtR.md)                        | `/libp2p/dcutr/1.0.0`              |
| [Fetch](https://github.com/libp2p/specs/tree/master/fetch)                                 | `/libp2p/fetch/0.0.1`              |
| [GossipSub v1.0](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub)             | `/libp2p/gossipsub/1.0.0`          |
| [GossipSub v1.1](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub)             | `/libp2p/gossipsub/1.1.0`          |
| [Identify](https://github.com/libp2p/specs/blob/master/identify/README.md)                 | `/ipfs/id/1.0.0`                   |
| [Identify (push)](https://github.com/libp2p/specs/blob/master/identify/README.md)          | `/ipfs/id/push/1.0.0`              |
| [Kademlia DHT](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)              | `/ipfs/kad/1.0.0`                  |
| Ping                                                                                       | `/ipfs/ping/1.0.0`                 |
| [Rendezvous](https://github.com/libp2p/specs/blob/master/rendezvous/README.md)             | `/libp2p/rendezvous/1.0.0`         |
