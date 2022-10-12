---
title: Circuit Relay
weight: 3
---

Circuit relay is a [transport protocol](/concepts/transport/) that routes traffic between two peers over a third-party "relay" peer.

In many cases, peers will be unable to [traverse their NAT and/or firewall](/concepts/nat/) in a way that makes them publicly accessible. Or they may not share common [transport protocols](/concepts/transport/) that would allow them to communicate directly.

To enable peer-to-peer architectures in the face of connectivity barriers like NAT, libp2p [defines a protocol called p2p-circuit][spec_relay]. When a peer isn't able to listen on a public address, it can dial out to a relay peer, which will keep a long-lived connection open. Other peers will be able to dial through the relay peer using a `p2p-circuit` address, which will forward traffic to its destination.

The circuit relay protocol is inspired by [TURN](https://tools.ietf.org/html/rfc5766), which is part of the [Interactive Connectivity Establishment](https://tools.ietf.org/html/rfc8445) collection of NAT traversal techniques.

{{% notice "note" %}}
Relay connections are end-to-end encrypted, which means that the peer acting as the relay is unable to read or tamper with any traffic that flows through the connection.
{{% /notice %}}

An important aspect of the relay protocol is that it is not "transparent". In other words, both the source and destination are aware that traffic is being relayed. This is useful, since the destination can see the relay address used to open the connection and can potentially use it to construct a path back to the source. It is also not anonymous - all participants are identified using their Peer ID, including the relay node.

#### Protocol Versions

Today there are two versions of the circuit relay protocol, [v1](https://github.com/libp2p/specs/blob/master/relay/circuit-v1.md) and [v2](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md). We recommend using the latter over the former. See the [circuit relay v2 specification](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md#introduction) for a detailed comparison of the two. If not explicitly noted, this document describes the circuit relay v2 protocol.

#### Relay addresses

A relay circuit is identified using a [multiaddr][definition_muiltiaddress] that includes the [Peer ID](/concepts/peers/) of the peer whose traffic is being relayed (the listening peer or "relay target").

Let's say that I have a peer with the Peer ID `QmAlice`. I want to give out my address to my friend `QmBob`, but I'm behind a NAT that won't let anyone dial me directly.

The most basic `p2p-circuit` address I can construct looks like this:

`/p2p-circuit/p2p/QmAlice`

The address above is interesting, because it doesn't include any [transport](/concepts/transport/) addresses for either the peer we want to contact (`QmAlice`) or for the relay peer that will convey the traffic. Without that information, the only chance a peer has of dialing me is to discover a relay and hope they have a connection to me.

A better address would be something like `/p2p/QmRelay/p2p-circuit/p2p/QmAlice`. This includes the identity of a specific relay peer, `QmRelay`. If a peer already knows how to open a connection to `QmRelay`, they'll be able to reach us.

Better still is to include the transport addresses for the relay peer in the address. Let's say that I've established a connection to a specific relay with the Peer ID `QmRelay`. They told me via the identify protocol that they're listening for TCP connections on port `55555` at IPv4 address `7.7.7.7`. I can construct an address that describes a path to me through that specific relay over that transport:

`/ip4/7.7.7.7/tcp/55555/p2p/QmRelay/p2p-circuit/p2p/QmAlice`

Everything prior to the `/p2p-circuit/` above is the address of the relay peer, which includes the transport address and their Peer ID `QmRelay`. After `/p2p-circuit/` is the Peer ID for my peer at the other end of the line, `QmAlice`.

By giving the full relay path to my friend `QmBob`, they're able to quickly establish a relayed connection without having to "ask around" for a relay that has a route to `QmAlice`.

{{% notice "tip" %}}
When [advertising your address](/concepts/peer-routing/), it's best to provide relay addresses that include the transport address of the relay peer. If the relay has many transport addresses, you can advertise a `p2p-circuit` through each of them.
{{% /notice %}}

#### Process

The below sequence diagram depicts a sample relay process:

![Circuit v2 Protocol Interaction](https://raw.githubusercontent.com/libp2p/specs/master/relay/circuit-v2.svg)

1. Node `A` is behind a NAT and/or firewall, e.g. detected via the [AutoNAT service](/concepts/nat/#autonat).
2. Node `A` therefore requests a reservation with relay `R`. I.e. node `A` asks relay `R` to listen for incoming connections on its behalf.
3. Node `B` wants to establish a connection to node `A`. Given that node `A` does not advertise any direct addresses but only a relay address, node `B` connects to relay `R`, asking relay `R` to relay a connection to `A`.
4. Relay `R` forwards the connection request to node `A` and eventually relays all data send by `A` and `B`.

[spec_relay]: https://github.com/libp2p/specs/tree/master/relay
[definition_muiltiaddress]: /reference/glossary/#mulitaddress
