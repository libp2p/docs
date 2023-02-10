---
title: "Kademlia DHT"
description: "The libp2p Kad-DHT subsystem is an implementation of the Kademlia
DHT, a distributed hash table that is designed for P2P networks."
weight: 25
---

## Overview

The Kademlia Distributed Hash Table (DHT), or Kad-DHT, is a distributed hash table
that is designed for P2P networks.

Kad-DHT in libp2p is a subsystem based on the
[Kademlia whitepaper](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf).

Kad-DHT offers a way to find nodes and data on the network by using a
[routing table](https://en.wikipedia.org/wiki/Routing_table) that organizes peers based
on how similar their keys are.

<details>
  <summary>A deeper look</summary>

  The routing table is organized based on a prefix length and a distance metric.
  The prefix length helps to group similar keys, and the distance metric helps to
  find the closest peers to a specific key in the routing table. The table maintains
  a list of `k` closest peers for each possible prefix length between `0` and `L-1`,
  where `L` is the length of the keyspace, determined by the length of the hash
  function used. **Kad-DHT uses SHA-256**, with a keyspace of 256 bits, trying to maintain
  `k` peers with a shared key prefix for every prefix length between `0` and `255` in
  its routing table.

  The prefix length measures the proximity of two keys in the routing table and
  divides the keyspace into smaller subspaces, called "buckets", each containing nodes
  that share a common prefix of bits in their SHA-256 hash. The prefix length is the
  number of bits that are the same in the two keys' SHA-256 hash. The more leading bits
  that are the same, the shorter the prefix length and the closer the proximity of the
  two keys are considered to be.

  The distance metric is a way to calculate the distance between two keys by
  taking the bitwise exclusive-or (XOR) of the SHA-256 hash of the two keys. The
  result is a measure of the distance between the two keys, where a distance of
  `0` means the keys are identical, and a distance of `1` means that only one
  bit is different, meaning the two keys are close to each other (i.e. their
  SHA-256 hashes are similar).

  This design allows for efficient and effective lookups in the routing table when
  trying to find nodes or data that share similar prefixes.

</details>

## Peer routing

The Kad-DHT uses a process called "peer routing" to discover nodes in the
network. When looking for a peer, the local node contacts the `k` closest nodes to
the remote peer's ID asking them for closer nodes. The local node repeats the
process until it finds the peer or determines that it is not in the network.

## Content provider routing

Kad-DHT also includes a feature for content provider discovery, where nodes can
look up providers for a given key. The local node again contacts the `k` closest
nodes to the key asking them for either providers of the key and/or closer nodes
to the key. The local node repeats the process until it finds providers for the
key or determines that it is not in the network.

## Bootstrap process

To maintain a healthy routing table and discover new nodes, the Kad-DHT includes
a bootstrap process that runs periodically. The process starts by generating a random peer
ID and looking it up via the peer routing process. The node then adds the closest peers it
discovers to its routing table and repeats the process multiple times. This process also
includes looking up its own peer ID to improve awareness of nodes close to itself.

{{< alert icon="💡" context="note" text="See the Kademlia DHT <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/kad-dht\">technical specification</a> for more details." />}}
