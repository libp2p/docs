---
title: "What is Peer Discovery"
description: "Peer discovery protocols are used to discover and announce services to other peers."
weight: 221
---

## Overview

Distributed networks require a way to discover peers. Peer discovery in distributed networks
is the process of using a discovery protocol to discover and announce services to other
available peers. Peer discovery requires each node in a network to be able to discover other
nodes without the need for a central server.

## Peer discovery in libp2p

Peers can discover other peers in libp2p using a variety of mechanisms, such as
exchanging peer addresses over the network, querying a directory service, or using a
[DHT (distributed hash table)](/concepts/fundamentals/dht) to store and retrieve information about
available peers. The process of peer discovery varies on the composition of protocols being
used to connect peers.

Generally, peer discovery is a function in respect to a topic that returns a list of
peers, usually their multiaddr and port information.

The methods for peer discovery in libp2p are, but are not limited to:

- [rendezvous](rendezvous);
- [mDNS](mdns);
- [publish/subscribe](/concepts/pubsub/overview.md)
- and using a [DHT](/concepts/introduction/protocols/dht.md).
