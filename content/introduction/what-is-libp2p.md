---
title: "What is libp2p?"
menu:
    introduction:
      weight: 1
---

Good question! The one-liner pitch is that libp2p is a modular system of *protocols*, *specifications* and *libraries* that enable the development of peer-to-peer network applications.

<!--more-->

## Peer-to-peer basics

There's a lot to unpack in that one-liner! Let's start with the last bit, "peer-to-peer network applications." You may be here because you're knee-deep in development of a peer-to-peer system and are looking for help. Likewise, you may be here because you're just exploring the world of peer-to-peer networking for the first time. Either way, we ought to spend a minute defining our terms upfront, so we can have some [shared vocabulary][glossary] to build on.

A [peer-to-peer network][definition_p2p] is one in which the participants (referred to as [peers][definition_peer] or nodes) communicate with one another directly, on more or less "equal footing". This does not necessarily mean that all peers are identical; some may have different roles in the overall network. However, one of the defining characteristics of a peer-to-peer network is that they do not require a priviliged set of "servers" which behave completely differently from their "clients", as is the case in the the predominant [client / server model][definition_client_server].

Because the definition of peer-to-peer networking is quite broad, many different kinds of systems have been built that all fall under the umbrella of "peer-to-peer". The most culturally prominent examples are likely the file sharing networks like bittorrent, and, more recently, the proliferation of blockchain networks that communicate in a peer-to-peer fashion.

## What problems can libp2p solve?

While peer-to-peer networks have many advantages over the client / server model, there are also challenges that are unique and require careful thought and practice to overcome. In our process of overcoming these challenges while building [IPFS](https://ipfs.io), we took care to build our solutions in a modular, composable way, into what is now libp2p. Although libp2p grew out of IPFS, it does not require or depend on IPFS, and today [many projects][built_with_libp2p] use libp2p as their network transport layer. Together we can leverage our collective experience and solve these foundational problems in a way that benefits an entire ecosystem of developers and a world of users.



Here I'll try to briefly outline the main problem areas that are addressed by libp2p today (early 2019). This is an ever-growing space, so don't be surprised if things change over time. We'll do our best to keep this section up-to-date as things progress, but if you notice something missing or have other ideas for improving this documentation, please [reach out to let us know][help_improve_docs].

<!-- TODO: as concept articles are written expanding on the below, add links -->

### Transport

At the foundation of libp2p is the transport layer, which is responsible for the actual transmission and receipt of data from one peer to another. There are many ways to send data across networks in use today, with more in development and still more yet to be designed. libp2p provides a simple [interface](https://github.com/libp2p/interface-transport) that can be adapted to support existing and future protocols, allowing libp2p applications to operate in many different runtime and networking environments.

### Identity

In a world with billions of networked devices, knowing who you're talking to is key to secure and reliable communication. libp2p uses [public key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography) as the basis of peer identity, which serves two complementary purposes.  First, it gives each peer a globally unique "name", in the form of a [PeerId][definition_peerid]. Second, the `PeerId` allows anyone to retrieve the public key for the identified peer, which enables secure communication between peers.

### Security

TODO:

- explain how libp2p addresses secure IO
- add "work in progress" disclaimer & disclosure info

### Routing

TODO:

- explain peer-routing basics, link to interface definition
- describe motivation for relay, link to circuit relay spec

### Discovery

TODO:

- explain how libp2p implements peer / content discovery via the DHT

[glossary]: {{< ref "/reference/glossary.md" >}}
[definition_p2p]: {{< ref "/reference/glossary.md#peer-to-peer-p2p" >}}
[definition_peer]: {{< ref "/reference/glossary.md#peer" >}}
[definition_peerid]: {{< ref "/reference/glossary.md#peerid" >}}
[definition_client_server]: {{< ref "/reference/glossary.md#client-server" >}}

[built_with_libp2p]: {{< ref "/community/applications/built_with_libp2p.md" >}}
[help_improve_docs]: {{< ref "/community/contribute/how_to_help.md" >}}
