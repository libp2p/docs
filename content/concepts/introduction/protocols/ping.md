---
title: "Ping"
description: "The ping protocol is a simple request response protocol."
weight: 20
---

## What is Ping?

ICMP Ping is a network utility that can be used as a simple liveness check
for peers to quickly see if another peer is online and measure RTT.

## Ping in libp2p

The libp2p ping protocol is different from the ping command line utility
([ICMP ping](https://en.wikipedia.org/wiki/Internet_Control_Message_Protocol)),
as it requires an already established libp2p connection.

A peer opens a stream, sends a request with a payload of 32 random
bytes, and the receiver responds with 32 bytes on the same stream.
Peers can reuse a strean for future pings.

The ping protocol ID is `/ipfs/ping/1.0.0`.

### Example

```shell
ipfs ping /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping

PING /ipfs/QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG/ping (QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG)
32 bytes from QmYwAPJzv5CZsnA625s3Xf2nemtYgPpHdWEz79ojWnPbdG: time=11.34ms
```

{{< alert icon="💡" context="note" text="See the ping <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/ping/ping.md\">technical specification</a> for more details." />}}
