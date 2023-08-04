---
title: "DCUtR"
description: "DCUtR is a protocol for establishing direct connections between nodes behind NATs."
weight: 210
---

## Background

Relays are used to traverse NATs by acting as proxies, but this can be expensive
to scale and maintain, and may result in low-bandwidth, high-latency
connections. [Hole punching](/concepts/nat/hole-punching) is another technique
that enables NAT traversal by enabling two nodes behind NATs to communicate
directly.  However, in addition to relay nodes, it requires another piece of
infrastructure called signaling servers.

> A signaling server is a server or service that facilitates communication
> between nodes in a P2P network, specifically in context of setting up,
> maintaining and terminating a direct communication channel between two peers
> which are behind NATs. It helps in discovering the external IP address and
> port of the peers and also in NAT traversal by relaying messages between the
> peers.

The good news is that libp2p offers a hole punching solution which eliminates
the need for centralized signaling servers and allows the use of distributed
relay nodes.

## What is Direct Connection Upgrade through Relay?

The libp2p DCUtR (Direct Connection Upgrade through Relay) is a protocol for
establishing direct connections between nodes through hole punching, without a
signaling server. DCUtR involves synchronizing and opening connections to each
peer's predicted external addresses.

The DCUtR protocol uses the protocol ID `/libp2p/dcutr` and involves the
exchange of `Connect` and `Sync` messages.

The DCUtR protocol supports different types of connections, such as TCP and
[QUIC](/concepts/transports/quic.md), the process of establishing a connection is
different for each type.

@Dennis-tra has a [great talk](https://www.youtube.com/watch?v=fyhZWlDbcyM) on
dctur and its holepunching success rates.

<!-- ADD DIAGRAMS -->

A helpful resource for understanding how NAT traversal works is [this blog post](https://tailscale.com/blog/how-nat-traversal-works/) by Tailscale.

{{< alert icon="💡" context="note" text="See the DCUtR <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/relay/DCUtR.md\">technical specification</a> for more details." />}}
