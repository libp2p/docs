---
title: All about Peers
weight: 4
---

### What is a PeerId

A Peer Identity (often written `PeerId`) is a unique reference to a specific
peer within the overall peer-to-peer network.

As well as serving as a unique identifier for each peer, a PeerId is a
verifiable link between a peer and its public cryptographic key.

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

[wiki_hash_function]: https://en.wikipedia.org/wiki/Cryptographic_hash_function
[wiki_base58]: https://en.wikipedia.org/wiki/Base58

[definition_multiaddr]: /reference/glossary/#multiaddr
[definition_multihash]: /reference/glossary/#multihash

[spec_peerid]: https://github.com/libp2p/specs/blob/master/peer-ids/peer-ids.md

## PeerStore

`PeerStore`, also known as a `PeerBook`, is a register in libp2p that holds an updated data registry of all known peers, known as `PeerInfo`. Other peers can dial the `PeerStore` and listen for updates and learn about
any peer within the network. The `PeerStore` works like a phone or address book.; think of it like a multiaddr book. To maintain the source of truth for all `PeerInfo`:

- `addressBook`: holds the known `multiaddrs` of a peer, which may change over time, which the book accounts for.
- `keyBook`: uses  the`PeerId` to keep track of the peers' public keys.
- `protocolBook`: holds the protocol identifiers that each peer supports, which may change over time, which the `protocolBook` accounts for.
- `metadataBook`: Keeps track of the available peer metadata, which is stored in a key-value fashion, where a key identifier (string) represents a metadata value (Uint8Array).

The `PeerStore` also provides an API for the components of the inner book, as well as data events.

A `datastore` helps with data persistence for peers that may have been offline or reset, to improve connection efficiency on the libp2p network. A libp2p node will need to receive a `datastore` to persist data across restarts—a `datastore` stores data as key-value pairs. The store maintains data persistence and connection efficiency by not constantly updating the `datastore` with new data. Instead, the `datastore` stores new data only after reaching a certain threshold of peers out-of-date, and when a node stops to, batch writes to the datastore.

The `PeerID` appends the `datastore` key for each data namespace. The namespaces were defined as follows:

The `PeerStore` also uses an Event Emitter to notify interested parties of relevant events, such as peer discovery.

### Discovery events

A discovery method is likely needed if a peer is undiscoverable using the `PeerStore`. A peer `multiaddr` is typically discovered with their `PeerId`. Once the network successfully discovers a peer `multiaddr`, the peer discovery protocol will emit a peer event to add the `PeerInfo` and peer `multiaddr`  to the `PeerStore`. Learn more about how to discover un-{known, identified} peers on the Peer Routing guide. 

This is one way that the network updates the `PeerStore`. In general, an identify protocol automatically runs on every connection when multiplexing is enabled. The protocol will put the `multiaddrs` and protocols identifiers provided by the peer to the `PeerStore`. Similarly, an `IdentifyPush` protocol waits for change notifications about protocols that a peer supports and updates the `PeerStore` accordingly.

### Retreival events

The `PeerStore` emits a `peer` event to the libp2p network when the network discovers a new peer. Peers can dial the new peer to retrieve its `PeerInfo`.

The `PeerStore` emits a `change:protocols` event when the supported protocols of a peer change.

The `PeerStore` emits a `change:multiaddrs` event when the known listening multiaddrs of a peer changes.
