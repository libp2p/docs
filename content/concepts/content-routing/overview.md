---
title: "What is Content Routing"
description: "Learn about Noise in libp2p."
weight: 218
---

## Overview

The most widely used method for accessing data today is via location addressing,
where the desired content can be located by its name on a specific server.
This makes routing simple, as the server information is readily available.
For example, the URL `example.com/cat.jpg` informs us that the server with
the domain name `example.com` has a file named `cat.jpg`.

However, with content-addressed data the content itself serves as the address.
Routing becomes a challenge since we only know what the data looks like, not who
has it.  This is where content routing comes into play, giving us a way to
figure out who has the content and how we can communicate with them.

Content routing is the abstract process of identifying a specific peer that
holds certain data and the means to connect to them within a P2P network.

One of the main challenges of content routing in P2P networks is scalability.
As the number of peers increases, it becomes more difficult to efficiently find
and retrieve the desired content due to the larger number of potential sources.

In general, specific characteristics of P2P networks complicate this process, including:

- The lack of universal orchestration that a central server can provide when
  querying and retrieving content.
- Not having a central directory that contains information about how to reach
  every peer in the network.
- The presence of high node churn.
- Creating a resilient, scalable, and optimal routing protocol resistant to
  Sybil attacks.
- Forward compatibility.

Content routing protocols have to deal with these problems while still providing
a way to find out who has the requested data.

## Content Routing in libp2p

```go
interface ContentRouting {
 Provide(CID, bool) error
 FindProviders(CID) [Multiaddr]
}
```

In libp2p, content routing is based on a [Distributed Hash Table (DHT) called
Kademlia](../introduction/protocols/kaddht.md). At a high level, the DHT stores
the content ID (CID) as a key and the value is the list of peers who can provide
it. The DHT handle spreading the load across the network and building in resiliency.

More information on Kademlia can be found in the [Kad-DHT content routing document](kaddht.md).

{{< alert icon="" context="note">}}
While there are different design approaches for a content routing protocol, such as
Kademlia DHT, DNS, and BitTorrent trackers, libp2p provides a Kademlia
implementation that applications can use to find and provide content.
{{< /alert >}}
