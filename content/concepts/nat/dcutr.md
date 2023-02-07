---
title: "DCUtR"
description: "DCUtR is a protocol for establishing direct connections between nodes behind NATs."
weight: 210
---

## Background

Relays are used to traverse NATs by acting as proxies, but this can be expensive to scale and
maintain, and may result in low-bandwidth, high-latency connections. [Hole punching](/concepts/nat/hole-punching)
is another technique that enables NAT traversal by enabling two nodes behind NATs to communicate directly.
However, in addition to relay nodes, it requires another piece of infrastructure called signaling servers (for [rendezvous](/concepts/discovery-routing/rendezvous.md) and synchronization).
> A signaling server is a server or service that facilitates communication between nodes in
> a P2P network, specifically in context of setting up, maintaining and terminating a direct
> communication channel between two peers which are behind NATs. It helps in discovering the
> external IP address and port of the peers and also in NAT traversal by relaying messages
> between the peers.

The good news is that libp2p offers a hole punching solution which eliminates not only the need for signaling servers but also allows the use of relay nodes to scale (by only relying on relay nodes temporarily).

## What is Direct Connection Upgrade through Relay?

The libp2p DCUtR (Direct Connection Upgrade through Relay) is a protocol for establishing direct
connections between nodes through hole punching, without a signaling server. DCUtR involves
synchronizing and opening connections to each peer's predicted external addresses.

The DCUtR protocol uses the protocol ID `/libp2p/dcutr` and involves the exchange of `Connect`
and `Sync` messages.

The protocol starts when one node, A, wants to connect to another node, B, behind a NAT,
and advertise relay addresses. If node A has public addresses advertised in its identify message
and B can initiate a unilateral upgrade to A, then the two nodes can establish a direct connection.
If the connection is unsuccessful, they can continue using the relay connection. Once the two nodes
have synchronized, they can simultaneously open a connection to each other's addresses, allowing
for successful hole punching.

The DCUtR protocol supports different types of connections, such as TCP and
[QUIC](../transports/quic.md), the process of establishing a connection is different for each type.
If a connection is successfully established, the nodes can upgrade to a direct connection.

In addition to the `Connect` and `Sync` messages, the protocol also includes `Close` messages,
which either node can send to close the connection and end the protocol. The protocol also
includes provisions for handling timeouts and errors.

<!-- ADD DIAGRAMS -->

A helpful resource for understanding how NAT traversal works is [this blog post](https://tailscale.com/blog/how-nat-traversal-works/) by Tailscale.

{{< alert icon="💡" context="note" text="See the DCUtR <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/relay/DCUtR.md\">technical specification</a> for more details." />}}
