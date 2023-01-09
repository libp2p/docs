---
title: "Fetch"
description: ""
weight: 24
---

## Fetch in libp2p

The Fetch protocol is a simple data retrieval protocol used in
libp2p to allow one node, A, to request data from another node, B,
based on a given [key](../core-abstractions/keys.md). If either node
breaks from the protocol, either by disconnecting or sending invalid
data, the behavior of the other node is not guaranteed.

The Fetch protocol, identified by the protocol ID `/libp2p/fetch/0.0.1`,
follows the contract: `Fetch(key) (value, statusCode)`, where `key` is the
data to be retrieved, `value` is the retrieved data, and `statusCode` is a
code indicating the result of the fetch request.

Fetch is used as a means to improve the performance of the
[IPNS (InterPlanetary Name System)](https://docs.ipfs.tech/concepts/ipns/) by
creating a persistence layer on top of the
[PubSub (publish-subscribe) protocol](../pubsub/overview.md).

It can also be used to augment other protocols, such as adding the ability to
directly request data from peers in a [DHT (distributed hash table)](dht.md).
