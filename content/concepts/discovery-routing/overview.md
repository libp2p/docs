---
title: "What is Discovery & Routing"
description: "Peer discovery and routing protocols are used to discover and announce services to other peers and find a peer's location, respectively."
weight: 221
---

## Overview

Peer discovery and routing are two essential aspects of P2P networking. In a P2P network,
each node must be able to discover and communicate with other nodes without the need for
a central server.

### Peer Discovery

Peer discovery is the process of finding and announcing services to other available
peers in a P2P network. It allows a peer to discover other peers in the network and
learn about their services. Peer discovery can be done using various protocols, such
as broadcasting a message to all peers in the network or using a bootstrap node to
provide a list of known peers.

### Peer Routing

Peer routing, on the other hand, refers to finding a specific peer's location
in the network. This is typically done by maintaining a routing table or a similar
data structure that keeps track of the network topology. Algorithms such as kbucket
and "routing by gossip" can be used to find the closest peers to a given peer ID.

A peer may use a routing algorithm to find the location of a specific peer and then
use that information to discover new peers in the vicinity. Additionally, a peer may
parallel use both peer routing and peer discovery mechanisms to find new peers and
route data to them. In practice, the distinction between peer routing and peer
discovery is not always clear-cut, and it's worth noting that in a real-world
implementation, discovery and routing usually happen concurrently.

## Discovery and Routing in libp2p

libp2p provides a set of modules for different network-level functionality,
including peer discovery and routing. Peers in libp2p can discover other
peers using various mechanisms, such as exchanging peer addresses over the
network, querying a directory service, or using a Distributed Hash Table (DHT)
to store and retrieve information about available peers.

These methods include, but are not limited to:

- [Rendezvous](rendezvous.md): a protocol that allows peers to exchange peer addresses
  in a secure and private manner.
- [mDNS](mdns.md): a multicast Domain Name System (DNS) protocol that allows peers to
  discover other peers on the local network.
- [Publish/Subscribe](pubsub.md): a protocol that allows peers to subscribe to specific
  topics and receive updates from other peers that are publishing information on those
  topics.
- [DHT](kaddht.md): Distributed Hash Table, libp2p uses a DHT called Kademlia, it assigns
  each piece of content a unique identifier and stores the content on the peer whose
  identifier is closest to the content's identifier.
