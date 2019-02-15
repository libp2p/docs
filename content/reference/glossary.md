---
title: "Glossary"
menu:
    reference:
        weight: 1
---

### Client / Server

A network architecture defined by the presence of central "server" programs which provide services and resources to a (usually much larger) set of "client" programs.  Typically clients do not communicate directly with one another, instead routing all communications through the server, which is inherently the most privileged member of the network.

### DHT

A [distributed hash table](https://en.wikipedia.org/wiki/Distributed_hash_table) whose contents are spread throughout a network of participating peers. Much like an in-process hash table, values are associated with a key and can be retrieved by key. Most DHTs assign a portion of the addressable key space to nodes in a deterministic manner, which allows for efficient routing to the node responsible for a given key.

Since DHTs are a foundational primitive of many peer-to-peer systems, libp2p provides a [Kademlia](https://en.wikipedia.org/wiki/Kademlia)-based DHT implementation in [Go](https://github.com/libp2p/go-libp2p-kad-dht) and [javascript](https://github.com/libp2p/js-libp2p-kad-dht).

libp2p uses the DHT as the foundation for one of its [peer routing](#peer-routing) implementations, and systems built with libp2p often use the DHT to provide metadata about content, advertise service availability, and more.

### Multiaddress

A `multiaddress` (often abbreviated `multiaddr`), is a convention for encoding multiple layers of addressing information into a single path structure.

For example: `/ip4/127.0.0.1/udp/1234` encodes two protocols along with their essential addressing information. The `/ip4/127.0.0.1` informs us that we want the `127.0.0.1` loopback address of the IPv4 protocol, and `/udp/1234` tells us we want to send UDP packets to port `1234`.

Things get more interesting as we compose further. For example, the multiaddr `/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N` uniquely identifies my local IPFS node, using libp2p's [registered protocol id](https://github.com/multiformats/multiaddr/blob/master/protocols.csv) `/p2p/` and the [multihash](#multihash) of my IPFS node's public key. For more on peer identity and its relation to public key cryptography, see [PeerId](#peerid).

Let's say that I have the peer id `QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N` as above, and my public ip is `7.7.7.7` (not my real IP, sadly). I start my libp2p application and listen for connections on port `4242`. Now I can start handing out multiaddrs to all my friends, of the form `/ip4/7.7.7.7/tcp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`. Now not only do they know where to find me, anyone they give that address to can verify that the machine on the other side is really me, or at least, that they control the private key for the peer id `QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N`.  They also know (by virtue of the `/p2p/` protocol id) that I'm likely to support common libp2p interactions like opening connections and negotiating what application protocols we can use to communicate. That's not bad!

This can be extended to account for multiple layers of addressing and abstraction. For example, the [Circuit Relay](#circuit-relay) implementation encapsulates the path of the relay into a new multiaddr that combines the public location of the relay with the [PeerId](#peer-id) of the peer on the other end of the circuit.

For more detail, see the [multiaddr spec](https://github.com/multiformats/multiaddr), which has links to many implementations.

### Multihash

[Multihash](https://github.com/multiformats/multihash) is a convention for representing the output of many different [cryptographic hash functions](https://en.wikipedia.org/wiki/Cryptographic_hash_function) in a compact, deterministic encoding that is accommodating of future changes.

Hashes are central to many systems (git, for example), yet many systems store only the hash output itself, since the choice of hash function is an implicit design parameter of the system. This has the unfortunate effect of making it much more difficult to ever change your mind about what kind of hash function your system uses!

A multihash encodes the type of hash function used to produce the output, as well as the length of the output in bytes. This is added as a two-byte header to the original hash output, and in return for those two bytes, the header allows current and future systems to easily identify and validate many hash functions by leveraging common libraries. As new functions are added, you can much more easily extend your application or protocol to support them, since the old and new hash outputs will be easily distinguishable from one another.

The most prominent use of multihashes in libp2p is in the [PeerId](#peerid), which contains a hash of a peer's public key. However, systems built with libp2p, most notably [IPFS](https://ipfs.io), use multihashes for other purposes. In the IPFS case, multihashes are used both to identify content and other peers, since IPFS uses libp2p and shares the same `PeerId` conventions.

In IPFS, multihashes are a key component of the [CID, or content identifier](#cid), and the "v0" version of CID is a "raw" multihash of a piece of content. A "modern" CID combines a multihash of some content with some compact contextualizing metadata, allowing for content-addressed systems like IPFS create intricate links between hash-addressed data. For more on the subject of hash-linked data structure in p2p systems, see [IPLD](#ipld).


### NAT

[Network address translation](https://en.wikipedia.org/wiki/Network_address_translation) in general is the mapping of addresses from one address space to another, as often happens at the boundary of private networks with the global internet. It is especially essential in IPv4 networks (which are still the vast majority), as the address space of IPv4 is quite limited. Using NAT, a local, private network can have a vast range of addresses within the internal network, while only consuming one public IP address from the global pool.

An unfortunate effect of NAT in practice is that it's much easier to make outgoing connections from the private network to the public one than it is to call from outside in.  This is because machines listening for connections on the internal network need to explicitly tell the router in charge of NAT that it should forward traffic for a given port (the [multiplexing](#multiplexing) abstraction for the OS networking layer) to the listening machine.

This is less of an issue in a client / server model, because outgoing connections to the server give the router enough information to route the response back to the client where it needs to go.

In the peer-to-peer model, accepting connections from other peers is often just as important as initiating them, which means that we often need our peers to be publicly reachable from the global internet. There are many viable approaches to [NAT Traversal](#nat-traversal), several of which are implemented in libp2p.

### NAT Traversal

NAT traversal refers to the process of establishing connections with other machines across a [NAT](#nat) boundary. When crossing the boundary between IP networks (e.g. from a local network to the global internet), a [Network Address Translation](#nat) process occurs which maps addresses from one space to another.

For example, my home network has an internal range of IP addresses (10.0.1.x), which is part of a range of addresses that are reserved for private networks. If I start a program on my computer that listens for connections on its internal address, a user from the public internet has no way of reaching me, even if they know my public IP address. This is because I haven't made my router aware of my program yet. When a connection comes in from the internet to my public IP address, the router needs to figure out which internal IP to route the request to, and to which port.

There are many ways to inform one's router about services you want to expose. For consumer routers, there's likely an admin interface that can setup mappings for any range of TCP or UDP ports. In many cases, routers will allow automatic registration of ports using a protocol called [upnp][external_upnp], which libp2p supports. If enabled, libp2p will try to register your service with the router for automatic NAT traversal. <!-- TODO: link to libp2p upnp repos. "if enabled" - how? link to config example -->

In some cases, automatic NAT traversal is impossible, often because multiple layers of NAT are involved. In such cases, we still want to be able to communicate, and we especially want to be reachable and allow other peers to [dial in](#dial) and use our services. This is the motivation for [Circuit Relay](#circuit-relay), which is a protocol involving a "relay" peer that is publicly reachable and can route traffic on behalf of others. Once a relay circuit is established, a peer behind an especially intractable NAT can advertise the relay circuit's [multiaddress](#multiaddress), and the relay will accept incoming connections on our behalf and send us traffic via the relay.

<!-- TODO: link to AutoRelay once it's defined -->

### Node

The word "node" is quite overloaded in general programming contexts, and this is especially the case in peer-to-peer networking circles.  

One common usage is when "node" refers to a single instance of a peer-to-peer software system, running at some time and place in the universe.  For example, `I'm running an orbit-db node in AWS. I think it's on version 3.2.0`. In this usage, "node" refers to the whole software program (the `daemon` in unix-speak) which participates in the network. In this documentation, we'll often use ["peer"](#peer) for this purpose instead, and the two terms are often used interchangeably in various p2p software discussions.

Another quite different meaning is the [node.js](https://nodejs.org) javascript runtime environment, which is one of the supported runtimes for the [javscript libp2p implementation][js-docs-home]. In general it should be pretty clear from context when "node" is referring to node.js.

Many members of our community are excited about graphs in many contexts, so the graph terminology of "nodes and edges" is often used when discussing various subjects.  Some common contexts for graph-related discussions:

- When discussing the [topology](#topology) or structure of a peer-to-peer network, "node" is often used in the context of a graph of connected peers. Efficient construction and traversal of this graph is key to effective [peer routing](#peer-routing).

- When discussing data structures, "node" is often useful for referring to key elements of the structure.  For example, a linked list consists of many "nodes" containing both a value and a link (or, in graph terms, an "edge") connecting it to the next node. Since many useful and interesting data structures can be described as graphs, much of the terminology of graph theory applies when discussing their properties. In particular, IPFS is naturally well-suited to storing and manipulating data structures which form a [Directed Acyclic Graph, or DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph). As there is a lot of overlap in interests between libp2p and IPFS developers, you're likely to encounter discussions of various graph data structures from time to time.

- An especially interesting data structure for many in our community is [IPLD](#ipld), or Interplanetary Linked Data.  Similar to libp2p, IPLD grew out of the real-world needs of IPFS, but is broadly useful and interesting in many contexts outside of IPFS. IPLD discussions often involve "nodes" of all the types discussed here.


### mDNS

[Multicast DNS](https://en.wikipedia.org/wiki/Multicast_DNS) is a protocol for service discovery on a local network.  One of libp2p's [peer routing](#peer-routing) implementations leverages mDNS to discover local nodes quickly and efficiently.

### Multiplexing

Multiplexing (or "muxing"), refers to the process of combining multiple streams of communication over a single logical "medium".  For example, we can maintain multiple independent data streams over a single TCP network connection, which is itself of course being multiplexed over a single physical connection (ethernet, wifi, etc).

Multiplexing allows peers to offer many [protocols](#protocol) over a single connection, which reduces network overhead and makes [NAT traversal](#nat-traversal) more efficient and effective.

Applications built with libp2p get multiplexing "for free" via the [mplex specification](https://github.com/libp2p/specs/tree/master/mplex).

### Peer

A single participant in a peer-to-peer network. While a given peer may support many [protocols](#protocol), it has a single [PeerId](#peerid) which it uses to identify itself to other peers. Often used synonymously with [node](#node).

### PeerId

TODO: link to spec, implementations in JS & Go

### Peer store

TODO: link to spec, implementations in JS & Go

### Peer routing

TODO: Describe general concept, link to mDNS and kad routing implementations

### Peer-to-peer (p2p)

TODO: define p2p network

### Protocol

TODO: define what we mean by "libp2p protocol", protocol handlers, etc. link to [multiplexing](#multiplexing).

### Stream

TODO: Distinguish between the various types of "stream".  Could refer to

- raw tcp connection
- one component of a multistream connection
- node.js streams / pull-streams

### Swarm

TODO: define swarm in libp2p context

### Transport

In libp2p, `transport` refers to the technology that lets us move bits from one machine to another. This may be a TCP network provided by the operating system, a websocket connection in a browser, or anything else capable of implementing the [transport interface](https://github.com/libp2p/interface-transport).  

Note that in some environments such as javascript running in the browser, not all transports will be available. In such cases, it may be possible to establish a [Circuit Relay](#circuit-relay) with the help of a peer that can support many common transports.  Such a relay can act as a "transport adapter" of sorts, allowing peers that can't communicate with each other directly to interact.  For example, a peer in the browser that can only make websocket connections could relay through a peer able to make TCP connections, which would enable communication with a wider variety of peers.


[js-docs-home]: {{< ref "FIXME: link to js implementation doc entry point" >}}
