---
title: "Ping"
description: "The ping protocol is a simple request response protocol."
weight: 20
---

## Ping in libp2p

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

A peer opens the stream, sends a request with a payload of 32 random
bytes, and the receiver responds with 32 bytes on the same stream.
Peers can reuse a strean for future pings.

The ping protocol ID is `/ipfs/ping/1.0.0`.

### Example

The following example is done using [Kubo IPFS](https://github.com/ipfs/kubo).

```shell
ipfs ping /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping

PING /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping (QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG)
32 bytes from QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG: time=11.34ms
```

{{< alert icon="💡" context="note" text="See the ping <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/ping/ping.md\">technical specification</a> for more details." />}}
