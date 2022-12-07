---
title: "Ping"
description: "The ping protocol is a simple request response protocol."
weight: 20
---

## What is Ping?

Ping is a network utility used to test a node's reachability.
The ping protocol measures the RTT for requests sent from an
originating node to a destination node by echoing a request payload.
This operates using
[ICMP (Internet Control Message Protocol)](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol). Ping can also be a simple liveness check that peers can use to quickly
see if another peer is online and measure RTT.

> The difference is that ICMP ping uses an echo request (ICMP type 8) packet
> to ping a node and receive an echo reply (type 0) packet, whereas a non-ICMP ping
> sends a packet based on the connection (e.g., TCP) to a node to receive
> a response packet of some kind.

## Ping in libp2p

The ping protocol in libp2p is non-ICMP and serves as a health or liveness check.
Pinging is only possible over a live libp2p connection.
A peer opens a stream, sends a request with a payload of 32 random
bytes, and the destination peer responds with 32 bytes on the same stream.
Peers can reuse a strean for future pings.

Typically, a ping is sent over a stream after the initial protocol negotiation.

The ping protocol ID is `/ipfs/ping/1.0.0`.

{{< alert icon="💡" context="note" text="See the ping <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/ping/ping.md\">technical specification</a> for more details." />}}
