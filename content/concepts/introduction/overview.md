---
title: "What is libp2p"
description: libp2p is a modular system of protocols, specifications, and libraries that enable the development of peer-to-peer network applications.
weight: 10
aliases:
  - "/introduction/what-is-libp2p"
---

Welcome to the libp2p documentation site!

The libp2p documentation site aims to provide a comprehensive guide about libp2p.
It covers the various modules of libp2p, including supported transport
protocols,  secure channels, stream multiplexers, peer discovery, messaging, NAT traversal,
and more.

This site is an essential resource for developers who want to learn about the
capabilities and features of libp2p, as well as for those who are already familiar
with libp2p and are looking for more advanced guidance. Whether you are just getting
started with P2P networking, or you are an experienced developer looking to
build the next generation of distributed applications, the libp2p documentation
has something for you.

{{< alert icon="" context="">}}
If you have any questions or suggestions as you navigate the documentation,
please don't hesitate to [reach out](../contribute/community.md), or help
improve the documentation by
[contributing to the site](https://github.com/libp2p/docs).
{{< /alert >}}

To get started, let's begin with an overview of libp2p and its key features and
capabilities.

## A modular networking stack

libp2p, (short for "library peer-to-peer")
is a peer-to-peer (P2P) networking framework that enables the development
of P2P applications. It consists of a collection of protocols, specifications, and
libraries that facilitate P2P communication between network participants, known as
"[peers](../fundamentals/peers.md)."

### Peer-to-peer basics

P2P networks are decentralized, meaning participants communicate directly with
one another on a relative "equal footing." No central server or
authority controls the network.
P2P networks do not require a privileged set of "servers" that behave differently
from their "clients," as in the predominant
[client-server model](https://en.wikipedia.org/wiki/Client%E2%80%93server_model).

P2P networks can take many forms, including file-sharing systems like
[BitTorrent](https://www.bittorrent.com/), blockchain networks like [Bitcoin](https://bitcoin.org/en/)
and [Ethereum](https://ethereum.org/en/), and decentralized communication standards like
[Matrix](https://matrix.org/). These systems all have different challenges and tradeoffs,
but they share the goal of improving upon the traditional client-server networking model.

### Background of libp2p

libp2p was initially developed as part of the [InterPlanetary File System (IPFS)](https://ipfs.tech/)
project as its wire protocol but has since phased out into a networking stack that has been adopted
by a wide range of other projects as a networking layer. It provides a set of specifications that
can be adapted to support various protocols, allowing libp2p applications to operate in diverse
runtimes and networking environments.

> Discovering and connecting with other peers is a key challenge in P2P networking. In the past,
> each P2P application had to develop its own solution for this problem, leading to a lack of
> reusable, well-documented P2P protocols. IPFS looked to existing research and networking
> applications for inspiration, but found few code implementations that were usable and adaptable.
> Many of the existing implementations had poor documentation, restrictive licensing, outdated code,
> no point of contact, were closed source, deprecated, lacked specifications, had unfriendly APIs,
> or were tightly coupled with specific use cases and not upgradeable. As a result, developers often
> had to reinvent the wheel each time they needed P2P protocols, rather than being able to reuse
> existing solutions.

{{< alert icon="" context="info">}}
libp2p was designed to address the limitations of traditional P2P networking approaches and these
existing network models, with the goal of enabling the distributed web.
{{< /alert >}}

## Why libp2p?

There are several reasons to consider using libp2p as a networking layer to create a robust P2P application:

- **Modularlity**: libp2p is designed to be modular, allowing developers to mix and match different components
  to meet the needs of their particular application. This makes it easy to customize the networking stack
  to fit the specific requirements of any P2P application.

- **Extensive transport configurability**: libp2p provides a set of specifications that can be adapted to
  support various [transport protocols](../transports/overview.md), allowing libp2p applications to operate
  in various runtime and networking environments. This makes it possible to use libp2p in a variety of
  scenarios, regardless of thanks to wealth of choices with regard to different transport protocols.

- **Versatility**: In addition to supporting a wide range of transports, libp2p offers a range of discovery
  mechanisms, data storage and retrieval patterns, and is also
  [implemented in many programming languages](https://libp2p.io/implementations/), providing
  developers with great flexibility when building P2P applications.

- **Security**: libp2p includes [several security features](../security/security-considerations.md),
  such as peer identity verification using public key cryptography and
  [encrypted communication](../secure-comm/overview.md) between peers using modern cryptographic algorithms.

- **Robustness**: libp2p is a robust and reliable networking protocol that is designed to withstand stress,
  disturbance, and change. Its features and design choices ensure that it is able to function effectively
  and efficiently in a wide range of environments, and it is able to recover quickly from disruptions or
  failures. It also offers protection against network attacks through the use of
  [mitigation techniques](../security/dos-mitigation.md).

- **Resiliency**: P2P networks are often more resilient than traditional client-server networks,
  as there is no single point of failure. libp2p includes features such as
  [peer discovery](../discovery/overview.md) and [content routing](../routing/overview.md) that help
  to ensure that the network remains available and accessible even if some peers are offline or unreachable.

- **Efficiency**: P2P networks can be more efficient in resource utilization, as data is
  distributed across multiple peers rather than stored on a central server. libp2p includes various storage
  and retrieval patterns that allow developers to distribute data efficiently across the network, making it
  possible to store and retrieve data in a cost-effective and scalable way.

- **Piercing NAT Barriers**: libp2p is equipped with capabilities for [NAT traversal](../nat/overview.md),
  which allows P2P communication between peers even when they are behind NAT devices or firewalls. This
  helps to maintain the connectivity of the network and ensure that it remains accessible despite the
  presence of these obstacles.

- **Message Distribution and Dissemination**: One such pattern libp2p uses is
  [publish/subscribe (pubsub)](../pubsub/overview.md), which allows a sender (publisher) to send a message
  to multiple recipients (subscribers) without the publisher having to know who the subscribers are.
  libp2p implements pubsub through the use of protocols like [gossipsub](../pubsub/gossipsub.md), providing
  developers with a flexible and efficient means of exchanging data and messages within their P2P
  applications.

- **Interoperability**: libp2p implementations in different programming languages and libp2p releases across
  versions are designed to be interoperable with one another. This enables applications /from different
  language ecosystems to communicate seamlessly. This helps to promote a healthy, interconnected ecosystem
  of P2P applications.

- **Decentralization**: One of the main advantages of P2P networks is their decentralized nature, allowing
  them to operate without a central authority. libp2p is designed to facilitate decentralized
  communication between peers, making it possible to build P2P applications resistant to censorship and more
  resilient in the face of network disruptions.

## Related projects

libp2p remains an integral component in IPFS and can be easily integrated with other projects in the
IPFS "family". Check their sites for specific information and references:

- [IPFS](https://libp2p.io) is the InterPlanetary File System, which uses libp2p as
  its networking layer.
- [Multiformats](https://multiformats.io) is a variety of *self-describing* data formats.
- [IPLD](https://ipld.io) is a set of tools for describing links between content-addressed
  data, like IPFS files, Git commits, or Ethereum blocks.
- [The Permissive License Stack](https://protocol.ai/blog/announcing-the-permissive-license-stack)
  is a licensing strategy for software development that embraces open-source values.
