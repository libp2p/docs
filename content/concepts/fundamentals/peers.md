---
title: "Peers"
description: Peers are what make up a libp2p network. They include unique identifiers and storage methods to facilitate peer-to-peer connections in libp2p.
weight: 60
aliases:
    - "/concepts/peers"
    - "/concepts/fundamentals/peers"
    - "/concepts/peer-id"
    - "/concepts/fundamentals/peer-id"
---

Peers are what make up a libp2p network. We'll go over their key
properties in this guide.

## Peer ID

A Peer Identity (often written `PeerID`) is a unique reference to a specific
peer within the overall peer-to-peer network.

As well as serving as a unique identifier for each peer, a Peer ID is
a verifiable link between a peer and its public cryptographic key.

Each libp2p peer controls a private key, which it keeps secret from all other
peers. Every private key has a corresponding public key, which is shared with
other peers.

Together, the public and private key (or "key pair") allow peers to establish
[secure communication]({{< relref "/concepts/secure-comm/overview.md" >}}) channels with each other.

Conceptually, a Peer ID is a [cryptographic hash][wiki_hash_function] of a peer's
public key. When peers establish a secure channel, the hash can be used to
verify that the public key used to secure the channel is the same one used
to identify the peer.

The [Peer ID spec][spec_peerid] goes into detail about the byte formats used
for libp2p public keys and how to hash the key to produce a valid Peer ID.

### How are Peer Ids represented as strings?

Peer Ids are [multihashes][definition_multihash], which are defined as a
compact binary format.

It's very common to see multihashes encoded into
[base 58][wiki_base58], using
[the same alphabet used by bitcoin](https://en.bitcoinwiki.org/wiki/Base58#Alphabet_Base58).

Here's an example of a Peer ID represented as a base58-encoded multihash:
`QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`

While it's possible to represent multihashes in many textual formats
(for example as hexadecimal, base64, etc), Peer Ids *always* use the base58
encoding, with no [multibase prefix](https://github.com/multiformats/multibase)
when encoded into strings.

### Peer IDs in multiaddrs

A Peer ID can be encoded into a [multiaddr][definition_multiaddr] as a `/p2p`
address with the Peer ID as a parameter.

If my Peer ID is `QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`, a
libp2p multiaddress for me would be:

```shell
/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N
```

As with other multiaddrs, a `/p2p` address can be encapsulated into
another multiaddr to compose into a new multiaddr. For example, I can combine
the above with a [transport]({{< relref "/concepts/transports/overview.md" >}}) address
`/ip4/198.51.100.0/tcp/4242` to produce this very useful address:

```shell
/ip4/198.51.100.0/tcp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N
```

This provides enough information to dial a specific peer over a TCP/IP
transport. If some other peer has taken over that IP address or port, it will be
immediately obvious, since they will not have control over the key pair used to
produce the Peer ID embedded in the address.

**For more on addresses in libp2p, see [Addressing]({{< relref "/concepts/fundamentals/addressing.md" >}})**

{{< alert icon="💡" context="note">}}
The multiaddr protocol for libp2p addresses was originally written `/ipfs` and was later renamed to `/p2p`.
The two are equivalent and have the same binary representation in multiaddrs.
Which one is rendered in the string format depends on the version of the multiaddr library in use.
{{< /alert >}}

## Peer Info

Another common libp2p data structure related to peer identity is the `PeerInfo`
structure.

Peer Info combines a Peer ID with a set of [multiaddrs][definition_multiaddr]
that the peer is listening on.

## Peer Store

A libp2p node will typically have a temporary store to store peer keys,
addresses and associated metadata. The peer store works like a phone or address
book; think of it like a universal multiaddr book that maintains the source of truth
for all known peers.

{{< alert icon="💡" context="info">}}
Implementations may wish to persist a snapshot of the peer store on shutdown, so that
they don’t have to start with an empty peer store when they boot up the next time.
{{< /alert >}}

### Peer Discovery

A discovery method is likely needed if no information about a peer is available in the
peer store. A peer multiaddr is typically discovered with their Peer ID. Once the network
successfully discovers a peer multiaddr (and able to establish a connection), the peer discovery
protocol adds the Peer Info and multiaddr to the Peer Store. Learn more about how to discover
un-{known, identified} peers on the peer routing guide.

<!-- to add when peer routing guide is up -->

[wiki_hash_function]: https://en.wikipedia.org/wiki/Cryptographic_hash_function
[wiki_base58]: https://en.wikipedia.org/wiki/Base58

[definition_multiaddr]: /concepts/appendix/glossary#multiaddr
[definition_multihash]: /concepts/appendix/glossary#multihash

[spec_peerid]: https://github.com/libp2p/specs/blob/master/peer-ids/peer-ids.md
[identity]: https://github.com/libp2p/specs/blob/master/identify/README.md#identifypush
