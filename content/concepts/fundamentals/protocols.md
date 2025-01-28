---
title: "Protocols"
description: There are protocols everywhere you look when you're writing network applications, and libp2p is especially thick with them.
weight: 50
aliases:
    - "/concepts/protocols"
    - "/concepts/fundamentals/protocols"
---

There are protocols everywhere you look when you're writing network applications, and libp2p is
especially thick with them.

The kind of protocols this article is concerned with are the ones built with libp2p itself,
using the core libp2p abstractions like [transport]({{< relref "/concepts/transports/overview.md" >}}), [peer identity]({{< relref "/concepts/fundamentals/peers.md#peer-id" >}}), [addressing]({{< relref "/concepts/fundamentals/addressing.md" >}}), and so on.

Throughout this article, we'll call this kind of protocol that is built with libp2p
a **libp2p protocol**, but you may also see them referred to as "wire protocols" or "application protocols".

These are the protocols that define your application and provide its core functionality.

This article will walk through some of the key [defining features of a libp2p protocol](#what-is-a-libp2p-protocol), give an overview of the [protocol negotiation process](#protocol-negotiation), and outline some of the [core libp2p protocols](#core-libp2p-protocols) that are included with libp2p and provide key functionality.

## What is a libp2p protocol?

A libp2p protocol has these key features:

### Protocol IDs

libp2p protocols have unique string identifiers, which are used in the [protocol negotiation](#protocol-negotiation) process when connections are first opened.

By convention, protocol ids have a path-like structure, with a version number as the final component:

```shell
/my-app/amazing-protocol/1.0.1
```

Breaking changes to your protocol's wire format or semantics should result in a new version
number. See the [protocol negotiation section](#protocol-negotiation) for more information about
how version selection works during the dialing and listening process.

{{< alert icon="💡" context="info">}}
While libp2p will technically accept any string as a valid protocol id,
using the recommended path structure with a version component is both
developer-friendly and enables [easier matching by version](#match-using-semver).
{{< /alert >}}

#### Handler functions

To accept connections, a libp2p application will register handler functions for protocols using their protocol id with the
[switch][definition_switch] (aka "swarm"), or a higher level interface such as [go's Host interface](https://github.com/libp2p/go-libp2p/blob/master/core/host/host.go).

The handler function will be invoked when an incoming stream is tagged with the registered protocol id.
If you register your handler with a [match function](#using-a-match-function), you can choose whether
to accept non-exact string matches for protocol ids, for example, to match on [semantic major versions](#match-using-semver).

#### Binary streams

The "medium" over which a libp2p protocol transpires is a bi-directional binary stream with the following
properties:

- Bidirectional, reliable delivery of binary data
  - Each side can read and write from the stream at any time
  - Data is read in the same order as it was written
  - Can be "half-closed", that is, closed for writing and open for reading, or closed for reading and open for writing
- Supports backpressure
  - Readers can't be flooded by eager writers <!-- TODO(yusef) elaborate: how is backpressure implemented? is it transport-depdendent? -->

Behind the scenes, libp2p will also ensure that the stream is [secure]({{< relref "/concepts/secure-comm/overview.md" >}}) and efficiently
[multiplexed]({{< relref "/concepts/multiplex/overview.md" >}}). This is transparent to the protocol handler, which reads and writes
unencrypted binary data over the stream.

The format of the binary data and the mechanics of what to send when and by whom are all up to the protocol to determine. For inspiration, some [common patterns](#common-patterns) that are used in libp2p's internal protocols are outlined below.

## Protocol Negotiation

When dialing out to initiate a new stream, libp2p will send the protocol id of the protocol you want to use.
The listening peer on the other end will check the incoming protocol id against the registered protocol handlers.

If the listening peer does not support the requested protocol, it will end the stream, and the dialing peer can
try again with a different protocol, or possibly a fallback version of the initially requested protocol.

If the protocol is supported, the listening peer will echo back the protocol id as a signal that future data
sent over the stream will
use the agreed protocol semantics.

This process of reaching agreement about what protocol to use for a given stream or connection is called
**protocol negotiation**.

### Matching protocol ids and versions

When you register a protocol handler, there are two methods you can use.

The first takes two arguments: a protocol id, and a handler function. If an incoming stream request sends an exact
match for the protocol id, the handler function will be invoked with the new stream as an argument.

#### Using a match function

The second kind of protocol registration takes three arguments: the protocol id, a protocol match function, and the handler function.

When a stream request comes in whose protocol id doesn't have any exact matches, the protocol id will be passed through
all of the registered match functions. If any returns `true`, the associated handler function will be invoked.

This gives you a lot of flexibility to do your own "fuzzy matching" and define whatever rules for protocol matching
make sense for your application.

### Dialing a specific protocol

When dialing a remote peer to open a new stream, the initiating peer sends the protocol id that they'd like to use. The remote peer will use
the matching logic described above to accept or reject the protocol. If the protocol is rejected, the dialing peer can try again.

When dialing, you can optionally provide a list of protocol ids instead of a single id. When you provide multiple protocol ids, they will
each be tried in succession, and the first successful match will be used if at least one of the protocols is supported by the remote peer.
This can be useful if you support a range of protocol versions, since you can propose the most recent version and fallback to older versions
if the remote hasn't adopted the latest version yet.

## Core libp2p protocols

In addition to the protocols that you write when developing a libp2p application, libp2p itself defines several foundational protocols that are used for core features.

### Common patterns

The protocols described below all use [protocol buffers](https://developers.google.com/protocol-buffers/) (aka protobuf) to define message schemas.

Messages are exchanged over the wire using a very simple convention which prefixes binary
message payloads with an integer that represents the length of the payload in bytes. The
length is encoded as a [protobuf varint](https://developers.google.com/protocol-buffers/docs/encoding#varints) (variable-length integer).

### Ping

| **Protocol id**    | spec |               |               | implementations   |
|--------------------|------|---------------|---------------|-------------------|
| `/ipfs/ping/1.0.0` | N/A  | [go][ping_go] | [js][ping_js] | [rust][ping_rust] |

[ping_go]: https://github.com/libp2p/go-libp2p/tree/master/p2p/protocol/ping
[ping_js]: https://github.com/libp2p/js-libp2p-ping
[ping_rust]: https://github.com/libp2p/rust-libp2p/blob/master/protocols/ping/src/lib.rs

The libp2p ping protocol is a simple liveness check that peers can use to test
the connectivity and performance between two peers. The libp2p ping protocol
is different from the ping command line utility
([ICMP ping](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol)),
as it requires an already established libp2p connection.

> ICMP Ping is a network utility that uses ICMP packets to
> check the connectivity and latency between two networked devices.
> It is typically used to check the reachability of a host on an IP network and
> to measure the round-trip time for messages sent from the originating host to a
> destination host.

A peer opens a new stream on an existing libp2p connection and sends a ping request with a random 32 byte payload. The receiver echoes these 32 bytes back on the same stream. By measuring the time between the
request and response, the initiator can calculate the round-trip time of the underlying libp2p connection.
The stream can be reused for future pings from the initiator.

#### Example

[Kubo](https://github.com/ipfs/kubo) exposes a command line interface to ping other peers, which uses the libp2p ping protocol.

```shell
ipfs ping /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping

PING /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping (QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG)
32 bytes from QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG: time=11.34ms
```

{{< alert icon="💡" context="note" text="See the ping <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/ping/ping.md\">technical specification</a> for more details." />}}


### Identify

| **Protocol id**  | spec                           |                   |                   | implementations       |
|------------------|--------------------------------|-------------------|-------------------|-----------------------|
| `/ipfs/id/1.0.0` | [identify spec][spec_identify] | [go][identify_go] | [js][identify_js] | [rust][identify_rust] |

<!-- TODO(yusef): update spec link on PR merge -->
[spec_identify]: https://github.com/libp2p/specs/pull/97/files
[identify_go]: https://github.com/libp2p/go-libp2p/tree/master/p2p/protocol/identify
[identify_js]: https://github.com/libp2p/js-libp2p-identify
[identify_rust]: https://github.com/libp2p/rust-libp2p/tree/master/protocols/identify/src

The `identify` protocol allows peers to exchange information about each other, most notably their public keys
and known network addresses.

The basic identify protocol works by establishing a new stream to a peer using the identify protocol id
shown in the table above.

When the remote peer opens the new stream, they will fill out an [`Identify` protobuf message][identify_proto] containing
information about themselves, such as their public key, which is used to derive their [`PeerId`]({{< relref "/concepts/fundamentals/peers.md" >}}).

Importantly, the `Identify` message includes an `observedAddr` field that contains the [multiaddr][definition_multiaddr] that
the peer observed the request coming in on. This helps peers determine their NAT status, since it allows them to
see what other peers observe as their public address and compare it to their own view of the network.

[identify_proto]: https://github.com/libp2p/go-libp2p/blob/master/p2p/protocol/identify/pb/identify.proto

#### identify/push

| **Protocol id**       | spec & implementations              |
|-----------------------|-------------------------------------|
| `/ipfs/id/push/1.0.0` | same as [identify above](#identify) |

A slight variation on `identify`, the `identify/push` protocol sends the same `Identify` message, but it does so proactively
instead of in response to a request.

This is useful if a peer starts listening on a new address, establishes a new [relay circuit]({{< relref "/concepts/nat/circuit-relay.md" >}}), or
learns of its public address from other peers using the standard `identify` protocol. Upon creating or learning of a new address,
the peer can push the new address to all peers it's currently aware of. This keeps everyone's routing tables up to date and
makes it more likely that other peers will discover the new address.

### kad-dht

`kad-dht` is a [Distributed Hash Table][wiki_dht] based on the [Kademlia][wiki_kad] routing algorithm, with some modifications.

libp2p uses the DHT as the foundation of its [routing]({{< relref "/concepts/discovery-routing/overview.md" >}}) functionality. To learn more about DHT and the Kademlia algorithm,
check out the [Distributed Hash Tables guide][dht] on the IPFS documentation site. In addition, check out the [libp2p implementations page](https://libp2p.io/implementations/) for updates on all the kad-libp2p implementations.

<!-- Consider adding general kad matrix on implementations page, then link -->

[wiki_dht]: https://en.wikipedia.org/wiki/Distributed_hash_table
[wiki_kad]: https://en.wikipedia.org/wiki/Kademlia
[dht]: https://docs.ipfs.tech/concepts/dht/

### Circuit Relay

| **Protocol id**               | spec                             |                | implementations |
|-------------------------------|----------------------------------|----------------|-----------------|
| `/libp2p/circuit/relay/0.1.0` | [circuit relay spec][spec_relay] | [go][relay_go] | [js][relay_js]  |

[spec_relay]: https://github.com/libp2p/specs/tree/master/relay
[relay_js]: https://github.com/libp2p/js-libp2p-circuit
[relay_go]: https://github.com/libp2p/go-libp2p-circuit

As described in the [Circuit Relay article]({{< relref "/concepts/nat/circuit-relay.md" >}}), libp2p provides a protocol
for tunneling traffic through relay peers when two peers are unable to connect to each other
directly. See the article for more information on working with relays, including notes on relay
addresses and how to enable automatic relay connection when behind an intractable NAT.

[definition_switch]: /concepts/appendix/glossary#switch
[definition_multiaddr]: /concepts/appendix/glossary#multiaddr
