---
title: "Addressing"
description: Flexible networks need flexible addressing systems. Since libp2p is designed to work across a wide variety of networks, we need a way to work with a lot of different addressing schemes in a consistent way.
weight: 30
aliases:
    - "/concepts/addressing"
    - "/concepts/fundamentals/addressing"
---

Flexible networks need flexible addressing systems. Since libp2p is designed to work across a wide variety of networks,
we need a way to work with a lot of different addressing schemes in a consistent way.

A `multiaddress` (often abbreviated `multiaddr`), is a convention for encoding multiple layers of addressing information into a single "future-proof" path structure. It [defines](https://github.com/libp2p/specs/blob/master/addressing/README.md) human-readable and machine-optimized encodings of common transport and overlay protocols and allows many layers of addressing to be combined and used together.

For example: `/ip4/192.0.2.0/udp/1234` encodes two protocols along with their essential addressing information. The `/ip4/192.0.2.0` informs us that we want the `192.0.2.0` loopback address of the IPv4 protocol, and `/udp/1234` tells us we want to send UDP packets to port `1234`.

Things get more interesting as we compose further. For example, the multiaddr `/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N` uniquely identifies my local IPFS node, using libp2p's [registered protocol id](https://github.com/multiformats/multiaddr/blob/master/protocols.csv) `/p2p/` and the [multihash](/reference/glossary/#multihash) of my IPFS node's public key.

{{< alert icon="💡" context="tip">}}
For more on peer identity and its relation to public key cryptography, see [Peer Identity](/concepts/fundamentals/peers.md#peer-id).
{{< /alert >}}

Let's say that I have the Peer ID `QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N` as above, and my public ip is `198.51.100.0`. I start my libp2p application and listen for connections on TCP port `4242`.

Now I can start [handing out multiaddrs to all my friends](/concepts/peer-routing/), of the form `/ip4/198.51.100.0/tcp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`. Combining my "location multiaddr" (my IP and port) with my "identity multiaddr" (my libp2p `PeerId`), produces a new multiaddr containing both key pieces of information.

Now not only do my friends know where to find me, anyone they give that address to can verify that the machine on the other side is really me, or at least, that they control the private key for my `PeerId`. They also know (by virtue of the `/p2p/` protocol id) that I'm likely to support common libp2p interactions like opening connections and negotiating what application protocols we can use to communicate. That's not bad!

This can be extended to account for multiple layers of addressing and abstraction. For example, the [addresses used for circuit relay](/concepts/circuit-relay/#relay-addresses) combine transport addresses with multiple peer identities to form an address that describes a "relay circuit":

```shell
/ip4/198.51.100.0/tcp/4242/p2p/QmRelay/p2p-circuit/p2p/QmRelayedPeer
```

### More information

For more detail, see the [Addressing spec](https://github.com/libp2p/specs/blob/master/addressing/README.md).
