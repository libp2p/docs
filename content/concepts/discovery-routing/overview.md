---
title: "What is Discovery & Routing"
description: "Peer discovery and routing protocols are used to discover and announce services to other peers and find a peer's location, respectively."
weight: 221
---

## Overview

Peer discovery and routing are two essential aspects of P2P networking. In a P2P network,
each node must be able to discover and communicate with other nodes without the need for
a central server.

### Peer discovery

Peer discovery is the process of finding and announcing services to other available
peers in a P2P network. Peer discovery can be done using various protocols, such
as broadcasting a message to all peers in the network or using a bootstrap node to
provide a list of known peers.

### Peer routing

Peer routing, on the other hand, refers to finding a specific peer's location
in the network. This is typically done by maintaining a routing table or a similar
data structure that keeps track of the network topology.

Different algorithms can be used to find the "closest" neighboring peers to a given peer ID.
A peer may use a routing algorithm to find the location of a specific peer and then
use that information to discover new peers in the vicinity. Additionally, a peer may
use both peer routing and peer discovery mechanisms in parallel to find new peers and
route data to them.

{{< alert icon="" context="note">}}
In practice, the distinction between peer routing and peer
discovery is not always clear-cut, and it's worth noting that in a real-world
implementation, discovery and routing usually happen concurrently.
{{< /alert >}}

## Discovery and routing in libp2p

libp2p provides a set of modules for different network-level functionality,
including peer discovery and routing. Peers in libp2p can discover other
peers using various mechanisms, such as exchanging peer
[multiaddresses]({{< relref "/concepts/fundamentals/addressing.md" >}}) over the
network, querying a directory service, or using a distributed hash table (DHT)
to store and retrieve information about available peers.

These methods include, but are not limited to:

- [Rendezvous]({{< relref "/concepts/discovery-routing/rendezvous.md" >}}): a protocol that allows peers to exchange peer multiaddresses
  in a secure and private manner.
- [mDNS]({{< relref "/concepts/discovery-routing/mDNS.md" >}}): a multicast Domain Name System (DNS) protocol that allows peers to
  discover other peers on the local network.
- [DHT]({{< relref "/concepts/discovery-routing/kaddht.md" >}}): Distributed Hash Table, libp2p uses a DHT called Kademlia, it assigns
  each piece of content a unique identifier and stores the content on the peer whose
  identifier is closest to the content's identifier.
