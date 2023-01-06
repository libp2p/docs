---
title: "What is libp2p"
description: libp2p is a modular system of protocols, specifications, and libraries that enable the development of peer-to-peer network applications.
weight: 10
aliases:
  - "/introduction/what-is-libp2p"
---

Welcome to the libp2p documentation portal!

The libp2p documentation portal aims to provide a comprehensive guide about libp2p.
It covers the various components of libp2p, including supported transport
protocols, nat traversal, peer discovery, and more.

This portal is an essential resource for developers who want to learn about the
capabilities and features of libp2p, as well as for those who are already familiar
with libp2p and are looking for more advanced guidance. Whether you are just getting
started with P2P networking, or you are an experienced developer looking to
build the next generation of distributed applications, the libp2p documentation
has something for you.

If you have any questions or suggestions as you navigate the documentation,
please don't hesitate to [reach out](../contribute/community.md), or help
improve the documentation by
[contributing to the site](https://github.com/libp2p/docs\).

To get started, let's begin with an overview of libp2p and its key features and
capabilities.

## A modular networking stack

libp2p, (short for "library peer-to-peer", always written in lowercase as "libp2p")
is a peer-to-peer (P2P) networking framework that enables the development
of P2P applications. It consists of a collection of protocols, specifications, and
libraries that facilitate P2P communication between network participants, known as
"[peers](../fundamentals/peers.md)."

P2P networks are decentralized networks in which participants communicate directly with
one another on a relative "equal footing." No central server or
authority controls the network, and all peers can communicate with one another
directly. P2P networks do not require a privileged set of "servers" that behave differently
from their "clients," as in the predominant
[client-server model](https://en.wikipedia.org/wiki/Client%E2%80%93server_model).
Instead, all peers in a P2P network are treated equally and can send and receive data
to and from other peers.

P2P networks can take many forms, including file-sharing systems like
[BitTorrent](https://www.bittorrent.com/), blockchain networks like [Bitcoin](https://bitcoin.org/en/)
and [Ethereum](https://ethereum.org/en/), and decentralized communication standards like
[Matrix](https://matrix.org/). These systems all have different challenges and tradeoffs,
but they share the goal of improving upon the traditional client-server networking model.

libp2p was initially developed as part of the [InterPlanetary File System (IPFS)](https://ipfs.tech/)
project as its wire protocol but has since phased out into a networking stack that has been adopted
by a wide range of other projects as a networking layer. It provides a set of specifications that
can be adapted to support various protocols, allowing libp2p applications to operate in diverse
runtime and networking environments.

In the context of the internet, the [OSI model](https://en.wikipedia.org/wiki/OSI_model) and the
[TCP/IP model](https://en.wikipedia.org/wiki/Internet_protocol_suite) are conceptual models that provide
a framework for understanding how networking protocols operate and interact. While these models offer
a useful way to understand the functions and roles of different networking protocols, the actual
implementations of networking protocols on the internet are often more complex and do not follow these
models exactly.

If we consider the TCP/IP model, for instance, the primary focus of libp2p is on the
Transport layer and the Application layer. However, these conceptual models have shortcomings.
For example, certain tasks may be unnecessarily repeated across multiple layers, leading to
inefficiencies. Additionally, some information may be hidden between layers, which can hinder
opportunities for improvement.

## Why libp2p?

libp2p was designed to address the limitations of traditional P2P networking approaches and existing
network models, with the goal of enabling the distributed web. There are several reasons to
consider using libp2p as a networking layer to create a robust P2P application:

- **Modularlity**: libp2p is designed to be modular, allowing developers to mix and match different components
  to meet the needs of their particular application. This makes it easy to customize the networking stack
  to fit the specific requirements of any P2P application. libp2p also supports
  [stream multiplexing](../multiplex/overview.md), which allows multiple streams of data to be transmitted
  over a single connection, improving efficiency and enabling more advanced communication patterns.

  - **Transport agnosticism**: libp2p provides a set of specifications that can be adapted to support various
    [transport protocols](../transports/overview.md), allowing libp2p applications to operate in various runtime
    and networking environments. This makes it possible to use libp2p in a variety of scenarios, regardless of
    the underlying transport protocol.

  - **Versatility**: In addition to being transport agnostic, libp2p offers a range of discovery mechanisms,
    data storage and retrieval patterns, and is also
    [implemented in many programming languages](https://libp2p.io/implementations/), providing developers
    with great flexibility when building P2P applications.

- **Security**: libp2p includes [several security features](../security/security-considerations.md), such
  as peer identity verification using public key cryptography, [encrypted communication](../secure-comm/overview.md) between peers using modern cryptographic algorithms, and protection against network attacks through the
  use of [mitigation techniques](../security/dos-mitigation.md).

- **Interoperability**: libp2p is designed to be interoperable with different implementations and aims to
  communicate with other P2P systems, allowing different libp2p-based applications to communicate
  seamlessly. This helps to promote a healthy, interconnected ecosystem of P2P applications.

- **Resiliency**: P2P networks are often more resilient than traditional client-server networks,
  as there is no single point of failure. libp2p includes features such as [peer discovery](../discovery/overview.md)
  and [content routing](../routing/overview.md) that help to ensure that the network remains available and
  accessible even if some peers are offline or unreachable. libp2p is equipped with [NAT traversal](../nat/overview.md)
  capabilities that allow P2P communication between peers even when they are behind NAT devices or firewalls.
  Additionally, libp2p is designed to be fault-tolerant, with built-in mechanisms for detecting and recovering
  from network disruptions.

- **Efficiency**: P2P networks can be more efficient in resource utilization, as data is
  distributed across multiple peers rather than stored on a central server. libp2p includes various storage
  and retrieval patterns that allow developers to distribute data efficiently across the network, making it
  possible to store and retrieve data in a cost-effective and scalable way. One such pattern is
  [publish/subscribe (pubsub)](../pubsub/overview.md), which allows a sender (publisher) to send a message to
  multiple recipients (subscribers) without the publisher having to know who the subscribers are. libp2p
  implements pubsub through the use of protocols like [gossipsub](../pubsub/gossipsub.md), providing developers
  with a flexible and efficient means of exchanging data and messages within their P2P applications.

- **Decentralization**: One of the main advantages of P2P networks is their decentralized nature, allowing
  them to operate without a central authority. libp2p is designed to facilitate decentralized
  communication between peers, making it possible to build P2P applications resistant to censorship and more
  resilient in the face of network disruptions.
