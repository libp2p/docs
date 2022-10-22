---
title: Content Routing
weight: 5
---

Peer-to-peer networks are inherently tricky to route because of the following 
interdisciplinary routing challenges:

- The lack of universal orchestration that a central server can provide when 
  querying and retrieving content.
- Not having a central directory that contains information about reaching every peer 
  in the network.
- The presence of high node churn.
- Creating a resilient, scalable, and optimal routing protocol that is resistant to 
- Resistance against Sybil attacks.
- Forward compatibility

libp2p offers a content routing interface that aims to overcomes these challenges.
The abstract ContentRouting interface follows the following format:

```
interface ContentRouting {
	Provide(CID, bool) error
	FindProviders(CID) [Multiaddr]
}
```

The content router is simply an index of the peer serving the content of interest, 
and a DHT is used to maintain a peer-to-peer index. When retrieving a file using 
content-addressing, the network identifies the file by its content ID (CID). DHTs are 
also commonly used for resolving Peer IDs to addresses, which is separate from content 
routing. See the peer routing guide for more details.

<!-- add when published -->

{{% notice "note" %}}
While there are different design approaches for a content routing protocol, such as
Kademlia DHT, DNS, and BitTorrent trackers, the libp2p 
documentation will focus on a DHT-based approach that implements the content routing 
interface: KadDHT-libp2p. Libp2p uses an adapation of the 
[Kademlia DHT algorithm](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf) 
to route peers.
{{% /notice %}}

For more information about DHTs and the Kademlia implementation, see the [IPFS documentation](https://docs.ipfs.tech/concepts/dht/). 

<!-- to add add diagram -->

A typical content lookup follows this process:

- Peers on the libp2p network maintain routing tables. A peer can send a request 
  through a network gateway to obtain a random list of peers.
- Usually, a peer will either want to add content (provide) or get a piece of content 
  (fetch) to the network. To fetch content, a peer must provide the CID for the content of 
  interest. The peer identifies the neighboring peers as candidate peers for content retrieval. 
  > One of the ways libp2p offers structured peer-to-peer networking is through content closeness. 
  Instead of the arbitrary ownership of content, libp2p peers store data to their closest 
  neighbor and use XOR as a *distance* metric (i.e., the distance between a 
  chunk of content, which is identified by a CID, and a PeerID of a peer, is close to 0).
- A peer will find a set of peers that satisfy content closeness for the CID of interest and request 
  a list of their closest peers to the CID.
- The peer then compares the provided lists to look for a node quorum across the list of 
  peers. This also protects against a potential malicious actor who may have filled out their 
  routing and is dishonest about having the closest peer.
- After identifying the closest peer, the peer either matches with the CID and provides a 
pointer to the content, or, the peer does not have the CID and suggests that the lookup failed.

{{% notice "note" %}}
This generalization assumes that the peer who has the content does not need to be discovered.

Providing content follows a similar approach.
{{% /notice %}}

## Provide: Announce content

Content stays local to peers across the network. Whenever a peer wants to provide content, 
the peer defines a pointer that points to the Peer ID of the peer. The peer generates a key 
based on the CID by performing SHA-256 on the CID. To know if a node is responsible for 
storing a specific piece of content, the peer's Peer Id and the CID of the content of interest
are used to calculate the distance between that peer and content chunk. The node with 
a Peer ID closest to the CID of the content is responsible for storing that CID in the 
DHT. These parameters are stored together in a tuple known as a provider record, 

A provider record is a record of pointers that is distributed to the closest peers of the key. 
Provider records associate a peer's Peer ID with the generated key based on the CID. 
The network uses a pull-model to pull content based on the pointers within the provider record.

Provider records also account for node churn; they expire after 24 hours
and are re-published every 12 hours as peers may go offline or no longer provide 
certain content.

<!-- to add add diagram -->

In addition, peers requesting content can become temporary content providers when 
receiving content. But to become a permanent content provider, the peer must pin the content.
The network clears peer memory of temporary content and unpinned content through garbage 
collection in temporary nodes when over 90% of the peer datastore is reached.

<!-- to add add diagram -->

## Resolve: Retrieve content

To find the peers that are storing a CID of interest, the peer performs a multi-round
iterative lookup. Similar to providing content, the peer generates a key based on the 
CID by performing SHA-256 on the CID. The peer walks across the DHT to obtain
the provider record and a list of k-closest peers storing the content chunk based on their
distance to the CID.

Ideally, the peer will be able to retrieve the multiaddr from the Peer Store to dial
the peer and retrieve the content. If the multiaddr is unknown, the peer will need 
to perform additional peer discovery. The peer can perform another walk by completing a new
DHT query to find the peer's address. 

<!-- to add add diagram -->
