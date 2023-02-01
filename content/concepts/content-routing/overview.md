---
title: "What is Content Routing"
description: "Learn about Noise in libp2p."
weight: 218
---

## Overview

The most widely used method for accessing data today is via addressing,
where the desired content can be located by its name on a specific server.
This makes routing simple as the server information is readily available.
For example, the URL "example.com/cat.jpg" informs us that the server with
the domain name "example.com" has a file named "cat.jpg".

However, when accessing content-addressed data, where the content itself
serves as the addressing mechanism, routing becomes a challenge when only
the hash value of the content is known. This is where content routing comes
into play, providing a solution to the problem of determining who has the
content given only its hash value.

Content routing refers to the process of identifying a specific peer that
holds certain data and the means to connect to them within a P2P network.

One of the main challenges of content routing in P2P networks is scalability.
As the number of peers increase, it becomes more difficult to efficiently find
and retrieve the desired content due to the larger number of potential sources.

In general, specific characteristics of P2P networks complicate this process, including:

- The lack of universal orchestration that a central server can provide when
  querying and retrieving content.
- Not having a central directory that contains information about reaching every peer
  in the network.
- The presence of high node churn.
- Creating a resilient, scalable, and optimal routing protocol resistant to Sybil attacks.
- Forward compatibility.

Content routing protocols have to deal with these problems while still providing a way to
find out who has the requested data.

## Content Routing in libp2p

libp2p provides a set of modules for different network-level functionality, including
a content routing interface.

```go
interface ContentRouting {
 Provide(CID, bool) error
 FindProviders(CID) [Multiaddr]
}
```

In libp2p, content routing is based on a
[Distributed Hash Table (DHT) called Kademlia](../introduction/protocols/kaddht.md).
Kademlia assigns each piece of content a unique identifier and stores the information
of the peer holding the content whose identifier is closest to the content's
identifier. This allows for efficient routing, reducing the number of possible routes.
A content router is used to find peers that have requested content and tells the network
that a peer can provide certain content.

More information can be found in the [Kad-DHT content routing document](kaddht.md).

{{< alert icon="" context="note">}}
While there are different design approaches for a content routing protocol, such as
Kademlia DHT, DNS, and BitTorrent trackers, libp2p provides a Kademlia
implementation that applications can use to find and provide content.
{{< /alert >}}
