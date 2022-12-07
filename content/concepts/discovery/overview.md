---
title: "What is Peer Discovery"
description: "Peer discovery protocols are used to discover and announce services to other peers."
weight: 221
---

## Overview

Distributed networks require a way to discover peers. Peer discovery is the
process of using a discovery protocol to discover and announce services to other
available peers. This is using broadcast messages, where a node sends out a message
asking if any other nodes on the network are available. Peer discovery requires each
node in a network to be able to discover other nodes without the need for a central
server.

## Peer discovery in libp2p

Peers can discover other peers in libp2p using a variety of mechanisms, such as
exchanging peer addresses over the network, querying a directory service, or using a
DHT (distributed hash table) to store and retrieve information about available peers.
The process of peer discovery varies on the networking stack or protocol being used to
connect peers.

Generally, peer discovery is a function in respect to a topic that returns a list of
peers, usually their multiaddr and port information.

The methods for peer discovery in libp2p are, but not limited to:

- [rendezvous](rendezvous);
- [mDNS](mdns);
- [publish/subscribe](../pubsub/overview.md)
- and using a [DHT](../../concepts/introduction/protocols/dht.md).
