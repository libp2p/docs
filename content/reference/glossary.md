### Client / Server

A network architecture defined by the presence of central "server" programs which provide services and resources to a (usually much larger) set of "client" programs.  Typically clients do not communicate directly with one another, instead routing all communications through the server, which is inherently the most privileged member of the network.

### DHT

A [distributed hash table](https://en.wikipedia.org/wiki/Distributed_hash_table) whose contents are spread throughout a network of participating peers. Much like an in-process hash table, values are associated with a key and can be retrieved by key. Most DHTs assign a portion of the addressable key space to nodes in a deterministic manner, which allows for efficient routing to the node responsible for a given key.

Since DHTs are a foundational primitive of many peer-to-peer systems, libp2p provides a [Kademlia](https://en.wikipedia.org/wiki/Kademlia)-based DHT implementation in [Go](https://github.com/libp2p/go-libp2p-kad-dht) and [javascript](https://github.com/libp2p/js-libp2p-kad-dht).

libp2p uses the DHT as the foundation for one of its [peer routing](#peer-routing) implementations, and systems built with libp2p often use the DHT to provide metadata about content, advertise service availability, and more.

### NAT

TODO: Network address translation - describe, link to NAT traversal

### NAT Traversal

TODO: Describe libp2p approach, link to Circuit Relay, AutoRelay

### Node

While the javascript implementation of libp2p supports [node.js](https://nodejs.org), generally when you see "node" in these docs, we're referring to a [peer](#peer) in a p2p network. The term "node" is often used when discussing the graph topology of a given network structure, or to refer to an actual software process running on a machine.

### mDNS

[Multicast DNS](https://en.wikipedia.org/wiki/Multicast_DNS) is a protocol for service discovery on a local network.  One of libp2p's [peer routing](#peer-routing) implementations leverages mDNS to discover local nodes quickly and efficiently.

### Multiplexing

Multiplexing (or "muxing"), refers to the process of combining multiple streams of communication over a single logical "medium".  For example, we can maintain multiple independent data streams over a single TCP network connection, which is itself of course being multiplexed over a single physical connection (ethernet, wifi, etc).

Multiplexing allows peers to offer many [protocols](#protocol) over a single connection, which reduces network overhead and makes [NAT traversal](#nat-traversal) more efficient and effective.

Applications built with libp2p get multiplexing "for free" via the [mplex]( )

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
