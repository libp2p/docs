---
title: "Glossary"
description: A compiled list of words, phrases, and abbreviations for libp2p.
weight: 280
aliases:
   - "/concepts/glossary"
   - "/reference/glossary"
---

### Boot Node

New nodes in a p2p network often make their initial connection to the p2p network through a set of nodes known as boot nodes. Information (e.g. addresses) about these boot nodes is e.g. embedded in an application binary or provided as a configuration option.

The boot nodes serve as an entry point, providing a list of other nodes in the network to newcomers. After connecting to the boot nodes, the new node can connect to those other nodes in the network, thereby no longer relying on the boot nodes.

### Circuit Relay

A means of establishing communication between peers who are unable to communicate directly, with the assistance of a third peer willing and able to act as an intermediary.

In many real-world peer-to-peer networks, direct communication between all peers may be impossible for a variety of reasons. For example, one or more peers may be behind a firewall or have [NAT traversal](#nat-traversal) issues. Or maybe the peers don't share any common [transports](#transport).

In such cases, it's possible to "bridge the gap" between peers, so long as each of them are capable of establishing a connection to a willing relay peer. If I only speak TCP and you only speak websockets, we can still hang out with the help of a bilingual pal.

Circuit relay is implemented in libp2p according to the [relay spec](https://github.com/libp2p/specs/tree/master/relay), which defines a wire protocol and addressing scheme for relayed connections.

### Client / Server

A network architecture defined by the presence of central "server" programs which provide services and resources to a (usually much larger) set of "client" programs. Typically clients do not communicate directly with one another, instead routing all communications through the server, which is inherently the most privileged member of the network.

### DHT

A [distributed hash table](https://en.wikipedia.org/wiki/Distributed_hash_table) whose contents are spread throughout a network of participating peers. Much like an in-process hash table, values are associated with a key and can be retrieved by key. Most DHTs assign a portion of the addressable key space to nodes in a deterministic manner, which allows for efficient routing to the node responsible for a given key.

Since DHTs are a foundational primitive of many peer-to-peer systems, libp2p provides a [Kademlia](https://en.wikipedia.org/wiki/Kademlia)-based DHT implementation in [Go](https://github.com/libp2p/go-libp2p-kad-dht) and [javascript](https://github.com/libp2p/js-libp2p-kad-dht).

libp2p uses the DHT as the foundation for one of its [peer routing](#peer-routing) implementations, and systems built with libp2p often use the DHT to provide metadata about content, advertise service availability, and more.

### Connection

A libp2p connection is a communication channel that allows peers to read and write data.

Connections between peers are established via [transports](#transport), which can be thought of as "connection factories". For example, the TCP transport allows you to create connections that use TCP/IP as their underlying substrate.

### DCUtR

Direct Connection Upgrade through Relay (DCUtR) is a protocol for establishing direct connections between nodes via hole punching, without a [signaling server](#signaling-server). DCUtR synchronizes and opens connections to each peer's predicted external addresses.

### Dial

The process of opening a libp2p connection to another peer is known as "dialing", and accepting connections is known as ["listening"](#listen). Together, an implementation of dialing and listening forms a [transport](#transport).

### Listen

The process of accepting incoming libp2p connections is known as "listening", and it allows other peers to ["dial"](#dial) up and open network connections to your peer.

### mDNS

[Multicast DNS](https://en.wikipedia.org/wiki/Multicast_DNS) is a protocol for service discovery on a local network. One of libp2p's [peer routing](#peer-routing) implementations leverages mDNS to discover local peers quickly and efficiently.

### multiaddr

A `multiaddress` (often abbreviated `multiaddr`), is a convention for encoding multiple layers of addressing information into a single "future-proof" path structure.

For example: `/ip4/192.0.2.0/udp/1234` encodes two protocols along with their essential addressing information. The `/ip4/192.0.2.0` informs us that we want the `192.0.2.0` loopback address of the IPv4 protocol, and `/udp/1234` tells us we want to send UDP packets to port `1234`.

Multiaddresses can be composed to describe multiple "layers" of addresses.

For more detail, see [Addressing]({{< relref "/concepts/fundamentals/addressing.md" >}}), or the [multiaddr spec](https://github.com/multiformats/multiaddr), which has links to many implementations.

### Multiaddress

See [multiaddr](#multiaddr)

### Multihash

[Multihash](https://github.com/multiformats/multihash) is a convention for representing the output of many different [cryptographic hash functions](https://en.wikipedia.org/wiki/Cryptographic_hash_function) in a compact, deterministic encoding that is accommodating of future changes.

Hashes are central to many systems (git, for example), yet many systems store only the hash output itself, since the choice of hash function is an implicit design parameter of the system. This has the unfortunate effect of making it quite difficult to ever change your mind about what kind of hash function your system uses!

A multihash encodes the type of hash function used to produce the output, as well as the length of the output in bytes. This is added as a two-byte header to the original hash output, and in return for those two bytes, the header allows current and future systems to easily identify and validate many hash functions by leveraging common libraries. As new functions are added, you can much more easily extend your application or protocol to support them, since the old and new hash outputs will be easily distinguishable from one another.

The most prominent use of multihashes in libp2p is in the [PeerId](#peerid), which contains a hash of a peer's public key. However, systems built with libp2p, most notably [IPFS](https://ipfs.io), use multihashes for other purposes. In the IPFS case, multihashes are used both to identify content and other peers, since IPFS uses libp2p and shares the same `PeerId` conventions.

In IPFS, multihashes are a key component of the [CID, or content identifier](https://docs.ipfs.io/guides/concepts/cid/), and the "v0" version of CID is a "raw" multihash of a piece of content. A "modern" CID combines a multihash of some content with some compact contextualizing metadata, allowing content-addressed systems like IPFS to create more meaningful links between hash-addressed data. For more on the subject of hash-linked data structures in p2p systems, see [IPLD](https://ipld.io).

Multihashes are often represented as [base58-encoded](https://en.wikipedia.org/wiki/Base58) strings, for example, `QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`. The first two characters `Qm` are the multihash header for the SHA-256 hash algorithm with a length of 256 bits, and are common to all base58-encoded multihashes using SHA-256.

### Multiplexing

Multiplexing (or "muxing"), refers to the process of combining multiple streams of communication over a single logical "medium". For example, we can maintain multiple independent data streams over a single TCP network connection, which is itself of course being multiplexed over a single physical connection (ethernet, wifi, etc).

Multiplexing allows peers to offer many [protocols](#protocol) over a single connection, which reduces network overhead and makes [NAT traversal](#nat-traversal) more efficient and effective.

libp2p supports several implementations of stream multiplexing. The [mplex specification](https://github.com/libp2p/specs/tree/master/mplex) defines a simple protocol with implementations in several languages. Other supported multiplexing protocols include [yamux](https://github.com/hashicorp/yamux) and [spdy](https://www.chromium.org/spdy/spdy-whitepaper).

See [Stream Muxer Implementations](https://libp2p.io/implementations/#stream-muxers) for status of multiplexing across libp2p language implementations.

### multistream

[multistream](https://github.com/multiformats/multistream) is a lightweight convention for "tagging" streams of binary data with a short header that identifies the content of the stream.

libp2p uses multistream to identify the [protocols](#protocol) used for communication between peers, and a related project [multistream-select](https://github.com/multiformats/multistream-select) is used for [protocol negotiation](#protocol-negotiation).

### NAT

[Network address translation](https://en.wikipedia.org/wiki/Network_address_translation) in general is the mapping of addresses from one address space to another, as often happens at the boundary of private networks with the global internet. It is especially essential in IPv4 networks (which are still the vast majority), as the address space of IPv4 is quite limited. Using NAT, a local, private network can have a vast range of addresses within the internal network, while only consuming one public IP address from the global pool.

An unfortunate effect of NAT in practice is that it's much easier to make outgoing connections from the private network to the public one than it is to call from outside in. This is because machines listening for connections on the internal network need to explicitly tell the router in charge of NAT that it should forward traffic for a given port (the [multiplexing](#multiplexing) abstraction for the OS networking layer) to the listening machine.

This is less of an issue in a client / server model, because outgoing connections to the server give the router enough information to route the response back to the client where it needs to go.

In the peer-to-peer model, accepting connections from other peers is often just as important as initiating them, which means that we often need our peers to be publicly reachable from the global internet. There are many viable approaches to [NAT Traversal](#nat-traversal), several of which are implemented in libp2p.

### NAT Traversal
<!-- TODO(yusef): much of this can be moved to the NAT concept doc and this definition can be trimmed -->

NAT traversal refers to the process of establishing connections with other machines across a [NAT](#nat) boundary. When crossing the boundary between IP networks (e.g. from a local network to the global internet), a [Network Address Translation](#nat) process occurs which maps addresses from one space to another.

For example, my home network has an internal range of IP addresses (10.0.1.x), which is part of a range of addresses that are reserved for private networks. If I start a program on my computer that listens for connections on its internal address, a user from the public internet has no way of reaching me, even if they know my public IP address. This is because I haven't made my router aware of my program yet. When a connection comes in from the internet to my public IP address, the router needs to figure out which internal IP to route the request to, and to which port.

There are many ways to inform one's router about services you want to expose. For consumer routers, there's likely an admin interface that can setup mappings for any range of TCP or UDP ports. In many cases, routers will allow automatic registration of ports using a protocol called [upnp](https://en.wikipedia.org/wiki/Universal_Plug_and_Play), which libp2p supports. If enabled, libp2p will try to register your service with the router for automatic NAT traversal.

In some cases, automatic NAT traversal is impossible, often because multiple layers of NAT are involved. In such cases, we still want to be able to communicate, and we especially want to be reachable and allow other peers to [dial in](#dial) and use our services. This is the one of the motivations for [Circuit Relay](#circuit-relay), which is a protocol involving a "relay" peer that is publicly reachable and can route traffic on behalf of others. Once a relay circuit is established, a peer behind an especially intractable NAT can advertise the relay circuit's [multiaddr](#multiaddr), and the relay will accept incoming connections on our behalf and send us traffic via the relay.

### Node

The word "node" is quite overloaded in general programming contexts, and this is especially the case in peer-to-peer networking circles.

One common usage is when "node" refers to a single instance of a peer-to-peer software system, running at some time and place in the universe. For example, `I'm running an orbit-db node in AWS. I think it's on version 3.2.0`. In this usage, "node" refers to the whole software program (the `daemon` in unix-speak) which participates in the network. In this documentation, we'll often use ["peer"](#peer) for this purpose instead, and the two terms are often used interchangeably in various p2p software discussions.

Another quite different meaning is the [node.js](https://nodejs.org) javascript runtime environment, which is one of the supported runtimes for js-libp2p. In general it should be pretty clear from context when "node" is referring to node.js.

Many members of our community are excited about graphs in many contexts, so the graph terminology of "nodes and edges" is often used when discussing various subjects. Some common contexts for graph-related discussions:

- When discussing the [topology](#topology) or structure of a peer-to-peer network, "node" is often used in the context of a graph of connected peers. Efficient construction and traversal of this graph is key to effective [peer routing](#peer-routing).

- When discussing data structures, "node" is often useful for referring to key elements of the structure. For example, a linked list consists of many "nodes" containing both a value and a link (or, in graph terms, an "edge") connecting it to the next node. Since many useful and interesting data structures can be described as graphs, much of the terminology of graph theory applies when discussing their properties. In particular, IPFS is naturally well-suited to storing and manipulating data structures which form a [Directed Acyclic Graph, or DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph).

- An especially interesting data structure for many in our community is [IPLD](https://ipld.io), or Interplanetary Linked Data. Similar to libp2p, IPLD grew out of the real-world needs of IPFS, but is broadly useful and interesting in many contexts outside of IPFS. IPLD discussions often involve "nodes" of all the types discussed here.

### Overlay

An "overlay network" or just "overlay" refers to the logical structure of a peer-to-peer network, which is "overlaid" on top of the underlying [transport mechanisms](#transport) used for lower-level network communication.

Peer-to-peer systems are generally composed of one or more overlay networks, which determine how peers are identified and located, how messages are propagated throughout the system, and other key properties.

Examples of overlay networks used in libp2p are the [DHT](#dht) implementation, which is based on [Kademlia](https://en.wikipedia.org/wiki/Kademlia), and the networks formed by participants in the various [pubsub](#pubsub) implementations.

### Peer

A single participant in a peer-to-peer network. While a given peer may support many [protocols](#protocol), it has a single [PeerId](#peerid) which it uses to identify itself to other peers. Often used synonymously with [node](#node).

### PeerId

A unique, verifiable identifier for a [peer](#peer) that is impossible for another peer to forge or impersonate without trivial detection. In libp2p, peers are identified by their `PeerId`, which is both globally unique and allows other peers to obtain the peer's [cryptographic public key](https://en.wikipedia.org/wiki/Public-key_cryptography).

The most common form of `PeerId` is a [multihash](#multihash) of a peer's public key, which can be used to fetch the entire public key from the [DHT](#dht) for encryption or signature verification. There is also experimental support for embedding or "inlining" small public keys directly into the `PeerId`, however, this is an area of [ongoing discussion](https://github.com/libp2p/specs/issues/138) and should be treated with caution in production systems until finalized.

An important property of cryptographic peer identities is that they are decoupled from [transport](#transport), allowing peers to verify the identity of other peers regardless of what underlying network they might use to communicate. This also gives them a much longer "shelf life" than location-based identifiers (for example, IP addresses), since identities remain stable across address changes.

### Peer store

A data structure that stores [PeerIds](#peerid) for known peers, along with known [multiaddresses](#multiaddr) that can be used to communicate with them.

### Peer routing

Peer routing is the process of discovering the network "route" or address for a
peer in the network, given the peer's [id](#peerid).

It may also include "ambient" discovery of local peers, for example via
[multicast DNS](#mdns).

The primary peer routing mechanism in libp2p uses a
[distributed hash table](#dht) to locate peers, taking advantage of the
Kademlia routing algorithm to efficiently locate peers.

### Peer-to-peer (p2p)

A peer-to-peer (p2p) network is one in which the participants (referred to as [peers](#peer) or [nodes](#node)) communicate with one another directly, on more or less "equal footing". This does not necessarily mean that all peers are identical; some may have different roles in the overall network. However, one of the defining characteristics of a peer-to-peer network is that they do not require a privileged set of "servers" which behave completely differently from their "clients", as is the case in the predominant [client / server model](#client-server).

### Pubsub

In general, refers to "publish / subscribe", a communication pattern in which participants "subscribe" for updates "published" by other participants, often on a named "topic".

libp2p defines a [pubsub spec](https://github.com/libp2p/specs/blob/master/pubsub/README.md), with links to several implementations in supported languages. Pubsub is an area of ongoing research and development, with multiple implementations optimized for different use cases and environments.

### Protocol

In general, a set of rules and data structures used for network communication.

libp2p is comprised of many protocols and makes use of many others provided by
the operating system or runtime environment.

Most core libp2p functionality is defined in terms of protocols, and libp2p
protocols are identified using [multistream](#multistream) headers.

### Protocol Negotiation

The process of reaching agreement on what protocol to use for a given stream
of communication.

In libp2p, protocols are identified using a convention called
[multistream](#multistream), which adds a small header to the beginning of
a stream containing a unique name, including a version identifier.

When two peers first connect, they exchange a [handshake](#handshake) to
agree upon what protocols to use.

The implementation of the libp2p handshake is called
[multistream-select](https://github.com/multiformats/multistream-select).

For details, see the [protocol negotiation article]({{< relref "/concepts/fundamentals/protocols.md#protocol-negotiation" >}}).

### Signaling server

A server or service that facilitates communication between nodes in a peer-to-peer network, specifically in context of setting up, maintaining and terminating a direct communication channel between two peers which are behind NATs. The server discovers the external IP address and port of the peers, and also relays messages between the peers to assist NAT traversal.

### Stream

TODO: Distinguish between the various types of "stream". Could refer to

- raw tcp connection
- one component of a multistream connection
- node.js streams / pull-streams

### Swarm

Can refer to a collection of interconnected peers.

In the libp2p codebase, "swarm" may refer to a module that allows a peer to
interact with its peers, although this component was later renamed ["switch"](#switch).

### Switch

A libp2p component responsible for composing multiple [transports](#transport)
into a single interface, allowing application code to [dial](#dial) peers
without having to specify what transport to use.

In addition to managing transports, the switch also coordinates the
"connection upgrade" process, which promotes a "raw" connection from
the transport layer into one that supports
[protocol negotiation]({{< relref "/concepts/fundamentals/protocols.md#protocol-negotiation" >}}),
[stream multiplexing](#multiplexing), and
[secure communications]({{< relref "/concepts/secure-comm/overview.md" >}}).

Sometimes called ["swarm"](#swarm) for historical reasons.

### Topology

In a peer-to-peer context, usually refers to the shape or structure of the [overlay network](#overlay) formed by peers as they communicate with each other.

### Transport

In libp2p, `transport` refers to the technology that lets us move bits from one machine to another. This may be a TCP network provided by the operating system, a websocket connection in a browser, or anything else capable of implementing the [transport interface](https://github.com/libp2p/interface-transport).

Note that in some environments such as javascript running in the browser, not all transports will be available. In such cases, it may be possible to establish a [Circuit Relay](#circuit-relay) with the help of a peer that can support many common transports. Such a relay can act as a "transport adapter" of sorts, allowing peers that can't communicate with each other directly to interact. For example, a peer in the browser that can only make websocket connections could relay through a peer able to make TCP connections, which would enable communication with a wider variety of peers.
