---
title: "What is libp2p"
description: libp2p is a modular system of protocols, specifications, and libraries that enable the development of peer-to-peer network applications.
weight: 2
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
