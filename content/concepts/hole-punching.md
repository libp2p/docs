---
title: Hole Punching
weight: 3
---

## Types of nodes

Nodes on the public internet can be divided into two groups: 
public and non-public. Most nodes are not publicly accessible as 
routers act as firewalls and allow for NATs. 

To be clear, a non-public node from a standard LAN:

- can dial other public nodes;
- cannot dial non-public nodes.

Likewise, a public node on the internet:

- can dial other public nodes;
- cannot dial non-public nodes.

### How can a node dial a non-public node?

Here are a few methods that nodes can use to dial a non-public node:

- UPnP (Universal Plug and Play): A protocol that enables nodes 
  to discover and connect by automatically opening
  ports into a firewall.
- Port forwarding: Manually configuring a port forward on a router.
- Traversal Using Relay NAT (TURN): A protocol that can traverse
  a NAT, allowing a client to obtain IP addresses and ports from 
  relaying.

### Limitations

UPnP automates the process of node discovery and connectivity. Still, 
it may not be available everywhere, and there can posses the risk
of establishing connections with untrustworthy nodes as the protocol
does not enforce authentication or authorization. Manually opening a
port requires technical expertise and does not enforce 
authentication or authorization. Using a relay node also requires
technical expertise. Relaying adds additional latency and is resource
intensive.

### Possible solution: hole punching

In the case where the other options aren't sufficient, networks can 
use a technique called hole punching to establish connections with 
non-public nodes.

Each node connects to an unrestricted third-party server and 
shares its external and internal address and port information.
The server temporarily stores the node's information and relays 
each node's information to the other. Clients can use this 
information to establish direct connections with each other.

Take two nodes, `A` and `B`, that would like the dial each other:

1. The first packet of both nodes (e.g., in the case of TCP, an SYN) 
   passes through their respective routers.
2. The routers add a 5-tuple to their router's state table. 
3. `Packet A` and `B` "punch holes" into their respective routers' 
   firewalls.
4. Both packets arrive at the opposite router.
5. Once `A`'s packet arrives at `router B`, `router B` checks its state 
   table and finds a 5-tuple previously added through the packet sent by 
   node B. 
6. The routers forward the packets through the "punched holes". 6. It 
   then forwards the packet to `B`. The same occurs with `B`'s packet; 
   upon arriving at `router A`, it matches a 5-tuple in `router A`'s state 
   table and thus forwards the packet to `A`.
  
The following use case diagram illustrates the above process.

![](https://i.imgur.com/0k2Zlj3.png)

{{% notice "note" %}}
This process assumes a mechanism to synchronize `A` and `B` simultaneously.
{{% /notice %}}

## Hole punching in libp2p

Inspired by the 
[ICE protocol](https://datatracker.ietf.org/doc/html/rfc8445) 
specified by the IETF, libp2p includes a decentralized hole punching 
feature that allows for firewall and NAT traversal without the need 
for central coordination servers like STUN and TURN. 

The following sequence diagram illustrates the whole process.

![](https://i.imgur.com/sMGMfGZ.png)

libp2p hole punching can be derived in two phases, a preparation phase and 
a hole punching phase.

### Phase I: Preparation

1. [AutoNAT](/concepts/nat/#autonat): Determine whether a node is dialable, 
   as in, discover if a node is behind a NAT or firewall.
   
   > This is equivalent to the 
   > [STUN protocol](https://www.rfc-editor.org/rfc/rfc3489) in ICE.

   ![](https://i.imgur.com/NeufUm7.png)
   
   - `B` reaches out to `Other_Peers` (e.g., boot nodes) on the network it 
     is on and asks each node to dial it on a set of addresses it suspects 
     could be reachable. 
   - `Other_Peers`attempt to dial each of `B`'s addresses and report the 
     outcome back to `B`. 
   - Based on the reports, `B` can gauge whether it is publicly dialable and 
     determine if hole punching is needed.
   
<!-- to add routing reference when available -->
1. Routing: Discover the k-closest public Relay nodes using a lookup method 
   (e.g. IPFS uses Kademlia DHT): `/<RELAY_ADDR>/p2p-circuit/<PEER_ID_B>`

    ![](https://i.imgur.com/cdqmJCo.png)
    
    - `Other_Peers` outside `B`'s network can dial `B` indirectly through 
      a public Relay node. In the case of [IPFS](https://ipfs.tech/), each public 
      node would serve as a `Relay`. `B` would either perform a lookup on the 
      [Kademlia DHT](https://github.com/libp2p/specs/blob/master/kad-dht/README.md) 
      for the closest peers to its Peer ID or choose a subset of the public nodes 
      it is already connected to.
   
2. [Circuit Relay](/concepts/circuit-relay): Connect to and request 
   reservations with the discovered Relay nodes. A node can advertise itself as being 
   reachable through a remote Relay node. 
   
   > This is equivalent to the 
   > [TURN protocol](https://datatracker.ietf.org/doc/html/rfc5766) in ICE.

    ![](https://i.imgur.com/kqRnQUV.png)

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

1. [Circuit Relay](/concepts/circuit-relay): Establish a secure relay connection 
   through the public Relay node. The node establishes a direct connection with 
   the Relay node. It then requests a relayed connection to the other node through 
   the Relay node, creating a bi-directional channel and using TLS to secure the 
   channel.
   
    ![](https://i.imgur.com/zoIWcwK.png)

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

    ![](https://i.imgur.com/wXehUlC.png)

    - `A` sends a `Connect` message to `B` through `Relay`. 
        - `Connect` contains the addresses of A. libp2p and offers multiple 
          mechanisms to discover one's addresses, e.g., via the libp2p identify 
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
- Keep up with the [libp2p implementations page](https://libp2p.io/implementations/) for 
  the state on different hole punching implementations. 
