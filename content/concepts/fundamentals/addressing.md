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

A `multiaddress` (often abbreviated `multiaddr`), is a convention for encoding multiple layers of addressing information into a
single "future-proof" path structure. It [defines][spec_multiaddr] human-readable and machine-optimized encodings of common transport
and overlay protocols and allows many layers of addressing to be combined and used together.

For example: `/ip4/192.0.2.0/udp/1234` encodes two protocols along with their essential addressing information. 
The `/ip4/192.0.2.0` informs us that we want the `192.0.2.0` loopback address of the IPv4 protocol, and `/udp/1234` tells us we 
want to send UDP packets to port `1234`.

Things get more interesting as we compose further. For example, the multiaddr `/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N` uniquely
identifies my local IPFS node, using libp2p's [registered protocol id](https://github.com/multiformats/multiaddr/blob/master/protocols.csv)
`/p2p/` and the [multihash](/reference/glossary/#multihash) of my IPFS node's public key.

{{< alert icon="💡" context="tip">}}
For more on peer identity and its relation to public key cryptography, see [Peer Identity](../peers/#peer-id/).
{{< /alert >}}

Let's say that I have the Peer ID `QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N` 
as above, and my public ip is `198.51.100.0`. I start my libp2p application and listen 
for connections on TCP port `4242`.

Now I can start [handing out multiaddrs to all my friends](/concepts/peer-routing/), of the 
form `/ip4/198.51.100.0/tcp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`. 
Combining my "location multiaddr" (my IP and port) with my "identity multiaddr" 
(my libp2p `PeerId`), produces a new multiaddr containing both key pieces of information.

Now not only do my friends know where to find me, anyone they give that address to can verify that the machine on the other side is really me,
or at least, that they control the private key for my `PeerId`. They also know (by virtue of the `/p2p/` protocol id) that I'm likely to support
common libp2p interactions like opening connections and negotiating what application protocols we can use to communicate. That's not bad!

This can be extended to account for multiple layers of addressing and abstraction. For example, the
[addresses used for circuit relay](../nat/circuit-relay#relay-addresses) combine transport addresses with multiple peer identities to form
an address that describes a "relay circuit":

```shell
/ip4/198.51.100.0/tcp/4242/p2p/QmRelay/p2p-circuit/p2p/QmRelayedPeer
```

## Security protocols

In libp2p, establishing a secure connection between two peers involves negotiating a security protocol.
Historically, this negotiation occurred in-band, meaning that it was conducted as part of the connection establishment
process using the [multistream-select protocol](https://github.com/multiformats/multistream-select).
However, this approach is susceptible to man-in-the-middle attacks, as a malicious actor could modify the list of supported
handshake protocols to force a downgrade to a less secure protocol.

To address this issue, libp2p recommends that peers encode the security protocol they wish to use directly in the multiaddr
rather than negotiating it in-band. For example, a peer may advertise an address of `/ip4/1.2.3.4/tcp/1234/tls` to indicate
that it is running **TLS 1.3** on TCP port `1234` or `/ip4/1.2.3.4/tcp/1235/noise` to indicate that it is running **Noise**
n TCP port `1235`. This approach allows the nodes to jump into a cryptographic handshake, eliminating the possibility of
packet-inspection-based censorship and dynamic downgrade attacks.

It is worth noting that this change also applies to
[circuit addresses (specialized addresses used to establish connections through a relay)](../nat/circuit-relay##security-protocols).
In these cases, the security protocol is encoded in the `<destination address>` as defined in the
[p2p-circuit specification](https://github.com/libp2p/specs/blob/master/relay/circuit-v2.md).

{{< alert icon="" context="">}}
Implementations of libp2p that use the Protocol Select feature must also encapsulate the security protocol in the multiaddr.
However, assuming that any node encoded the security protocol in its multiaddr also supports Protocol Select is not valid.
To ease the transition to this new approach, users may leverage the dnsaddr multiaddr protocol or switch to a new UDP or TCP
port when changing the security protocol.
{{< /alert >}}

## More information

For more detail, see the [addressing specification](https://github.com/libp2p/specs/blob/master/addressing/README.md).
