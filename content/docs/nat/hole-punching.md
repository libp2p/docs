---
title: "Hole Punching"
description: "The internet is composed of countless networks, bound together into shared address spaces by foundational transport protocols. As traffic moves between network boundaries, it's very common for a process called Network Address Translation to occur. Network Address Translation (NAT) maps an address from one address space to another."
weight: 4
aliases:
    - /concepts/hole-punching
    - /concepts/nat/hole-punching
---

Nodes on a peer-to-peer network can be categorized into two groups:
public and non-public. Public nodes are those nodes that have unobstructed
access to the internet, whereas non-public nodes are located behind some kind
of firewall. This applies to most nodes in home and in corporate network,
as well as mobile phones. In most configurations, both public and non-public
nodes can dial connections to other public nodes. However, it's not possible
to establish a connection from the public internet to a non-public node.

## Dialing a non-public node

Here are a few methods that nodes can use to dial a non-public node:

- UPnP (Universal Plug and Play): A protocol spoken between routers and computers
  inside the network. It allows the computer to request that certain ports be
  opened and forward to that computer.
- Port forwarding: Manually configuring a port forwarding on a router.

### Limitations

In many settings, UPnP is disabled by the router or a firewall.
UPnP may also not work depending on the router's firmware.

Manually opening a port requires technical expertise and does not
enforce authentication or authorization.

### Possible solution: hole punching

#### Relaying overview

Relaying is a mechanism used to send information between two ends.
In the case of non-public nodes:

Node A maintains a permanent connection to a relay node, R, and when node
B wants to connect to node A, it first establishes a connection to node R,
where R forwards all the packets on the connection. Relaying adds additional
latency and is resource intensive as node R needs to handle a lot of traffic.
Using a relay node also requires technical expertise.

#### What if we could use node R to help facilitate a **direct connection** between node A and node B?

In the case where the other options aren't sufficient, networks can
use a technique called hole punching to establish connections with
non-public nodes.

Each node connects to a relay node and shares its external address and port
information. The server temporarily stores the node's
information and relays each node's information to the other. Clients can
use this information to establish direct connections with each other.

Take two nodes, `A` and `B`, that would like the dial each other:

1. The first packet of both nodes (e.g., in the case of TCP, an SYN)
   passes through their respective routers.
2. The routers add a 5-tuple to their router's state table.

   > A router state table (routing table) is data store within a router that lists
   > the routes to particular network destinations.
   > The 5-tuple structure includes the source IP address, source port,
   > destination IP address, destination port, and transport protocol.

3. `PacketA` and `PacketB` "punch holes" into their respective routers'
   firewalls.
4. Both packets arrive at the opposite router.
5. Once `A`'s packet arrives at `Router_B`, `Router_B` checks its state
   table and finds a 5-tuple previously added through the packet sent by
   node B.
6. The routers forward the packets through the "punched holes" to `B`.
   The same occurs with `B`'s packet; upon arriving at `Router_A`, it matches
   a 5-tuple in `Router_A`'s state table and thus forwards the packet to `A`.

The following use case diagram illustrates the above process.

<img src="../../assets/hole-punching/libp2p-hole-punching-2.svg/" alt="hp">

> This process assumes a mechanism to synchronize `A` and `B` simultaneously.

## Hole punching in libp2p

Inspired by the
[ICE protocol](https://datatracker.ietf.org/doc/html/rfc8445),
libp2p includes a decentralized hole punching
feature that allows for firewall and NAT traversal without the need
for central coordination servers like STUN and TURN.

The following sequence diagram illustrates the whole process.

<img src="../../assets/hole-punching/libp2p-hole-punching-4.svg/" alt="hp">

libp2p hole punching can be divided into two phases, a preparation phase and
a hole punching phase.

### Phase I: Preparation

1. [AutoNAT](../autonat): Determine whether a node is dialable,
   as in, discover if a node is behind a NAT or firewall.

   > This is equivalent to the
   > [STUN protocol](https://www.rfc-editor.org/rfc/rfc3489) in ICE.

   <img src="../../assets/hole-punching/libp2p-hole-punching-5.svg/" alt="hp">

   - `B` reaches out to `Other_Peers` (e.g., boot nodes) on the network it
     is on and asks each node to dial it on a set of addresses it suspects
     could be reachable. A libp2p node has multiple ways of discovering its
     addresses, but the most prominent is using the
     [libp2p Identify protocol](https://github.com/libp2p/specs/blob/master/identify/README.md).
   - `Other_Peers` attempt to dial each of `B`'s addresses and report the
     outcome back to `B`.
   - Based on the reports, `B` can gauge whether it is publicly dialable and
     determine if hole punching is needed.

<!-- to add routing reference when available -->
<!-- to add autorelay reference when available -->

1. AutoRelay: Dynamically discover and bind to relay nodes on the network.
   > IPFS discovers the k-closest public relay nodes using a lookup method
   > via Kademlia DHT): `/<RELAY_ADDR>/p2p-circuit/<PEER_ID_B>`

    <img src="../../assets/hole-punching/libp2p-hole-punching-6.svg/" alt="hp">

    - `Other_Peers` outside `B`'s network can dial `B` indirectly through
      a public relay node. In the case of [IPFS](https://ipfs.tech/), each public
      node would serve as a `Relay`. `B` would either perform a lookup on the
      [Kademlia DHT](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)
      for the closest peers to its Peer ID or choose a subset of the public nodes
      it is already connected to.

2. [Circuit Relay](../circuit-relay): Connect to and request
   reservations with the discovered relay nodes. A node can advertise itself as
   being reachable through a remote relay node.

   > This is equivalent to the
   > [TURN protocol](https://datatracker.ietf.org/doc/html/rfc5766) in ICE.

    <img src="../../assets/hole-punching/libp2p-hole-punching-7.svg/" alt="hp">

   - `Relay` can limit the resources used to relay connections (e.g., by the number
     of connections, the time, and bytes) via Circuit Relay v2. In the case of IPFS,
     this allows every public node in the network to serve as a relay without high
     resource consumption.
   - For each discovered `Relay`, `B`:
       - connects to the remote node and requests the Relay node to listen to
         connections on its behalf, known as a reservation;
       - if `Relay` accepts reservation requests, `B` can advertise itself as being
         reachable through `Relay`.

### Phase II: Hole punching

1. [Circuit Relay](../circuit-relay): Establish a secure relay connection
   through the public relay node. Node `A` establishes a direct connection with
   the relay node. Node `B` then requests a relayed connection to node `A` through
   the relay node, creating a bi-directional channel and uses TLS to secure the
   channel.

    <img src="../../assets/hole-punching/libp2p-hole-punching-8.svg/" alt="hp">

    - `A` establishes a relayed connection to `B` via the `Relay` using the
      information contained in `B`'s advertised address.
        - `A` first establishes a direct connection to `Relay` and then
          requests a relayed connection to `B` from `Relay`.
        - `Relay` forwards said request to `B` and accepts.
        - `Relay` forwards the acceptance to `A`.
        - `A` and `B` can use the bi-directional channel over `Relay` to
          communicate.
        - `A` and `B` upgrade the relayed connection with a security protocol
          like TLS.

   <!-- to add dcutr reference when available -->

2. [DCUtR](https://github.com/libp2p/specs/blob/master/relay/DCUtR.md): Use
   DCUtR as a synchronization mechanism to coordinate hole punching.

    <img src="../../assets/hole-punching/libp2p-hole-punching-9.svg/" alt="hp">

    - `A` sends a `Connect` message to `B` through `Relay`.
        - `Connect` contains the addresses of A. libp2p offers multiple
          mechanisms to discover one's addresses, e.g., via the libp2p Identify
          protocol.
    - `B` receives the `Connect` message on the relayed connection and replies
      with a `Connect` message containing its (non-relayed) addresses.
    - `A` measures the time between sending its message and receiving `B`'s
      message, thereby determining the round-trip time between `A` and `B` via `Relay`.
    - Then, `A` sends a `Sync` message to `B` on the relayed connection.
    - `A` waits for half the round-trip time, then directly dials `B` via the
      addresses received in `B`'s `Connect`.
    - As soon as `B` receives `A`'s `Sync` message, it directly dials `A` with the
      addresses provided in `A`'s `Connect` message.
    - Once `A` and `B` dial each other simultaneously, a hole punch occurs.

### Resources

- This guide is a byproduct of the
  [Hole punching in libp2p - Overcoming Firewalls](https://blog.ipfs.tech/2022-01-20-libp2p-hole-punching/)
  blog post by Max Inden.
- Research paper on
  [decentralized hole punching by Protocol Labs Research](https://research.protocol.ai/publications/decentralized-hole-punching/)
- Keep up with the [libp2p implementations page](https://libp2p.io/implementations/) for
  the state on different hole punching implementations.
