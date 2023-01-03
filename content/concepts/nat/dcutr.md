---
title: "DCUtR"
description: "DCUtR is a protocol for establishing direct connections between nodes behind NATs."
weight: 210
aliases:
    - "/concepts/circuit-relay"
    - "/concepts/nat/circuit-relay"
---

## Background

Relays can be used to traverse NATs by acting as proxies, but this can be expensive to scale and
maintain, and may result in low-bandwidth, high-latency connections. [Hole punching](hole-punching.md)
is a technique that allows two nodes behind NATs to communicate directly, but it requires rendezvous
and synchronization, which can be accomplished using signaling servers.

## What is Direct Connection Upgrade through Relay?

The libp2p DCUtR (Direct Connection Upgrade through Relay) is a protocol for establishing direct
connections between nodes through hole punching, without a signaling server.
DCUtR involves synchronizing and opening connections to each peer's predicted external addresses.

The DCUtR protocol uses the protocol ID `/libp2p/dcutr` and involves the exchange of `Connect` and
`Sync` messages.

The protocol starts when one node, A, wants to connect to another node, B, behind a NAT and advertises
relay addresses. If node A has public addresses advertised in its identify message and B can initiate a
unilateral upgrade to A, then the two nodes can establish a direct connection. If the unilateral
connection upgrade fails or A is a NATed node without public addresses, then B initiates the DCUtR
protocol.

The DCUtR protocol involves the exchange of `Connect` and `Sync` messages between A and B. Node B also
measures the RTT of the relay connection between the two nodes. If the connection is successful, A and B
can upgrade to a direct connection and close the relay connection. If the connection is unsuccessful,
they can continue using the relay connection. Once the two nodes have synchronized, they can simultaneously
open a connection to each other's addresses, allowing for successful hole punching.

The DCUtR protocol supports TCP and QUIC connections with slightly different procedures. For TCP
connections, nodes A and B initiate simultaneous dials to each other's addresses. For QUIC connections,
node B sends repeated packets filled with random bytes to node A's address while node A dials node B's
address. If either node successfully establishes a connection to the other, they can upgrade to a direct
connection.

In addition to the `Connect` and `Sync` messages, the protocol also includes `Close` messages, which
either node can send to close the connection and end the protocol. The protocol also includes provisions
for handling timeouts and errors.

<!-- ADD DIAGRAMS -->

{{< alert icon="💡" context="note" text="See the DCUtR <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/relay/DCUtR.md\">technical specification</a> for more details." />}}
