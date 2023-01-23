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
[Kademlia whitepaper](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf)
and is augmented with other systems, such as
[Coral](https://www.cs.princeton.edu/~mfreed/docs/coral-iptps03.pdf) and the
[BitTorrent DHT](https://www.bittorrent.org/beps/bep_0005.html).

Kad-DHT offers a way to find and manage nodes and data on the network by using a
[routing table](https://en.wikipedia.org/wiki/Routing_table) that organizes peers based
on how similar their keys are.

<details>
  <summary>A deeper look</summary>

  The routing table is organized based on a prefix length and a distance metric.
  The prefix length helps to group similar keys, and the distance metric helps to
  find the closest peers to a specific key in the routing table. The table maintains
  a list of `k` closest peers for each possible prefix length between `0` and `L-1`,
  where `L` is the length of the keyspace, determined by the length of the hash
  function used. **Kad-DHT uses SHA-256**, with a keyspace of 256 bits, maintaining
  `k` peers with a shared key prefix for every prefix length between `0` and `255` in
  its routing table.

  The prefix length measures the proximity of two keys in the routing table and
  divides the keyspace into smaller subspaces, called "buckets", each containing nodes
  that share a common prefix of bits in their SHA-256 hash. The prefix length is the
  number of bits that are the same in the two keys' SHA-256 hash. The more leading bits
  that are the same, the shorter the prefix length and the closer the proximity of the
  two keys are considered to be.

  The distance metric is a way to calculate the distance between two keys by taking
  the bitwise exclusive-or (XOR) of the SHA-256 hash of the two keys. The resulting
  hash is a measure of the distance between the two keys, where a distance of `0` means
  the keys are identical, and a distance of `1` means that only one bit is different,
  meaning the two keys are close to each other (i.e. their SHA-256 hashes are similar).

  This design allows for efficient and effective lookups in the routing table when
  trying to find nodes or data that share similar prefixes.

</details>

## Peer discovery

The Kad-DHT uses a process called "peer routing" to discover new nodes in the network.
This process starts by generating a random peer ID and looking it up via the routing
table. The node then contacts the k closest nodes to the peer ID and repeats the process
until it finds the peer or determines that it is not in the network. Nodes also add any
new nodes they discover to their routing table to improve its awareness of the network.

## Content provider discovery

Kad-DHT also includes a feature for content provider discovery, where nodes can look up
providers for a given key. This is done by sending an [RPC message](#rpc-messages) (which uses a
key/value API) to the `k` closest nodes to the key and collecting the responses. The node then
returns the list of providers it has discovered. Check out the
[Kad-DHT content routing document](../../content-routing/kaddht.md) for more information.

## Bootstrap process

To maintain a healthy routing table and discover new network nodes, the Kad-DHT includes
a bootstrap process that runs periodically. The process starts by generating a random peer
ID and looking it up via the peer routing process. The node then adds the closest peers it
discovers to its routing table and repeats the process multiple times. This process also
includes a mechanism to look up its peer ID to improve its awareness of nodes close to itself.

## Client and server mode

The Kad-DHT in libp2p has a concept of a "client" and "server" mode. A node can operate in
one of the modes, depending on the characteristics of the network topology and the properties
of the DHT. For example, publicly routable nodes can operate in server mode, while non-publicly
routable nodes can operate in client mode. The distinction allows restricted nodes to utilize
the DHT, i.e., query the DHT, without decreasing the quality of the distributed hash table.

## RPC messages

There are various RPC messages for performing operations on the DHT,
such as `PUT_VALUE`, `GET_VALUE`, `ADD_PROVIDER`, and `GET_PROVIDERS`. These messages are used
for storing and retrieving key-value pairs and finding providers for a given key.

{{< alert icon="💡" context="note" text="See the Kademlia DHT <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/kad-dht\">technical specification</a> for more details." />}}
