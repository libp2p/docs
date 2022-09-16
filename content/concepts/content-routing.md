---
title: Content Routing
weight: 5
---

Peer-to-peer networks are inherently difficult to route because of the following 
interdisciplinary routing challenges:

- The lack of universal orchestration that a central sever can provide when 
  querying and retrieving content.
- Not have a central directory that contains information about reaching every peer 
  in the network.
- The presence of high node churn.
- Data classification being communication-expensive.
- Creating a resilient, scalable, and optimal routing protocol that is resistant to 
  sybil attacks and node churn, while being future-proof.

Content requests are done in content addressing through the CID.
If we want to retrieve a file, we send a general request to the network with the CID.

In libp2p, there exists a common content routing interface with operations that allows 
for content lookups:
- Provide: make content available for other peers on the network by their CID. 
- Resolve: locate the peer (content provider) storing the content in the network by hash key.
- Fetch: download the content from the provider using the CID.

Peer routing schemes may be required to find the peers on the network based on the content 
routing protocol; DHT-based routing is an example of this, where a DHT is used as namespace 
that contains peer information about how to contract different peers on the network. 
See the peer routing guide for more details.

<!-- add when published -->

While there are different design approaches for a content routing protocol, the libp2p 
documentation will focus on a DHT-based approach that implements the content routing 
interface: KadDHT-libp2p. Libp2p uses an adpedtation of a Kademila DHT. For other material 
on content routing, please refer to the IPFS documentation.

The DHT provides a key-value store that is maintained by multiple peers on the network. 
Each row is stored by a different peer. The way the network knows which peer is responsible 
for which row is by a distance metric: K-closest neighbor. 

Kademila uses an XOR metric as a distance calculation between nodes and the CID: 
distance(PeerID, CID) = PeerID XOR CID = distance(CID,PeerID)

To know if a node is responsible for storing a specific piece of content, 
that node's `PeerId` and the CID of the content to store are used to calculate 
the distance between that peer and the piece of content. The node with a `PeerID`
closest to the content is responsible for storing that content ID in the 
DHT.

The Kademila DHT in libp2p uses a 256 bit address space as a way to uniquely 
identify all content. In libp2p, this is all the numbers from `0` to `2^256-1`. 
Once the CID is known to the network, libp2p takes `SHA256(PeerID)` and interprets 
it as an integer between `0` and `2^256-1`.

Providing content
