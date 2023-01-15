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

A peer opens a new stream on an existing libp2p connection and sends a ping request with a random 32 byte payload. The receiver echoes these 32 bytes back on the same stream. By measuring the time between the
request and response, the initiator can calculate the round-trip time of the underlying libp2p connection.
The stream can be reused for future pings from the initiator.

The ping protocol ID is `/ipfs/ping/1.0.0`.

### Example

[Kubo](https://github.com/ipfs/kubo) exposes a command line interface to ping other peers, which uses the libp2p ping protocol.

```shell
ipfs ping /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping

PING /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping (QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG)
32 bytes from QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG: time=11.34ms
```

{{< alert icon="💡" context="note" text="See the ping <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/ping/ping.md\">technical specification</a> for more details." />}}
