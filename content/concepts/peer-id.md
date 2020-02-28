---
title: Peer Identity
weight: 4
---

A Peer Identity (often written `PeerId`) is a unique reference to a specific
peer within the overall peer-to-peer network.

As well as serving as a unique identifier for each peer, a PeerId is a
verifiable link between a peer and its public cryptographic key.

### What is a PeerId

Each libp2p peer controls a private key, which it keeps secret from all other
peers. Every private key has a corresponding public key, which is shared with
other peers.

Together, the public and private key (or "key pair") allow peers to establish
[secure communication](/concepts/secure-comms/) channels with each other.

Conceptually, a PeerId is a [cryptographic hash][wiki_hash_function] of a peer's
public key. When peers establish a secure channel, the hash can be used to
verify that the public key used to secure the channel is the same one used
to identify the peer.

The [PeerId spec][spec_peerid] goes into detail about the byte formats used
for libp2p public keys and how to hash the key to produce a valid PeerId.

PeerIds are encoded using the [multihash][definition_multihash] format, which
adds a small header to the hash itself that identifies the hash algorithm used
to produce it.

### How are Peer Ids represented as strings?

PeerIds are [multihashes][definition_multihash], which are defined as a
compact binary format.

It's very common to see multihashes encoded into
[base 58][wiki_base58], using
[the same alphabet used by bitcoin](https://en.bitcoinwiki.org/wiki/Base58#Alphabet_Base58).

Here's an example of a PeerId represented as a base58-encoded multihash:
`QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`

While it's possible to represent multihashes in many textual formats
(for example as hexadecimal, base64, etc), PeerIds *always* use the base58
encoding, with no [multibase prefix](https://github.com/multiformats/multibase)
when encoded into strings.

### PeerIds in multiaddrs

A PeerId can be encoded into a [multiaddr][definition_multiaddr] as a `/p2p`
address with the PeerId as a parameter.

If my peer id is `QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`, a
libp2p multiaddress for me would be:

```
/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N
```

As with other multiaddrs, a `/p2p` address can be encapsulated into
another multiaddr to compose into a new multiaddr. For example, I can combine
the above with a [transport](/concepts/transport/) address
`/ip4/7.7.7.7/tcp/4242` to produce this very useful address:

```
/ip4/7.7.7.7/tcp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N
```

This provides enough information to dial a specific peer over a TCP/IP
transport. If some other peer has taken over that IP address or port, it will be
immediately obvious, since they will not have control over the key pair used to
produce the PeerId embedded in the address.

**For more on addresses in libp2p, see [Addressing](/concepts/addressing/)**

{{% notice "note" %}}
The multiaddr protocol for libp2p addresses was originally written `/ipfs`
and was later renamed to `/p2p`.
The two are equivalent and have the same binary
representation in multiaddrs. Which one is rendered in the string format
depends on the version of the multiaddr library in use.
{{% /notice %}}


### PeerInfo

Another common libp2p data structure related to peer identity is the `PeerInfo`
structure.

A `PeerInfo` combines a `PeerId` with a set of [multiaddrs][definition_multiaddr]
that the peer is listening on.

libp2p applications will generally keep a "peer store" or "peer book" that
maintains a collection of `PeerInfo` objects for all the peers that they're
aware of.

The peer store acts as a sort of "phone book" when dialing out to
other peers; if a peer is in the peer store, we probably don't need to discover
their addresses using [peer routing](/concepts/peer-routing/).


{{% notice "tip" %}}
You can help improve this article! Please [refer to this issue](https://github.com/libp2p/docs/issues/12) to make suggestions and let us know how to help.
{{% /notice %}}

[wiki_hash_function]: https://en.wikipedia.org/wiki/Cryptographic_hash_function
[wiki_base58]: https://en.wikipedia.org/wiki/Base58

[definition_multiaddr]: /reference/glossary/#multiaddr
[definition_multihash]: /reference/glossary/#multihash

<!-- TODO(yusef): update link when peer-id PR lands -->
[spec_peerid]: https://github.com/libp2p/specs/pull/100
