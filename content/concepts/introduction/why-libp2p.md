---
title: "Why libp2p"
description: libp2p is a modular system of protocols, specifications, and libraries that enable the development of peer-to-peer network applications.
weight: 3
---

There are several reasons to consider using libp2p as a networking layer to create a robust P2P application:

- **Modularlity**: libp2p is designed to be modular, allowing developers to mix and match different components
  to meet the needs of their particular application. This makes it easy to customize the networking stack
  to fit the specific requirements of any P2P application.

- **Extensive transport configurability**: libp2p provides a set of specifications that can be adapted to
  support various [transport protocols](../transports/overview.md), allowing libp2p applications to operate
  in various runtime and networking environments as the wealth of transport protocol choices makes it possible
  to use libp2p in a variety of scenarios.

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
  versions are designed to be interoperable with one another. This enables applications from different
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
