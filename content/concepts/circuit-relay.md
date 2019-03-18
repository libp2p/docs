---
title: Circuit Relay
weight: 3
---

Circuit relay is a [transport protocol](/concepts/transport/) that routes traffic between two peers over a third-party "relay" peer.

In many cases, peers will be unable to [traverse their NAT](/concepts/nat/) in a way that makes them publicly accessible. Or they may not share common [transport protocols](/concepts/transport/) that would allow them to communicate directly.

To enable peer-to-peer architectures in the face of connectivity barriers like NAT, libp2p [defines a protocol called p2p-circuit][spec_relay]. When a peer isn't able to listen on a public address, it can dial out to a relay peer, which will keep a long-lived connection open. Other peers will be able to dial through the relay peer using a `p2p-circuit` address, which will forward traffic to its destination.

The circuit relay protocol is inspired by [TURN](https://tools.ietf.org/html/rfc5766), which is part of the [Interactive Connectivity Establishment](https://tools.ietf.org/html/rfc8445) collection of NAT traversal techniques.

{{% notice "note" %}}
Relay connections are end-to-end encrypted, which means that the peer acting as the relay is unable to read or tamper with any traffic that flows through the connection.
{{% /notice %}}

An important aspect of the relay protocol is that it is not "transparent". In other words, both the source and destination are aware that traffic is being relayed. This is useful, since the destination can see the relay address used to open the connection and can potentially use it to construct a path back to the source. It is also not anonymous - all participants are identified using their peer id, including the relay node.

#### Relay addresses

A relay circuit is identified using a [multiaddr][definition_muiltiaddress] that includes the [peer id](/concepts/peer-id/) of the peer whose traffic is being relayed (the listening peer or "relay target").

Let's say that I have a peer with the peer id `QmAlice`. I want to give out my address to my friend `QmBob`, but I'm behind a NAT that won't let anyone dial me directly.

The most basic `p2p-circuit` address I can construct looks like this:

`/p2p-circuit/p2p/QmAlice`

The address above is interesting, because it doesn't include any [transport](/concepts/transport/) addresses for either the peer we want to contact (`QmAlice`) or for the relay peer that will convey the traffic. Without that information, the only chance a peer has of dialing me is to discover a relay and hope they have a connection to me.

A better address would be something like `/p2p/QmRelay/p2p-circuit/p2p/QmAlice`. This includes the identity of a specific relay peer, `QmRelay`. If a peer already knows how to open a connection to `QmRelay`, they'll be able to reach us.

Better still is to include the transport addresses for the relay peer in the address. Let's say that I've established a connection to a specific relay with the peer id `QmRelay`. They told me via the identify protocol that they're listening for TCP connections on port `55555` at IPv4 address `7.7.7.7`. I can construct an address that describes a path to me through that specific relay over that transport:

`/ip4/7.7.7.7/tcp/55555/p2p/QmRelay/p2p-circuit/p2p/QmAlice`

Everything prior to the `/p2p-circuit/` above is the address of the relay peer, which includes the transport address and their peer id `QmRelay`. After `/p2p-circuit/` is the peer id for my peer at the other end of the line, `QmAlice`.

By giving the full relay path to my friend `QmBob`, they're able to quickly establish a relayed connection without having to "ask around" for a relay that has a route to `QmAlice`.

{{% notice "tip" %}}
When [advertising your address](/concepts/peer-routing/), it's best to provide relay addresses that include the transport address of the relay peer. If the relay has many transport addresses, you can advertise a `p2p-circuit` through each of them.
{{% /notice %}}

#### Autorelay

The circuit relay protocol is only effective if peers can discover willing relay peers that are accessible to both sides of the relayed connection.

While it's possible to simply "hard-code" a list of well-known relays into your application, this adds a point of centralization to your architecture that you may want to avoid. This kind of bootstrap list is also a potential point of failure if the bootstrap nodes become unavailable.

Autorelay is a feature (currently implemented in go-libp2p) that a peer can enable to attempt to discover relay peers using libp2p's [content routing](/concepts/content-routing/) interface.

When Autorelay is enabled, a peer will try to discover one or more public relays and open relayed connections. If successful, the peer will advertise the relay addresses using libp2p's [peer routing](/concepts/peer-routing/) system.

{{% notice "warning" %}}
Autorelay is under active development and should be considered experimental. There are currently no protections against malicious or malfunctioning relays which could advertise relay services and refuse to provide them.
{{% /notice %}}

##### How Autorelay works

The Autorelay service is responsible for:

1. discovering relay nodes around the world,
2. establishing long-lived connections to them, and
3. advertising relay-enabled addresses for ourselves to our peers, thus making ourselves routable through delegated routing.

When [AutoNAT service](/concepts/nat/#autonat) detects we're behind a NAT that blocks inbound connections, Autorelay jumps into action, and the following happens:

1. We locate candidate relays by running a DHT provider search for the `/libp2p/relay` namespace.
2. We select three results at random, and establish a long-lived connection to them (`/libp2p/circuit/relay/0.1.0` protocol). Support for using latency as a selection heuristic will be added soon.
3. We enhance our local address list with our newly acquired relay-enabled multiaddrs, with format: `/ip4/1.2.3.4/tcp/4001/p2p/QmRelay/p2p-circuit`, where:
   `1.2.3.4` is the relay's public IP address, `4001` is the libp2p port, and `QmRelay` is the peer ID of the relay.
   Elements in the multiaddr can change based on the actual transports at use.
4. We announce our new relay-enabled addresses to the peers we're already connected to via the `IdentifyPush` protocol.

The last step is crucial, as it enables peers to learn our updated addresses, and in turn return them when another peer looks us up.

[spec_relay]: https://github.com/libp2p/specs/tree/master/relay
[definition_muiltiaddress]: /reference/glossary/#mulitaddress
