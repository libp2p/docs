---
title: "devp2p"
description: A brief comparison of devp2p and libp2p.
weight: 280
---

## About devp2p

[devp2p](https://github.com/ethereum/devp2p) is a dedicated networking stack and set of networking protocols, not unlike libp2p in some manners.
It is used in [Ethereum](https://ethereum.org/en/), primarily in [execution clients](https://ethereum.org/en/developers/docs/nodes-and-clients/#execution-clients).

In the early days of Ethereum and libp2p, some commonly asked questions were: "Does Ethereum use libp2p?" or "Why doesn't Ethereum use libp2p?"

Until recently, the answer to the first question was no. The reason for that was the answer to the second question: libp2p didn't exist when Ethereum was first developed, so it never got a chance to be evaluated and/or adopted.

[Felix Lange](https://github.com/fjl), developer of [go-ethereum (Geth)](https://geth.ethereum.org/) at the Ethereum Foundation, reflected on this in an article titled ["Ethereum ♥ libp2p"](https://twurst.com/articles/eth-loves-libp2p.html):

> *"libp2p didn't exist when we started building the peer-to-peer networking stack for Ethereum. There were discussions about building something together very early on, but in the end we were more set on shipping a working system than to discussing how to make the most flexible and generic framework."*

Thus, prior to the Merge, Ethereum solely used devp2p.
And though there were talks between the Ethereum and IPFS/libp2p communities to have one solution instead of two, the timing didn't work, and Ethereum shipped with devp2p as its solution.

## Comparing devp2p and libp2p

The [devp2p repo](https://github.com/ethereum/devp2p#relationship-with-libp2p) provides an apt contrast of each project's intended scope and design:

*"devp2p is an integrated system definition that wants to serve Ethereum's needs well (although it may be a good fit for other applications, too) while libp2p is a collection of programming library parts serving no single application in particular.
That said, both projects are very similar in spirit and devp2p is slowly adopting parts of libp2p as they mature."*

devp2p was explicitly designed to fulfill requirements for Ethereum. In particular, devp2p specifies:

- [Ethereum Node Records] (ENR): a format to share and learn an Ethereum node's IP addresses & ports and its purpose on the network.
- [Node Discovery Protocol v5] (discv5): a protocol for the Node Discovery system. The system acts like a database of all live nodes and is used for bootstrapping into & finding peers on the network (using ENRs).
- [RLPx protocol] (RLPx): a TCP-based transport protocol that has a notion of ["capability messages"](https://github.com/ethereum/devp2p/blob/master/rlpx.md#capability-messaging) used during connection establishment.
    RLPx is used for authentication, stream multiplexing, and more.

Each component is a requirement of devp2p.
Together these specifications define devp2p as an ***integrated** networking **system*** for Ethereum.

By contrast, libp2p is a ***modular** networking **framework***, meaning that many different sorts of libp2p networking stacks can be composed by assembling a wide variety general-purpose modules.

libp2p provides the necessary modules to create a distributed peer-to-peer network, including modules for transport protocols, stream multiplexers, secure channels and authentication, peer discovery, messaging, NAT traversal, and more.
They are specified in the [libp2p specification repo](https://github.com/libp2p/specs/).

Modularity provides libp2p with a few advantages:

- Flexibility
  - An application can pick and choose a combination of modules and assemble a networking stack suited to its needs.
- Extensibility
  - New modules can be added seamlessly thanks to well-defined interfaces and specifications
- Reach
  - Thanks to a wealth of plug-and-play options, new applications can be built with libp2p.
    Additionally, libp2p enables connectivity to the browser thanks to modular transport protocols.
    *To learn more about browser connectivity, visit: [connectivity.libp2p.io](https://connectivity.libp2p.io/)*

A great similarity that both devp2p and libp2p share is language interoperability.
For example, go-libp2p and rust-libp2p are written in different programming languages, but are still compatible and interoperabile with each other. The same holds true for devp2p.

[Ethereum Node Records]: https://github.com/ethereum/devp2p/blob/master/enr.md
[Node Discovery Protocol v4]: https://github.com/ethereum/devp2p/blob/master/discv4.md
[Node Discovery Protocol v5]: https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md
[RLPx protocol]: https://github.com/ethereum/devp2p/blob/master/rlpx.md
