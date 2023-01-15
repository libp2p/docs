---
title: "Kad-DHT"
description: "The Kad-DHT subsystem in libp2p can be used for content routing."
weight: 219
---

## Content Closeness

The concept of "content closeness" is used to determine the location of content on the network.
In this system, each peer on the libp2p network maintains a routing table that can be used
to find other peers on the network.

When a peer wants to add or retrieve content, it first identifies a set of potential peers that
are likely to have the content based on their "distance" to the content using the XOR metric.
The peer then requests a list of the closest peers to the content from the potential peers
and compares the lists to find a "quorum" of peers that are likely to have the content.

Once the closest peer is identified, the peer can retrieve or announce the
content to the network. The network uses a pull model to retrieve content, so the peer who wants the
content must request it from the closest peer.

## Provide: Announce Content

When a peer wants to announce content to the network, it creates a "provider record" that associates
the peer's Peer ID with the content's identifier. The peer generates a key based on the content
identifier by performing a SHA-256 hash. The peer then distributes the provider record to the
closest peers to the key.

Peers can become temporary content providers when receiving content, but to become a permanent content
provider, the peer must "pin" the content. The network clears peer memory of temporary content and
unpinned content through garbage collection in temporary nodes when over 90% of the peer data store is
reached. Provider records also account for node churn, meaning that they expire after a certain time
and are re-published at regular intervals to ensure that the information is up-to-date.

## Resolve: Retrieve Content

When a peer wants to retrieve content from the network, it generates a key based on the content
identifier by performing SHA-256 on it and walking across the DHT to obtain the provider record and a
list of k-closest peers storing the content chunk based on their distance to the content identifier.

Ideally, the peer will be able to retrieve the multiaddr from the Peer Store to dial the peer and
retrieve the content. If the multiaddr is unknown, the peer will need to perform additional peer
discovery by completing a new DHT query to find the peer's address.

<!-- DIAGRAMS COMING SOOON -->
