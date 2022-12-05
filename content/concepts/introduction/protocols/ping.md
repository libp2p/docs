---
title: "Ping"
description: "The ping protocol is a simple request response protocol."
weight: 20
---

## What is Ping?

Ping is a network utility used to test a node's reachability.
The ping protocol is a simple request-response protocol that measures the RTT
for requests sent from an originating node to a destination node by echoing
a request payload.

## Ping in LibP2P

In LibP2P, a peer opens a stream, sends a request with a payload of 32 random bytes,
and the destination peer responds with 32 bytes on the same stream.

An originating peer will only have one outbound stream at a time, and a destination peer
accepts a maximum of two streams per peer. This is because the destination peer may view
the originating peer as opening and closing the wrong stream as cross-stream behavior is
non-linear.

The ping protocol ID is `/ipfs/ping/1.0.0`.

{{< alert icon="💡" context="note" text="See the ping <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/ping/ping.md\">technical specification</a> for more details." />}}
