---
title: All about Peers
weight: 4
---

## Peer ID

A Peer Identity (often written `PeerId`) is a unique reference to a specific
peer within the overall peer-to-peer network.

As well as serving as a unique identifier for each peer, a Peer Id is a
verifiable link between a peer and its public cryptographic key.

Each libp2p peer controls a private key, which it keeps secret from all other
peers. Every private key has a corresponding public key, which is shared with
other peers.

Together, the public and private key (or "key pair") allow peers to establish
[secure communication](/concepts/secure-comms/) channels with each other.

Conceptually, a Peer Id is a [cryptographic hash][wiki_hash_function] of a peer's
public key. When peers establish a secure channel, the hash can be used to
verify that the public key used to secure the channel is the same one used
to identify the peer.

The [Peer Id spec][spec_peerid] goes into detail about the byte formats used
for libp2p public keys and how to hash the key to produce a valid Pee Id.

Peer Ids are encoded using the [multihash][definition_multihash] format, which
adds a small header to the hash itself that identifies the hash algorithm used
to produce it.

### How are Peer Ids represented as strings?

Peer Ids are [multihashes][definition_multihash], which are defined as a
compact binary format.

It's very common to see multihashes encoded into
[base 58][wiki_base58], using
[the same alphabet used by bitcoin](https://en.bitcoinwiki.org/wiki/Base58#Alphabet_Base58).

Here's an example of a Peer Id represented as a base58-encoded multihash:
`QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`

While it's possible to represent multihashes in many textual formats
(for example as hexadecimal, base64, etc), Peer Ids *always* use the base58
encoding, with no [multibase prefix](https://github.com/multiformats/multibase)
when encoded into strings.

### Peer Ids in multiaddrs

A Peer Id can be encoded into a [multiaddr][definition_multiaddr] as a `/p2p`
address with the Peer Id as a parameter.

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
produce the Peer Id embedded in the address.

**For more on addresses in libp2p, see [Addressing](/concepts/addressing/)**

{{% notice "note" %}}
The multiaddr protocol for libp2p addresses was originally written `/ipfs`
and was later renamed to `/p2p`.
The two are equivalent and have the same binary
representation in multiaddrs. Which one is rendered in the string format
depends on the version of the multiaddr library in use.
{{% /notice %}}

## Peer Info

Another common libp2p data structure related to peer identity is the `PeerInfo`
structure.

Peer Info combines a Peer Id with a set of [multiaddrs][definition_multiaddr]
that the peer is listening on.

## Peer Store

A libp2p node will typically have a temporary store to store peer keys, 
addresses and associated metadata. `PeerStore`, also known as a `PeerBook`, 
is a register in libp2p that holds an updated data (Peer Info) registry of all 
known peers. Other peers can dial the peer store and listen for updates and learn 
about any peer within the network. The peer store works like a phone or address book; 
think of it like a universal multiaddr book that maintains the source of truth for all
known peers.

{{% notice "note" %}}

With different design choices possible, here is a snapshot of how the js-libp2p 
implements the peer store: an `addressBook` holds the known multiaddrs of a peer, 
which may change over time, which the book accounts for; a `keyBook` uses the Peer Id 
to keep track of the peers' public keys; a `protocolBook` holds the protocol identifiers 
that each peer supports, which may change over time, which the `protocolBook` accounts 
for; a `metadataBook` keeps track of the available peer metadata, which is stored in a 
key-value fashion, where a key identifier (string) represents a metadata value (Uint8Array). 
There is also an API to expose the components of the inner book, as well as data events 
to emit data about new information and changes.
  
{{% /notice %}}

A datastore helps with data persistence for peers that may have been offline or reset, to 
improve connection efficiency on the libp2p network. A libp2p node will need to receive a 
datastore to persist data across restarts—a datastore stores data as key-value pairs. The 
store maintains data persistence and connection efficiency by not constantly updating the 
datastore with new data. Instead, the datastore stores new data only after reaching a certain 
threshold of peers out-of-date, and when a node stops to, batch writes to the datastore.
The Peer ID will be appended to the datastore key for each data namespace.

### Peer Discovery

A discovery method is likely needed if a peer is undiscoverable using the Peer Store. A peer 
multiaddr is typically discovered with their Peer Id. Once the network successfully discovers 
a peer multiaddr (and able to establish a connection), the peer discovery protocol adds the 
Peer Info and multiaddr to the Peer Store. Learn more about how to discover 
un-{known, identified} peers on the peer routing guide.

<!-- to add when peer routing guide is up -->

This is one way that the network updates the Peer Store. 
In general, an [Identify protocol][identity] automatically runs on every connection when 
multiplexing is enabled. The protocol will put the multiaddrs and protocols identifiers provided 
by the peer to the Peer Store. Similarly, the Identity protocol waits for change notifications 
about protocols that a peer supports and updates the Peer Store accordingly.

### Peer Retrieval

The Peer Store notifies the libp2p network when the network discovers 
a new peer. The Peer Store also notifies the network about changes to the Peer Info
about the peer, such as the peer's supported protocols and known multiaddrs.

[wiki_hash_function]: https://en.wikipedia.org/wiki/Cryptographic_hash_function
[wiki_base58]: https://en.wikipedia.org/wiki/Base58

[definition_multiaddr]: /reference/glossary/#multiaddr
[definition_multihash]: /reference/glossary/#multihash

[spec_peerid]: https://github.com/libp2p/specs/blob/master/peer-ids/peer-ids.md
[identity]: https://github.com/libp2p/specs/blob/master/identify/README.md#identifypush