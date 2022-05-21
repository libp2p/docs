---
title: Peer Routing
weight: 5
---

One of the many mechanisms that libp2p uses for peer routing is Kademlia DHT. We will dive into how it works in this article, this will help you further understand more advanced topics.

## Static DHT

In this example, we are going to assume for now that our DHT is static, in the sense that no one joins DHT and no one leaves.

### System Description

When a peer is added to the DHT, each peer is assigned a peer ID. Kademlia provides an efficient lookup algorithm that locates successively “closer” nodes to any desired ID.

In Kademlia, peers are sorted as key-value pairs in the DHT. A peerID is stored as a key and the [address](/concepts/addressing/) (or IP address) of a that peer stored as a value.

Kademlia treats peers as leaves in a binary tree. We store hashes of Peer IDs in leaves, which are represented as binary numbers. Notice, that we do not need to store the whole hash to specify the peer. We can store only prefix if prefix is unique.

Leaves on the tree that are not peers represent [content](/concepts/content-routing/) which is stored by some close nodes.

![Kademlia-system](Kademlia-system.png)

The red node in this diagram has the prefix `001`. Traversing this graph from the top to the bottom along the edges, you will notice a blue node with the prefix `11101`, as well as yellow leaves which are other peers.

For any given node, Kademlia divides the whole binary tree into a series of successively lower subtrees. The highest subtree consists of the half of the binary tree not containing the original node. The next subtree consists of the half of the remaining tree not containing the next highest node, and so on.

You can see here for node `001` there are three levels of subtrees are also circle, consisting of all nodes with prefixes `1` (highest level subtree) , `01`, `000` (lowest level subtree).

The Kademlia protocol ensures that every node knows of at least one node in each of its subtrees, if that subtree contains a node. This guarantees that any node can be located by it's peer ID.

Let's see how once can locate in an example. We will call the red node 'Bob', with the prefix `001.` We will call the yellow node Alice, with the prefix `01`

_A brief reminder_: Alice's peerID is a key in the DHT, and the value of this key is Alice's IP address.

Bob can locate Alice in this example. Bob knows Alice's peerID and he needs to get her IP address. From the subtree with the prefix `1` Bob knows a peer with prefix `101`. He sends a message to their address, where he asks for Alice's address.

![1-hop](1-hop.png)

Peer `100` doesn't have Alice's key. But they have key of node `110` from their subtree which locates Alice better! And we are doing second hop:

![2-hop](2-hop.png)

Peer `110` also doesn't have Alice's key, but they again locate Alice better and send request to node with prefix `1111`.

![3-hop](3-hop.png)

Peer `1111` stores Alices peer id and can send the key to the Bob! This is how routing works and here is full scheme:

![final-hop](final-hop.png)

Peer `1111` sends response directly to Bob, since each request in this chain had Bob's address.

### Routing table

The place where one node stores info about other nodes is called a routing table. The routing table is a binary tree whose leaves are `k-buckets`.

### k-buckets

Take a look at the initial tree:
![Kademlia-system](Kademlia-system.png)
See this circled sub-trees? Remember that the Kademlia protocol ensures that every node knows of (and can locate) at least one node in each of its subtrees. If that subtree contains a node. `k-bucket` of a sub-tree is a set of that nodes. Once again: from each subtree we take only those nodes that we know - and we call it `k-bucket`. In out case `k-buckets` for Bob look like this

![k-buckets](k-buckets.png)

Each `k-bucket` covers some range of the ID space, and together the `k-buckets` cover the entire peer ID space with no overlap.

## Dynamic DHT

Okay, that was it for static DHT. And the gap from our current state to a fully dynamic DHT is not as far away as it seems. Let us first consider how we can extend this protocol to support computers sporadically leaving.

### Peers Leaving

Let us assume that we have some known parameter `k` that represents some given number of computers. This number should be a value such that it is extremely unlikely that all of those computers will leave the network in the same hour. The original Kademlia paper that the `k` value should be 20.

Next, our `k-bucket` should, instead of storing just 1 computer, store `k` computers within that `k-bucket’s` range. Thus, with high likelihood, there will always be at least one computer online in each of a computer’s `k-buckets`.

And, when hopping, instead of asking one computer from the `k-bucket` we will be asking `k` number of peers. Some may not reply, but not all.

To check if each node is still alive we can ping it periodically. If node doesn't respond in the allotted time it will be marked as non-responding and eventually replace it with another.

How do we become aware of new computers that could fit into our unfilled `k-buckets`? We can perform lookups on random ids within a `k-bucket’s` id range (the range is defined by all leaves that are direct descendants of the `k-bucket’s` corresponding internal node, which is not a leaf, in the complete tree) and thus learn about other computers within that `k-bucket`, if they exist. This is called a _bucket refresh_.

### Peers Joining

To join the DHT new computer, which we will call `Eve`, must know at least on IP address of a computer which is in the network. Then `Eve` will perform a lookup of herself to get closest known computers which are already aware of `Eve`. After that `Eve` will perform a _bucket refresh_ for all `k-buckets` from the closest known computers to `Eve`.

This will populate the `Eve's` routing table based on the correctness of the lookup algorithm and the fact that the routing tables of other computers are sufficiently populated. In addition, all computers that are being queried by `Eve` will become aware of `Eve` in the process and thus will have the opportunity to insert `Eve` into their own `k-buckets` if their corresponding bucket is not already full.

## More information

It will be useful to read the original Kademlia [whitepaper](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf).

[libp2p Kademlia specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)

In addition take a look at [libp2p kademlia implementation on go](https://github.com/libp2p/go-libp2p-kad-dht).

For more detailed informationg check out the article from [Stanford Code the Change](https://codethechange.stanford.edu/guides/guide_kademlia.html).
