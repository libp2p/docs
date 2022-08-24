---
title: "What is libp2p?"
weight: 2
---

Moving from a location-addressed system to a peer-to-peer, content-addressed system presents many challenges. The internet as it is, with firewalls and NATs, was designed to [securely] provide data. There are also trust assumptions, as clients must trust the central servers they connect to and the data they provide, despite these servers verifying their identity using certificate authorities.

libp2p is a modular system of *protocols*, *specifications* and *libraries* that enable the development of peer-to-peer network applications. Because of the way libp2p is architected, a lot of the needs and considerations that the web2 network was built on no longer apply.

See the [Glossary][glossary] to understand the basic building blocks for understanding libp2p.
<!--more-->

## Peer-to-peer basics

 Let's start with what a _peer-to-peer network application_ is:

_A [peer-to-peer network][definition_p2p] is one in which the participants (referred to as [peers][definition_peer]) communicate directly with one another on a relative "equal footing". This does not mean that all peers are identical; some may have different roles in the overall network. However, one of the defining characteristics of a peer-to-peer network is that the network does not require a privileged set of "servers" which behave completely differently from their "clients", as is the case in the predominant [client / server model][definition_client_server]._

Because the definition of peer-to-peer networking is quite broad, many different kinds of systems have been built that all fall under the umbrella of "peer-to-peer". The most culturally prominent examples are likely the file sharing networks like bittorrent, and, more recently, the proliferation of blockchain networks that communicate in a peer-to-peer fashion.

## What problems can libp2p solve?

While peer-to-peer networks have many advantages over the client-server model, there are unique challenges that require careful thought and practice to overcome.

libp2p lets you preserve your network identity, overcome network censorship, and communicate over different transfer protocols.

In our process of overcoming these challenges while building [IPFS](https://ipfs.io), we took care to build our solutions in a modular, composable way, into what is now libp2p. Although libp2p grew out of IPFS, it does not require or depend on IPFS, and today [many projects][built_with_libp2p] use libp2p as their network transport layer. Together we can leverage our collective experience and solve these foundational problems in a way that benefits an entire ecosystem of developers and a world of users.



Here we'll briefly outline the main problem areas that are addressed by libp2p. This is an ever-growing space, so don't be surprised if things change over time. If you notice something missing or have other ideas for improving this documentation, please [reach out to let us know][help_improve_docs].

<!-- TODO: as concept articles are written expanding on the below, add links -->

### Transport

At the foundation of libp2p is the transport layer, which is responsible for the actual transmission and receipt of data from one peer to another. There are many ways to send data across networks in use today, with more in development and still more yet to be designed. libp2p provides a simple [interface](https://github.com/libp2p/js-libp2p-interfaces) that can be adapted to support existing and future protocols, allowing libp2p applications to operate in many different runtime and networking environments.

### Identity

In a world with billions of networked devices, knowing who you're talking to is key to secure and reliable communication. libp2p uses [public key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography) as the basis of peer identity, which serves two complementary purposes.  First, it gives each peer a globally unique "name", in the form of a [PeerId][definition_peerid]. Second, the `PeerId` allows anyone to retrieve the public key for the identified peer, which enables secure communication between peers.

### Security

It's essential that we are able to send and receive data between peers *securely*, meaning that we can trust the [identity](#identity) of the peer we're communicating with and that no third-party can read our conversation or alter it in-flight.

libp2p supports "upgrading" a connection provided by a [transport](#transport) into a securely encrypted channel. The process is flexible, and can support multiple methods of encrypting communication. libp2p currently supports [TLS 1.3](https://www.ietf.org/blog/tls13/) and [Noise](https://noiseprotocol.org/), though not every language implementation of libp2p supports both of these. (Older versions of libp2p may support a [deprecated](https://blog.ipfs.io/2020-08-07-deprecating-secio/) protocol called SECIO; all projects should switch to TLS 1.3 or Noise instead.)

### Peer Routing

When you want to send a message to another peer, you need two key pieces of information: their [PeerId][definition_peerid], and a way to locate them on the network to open a connection.

There are many cases where we only have the `PeerId` for the peer we want to contact, and we need a way to discover their network address. Peer routing is the process of discovering peer addresses by leveraging the knowledge of other peers.

In a peer routing system, a peer can either give us the address we need if they have it, or else send our inquiry to another peer who's more likely to have the answer. As we contact more and more peers, we not only increase our chances of finding the peer we're looking for, we build a more complete view of the network in our own routing tables, which enables us to answer routing queries from others.

The current stable implementation of peer routing in libp2p uses a [distributed hash table][definition_dht] to iteratively route requests closer to the desired `PeerId` using the [Kademlia][wiki_kademlia] routing algorithm.


### Content Discovery

In some systems, we care less about who we're speaking with than we do about what they can offer us. For example, we may want some specific piece of data, but we don't care who we get it from since we're able to verify its integrity.

libp2p provides a [content routing interface][interface_content_routing] for this purpose, with the primary stable implementation using the same [Kademlia][wiki_kademlia]-based DHT as used in peer routing.

### Messaging / PubSub

Sending messages to other peers is at the heart of most peer-to-peer systems, and pubsub (short for publish / subscribe) is a very useful pattern for sending a message to groups of interested receivers.

libp2p defines a [pubsub interface][interface_pubsub] for sending messages to all peers subscribed to a given "topic". The interface currently has two stable implementations; `floodsub` uses a very simple but inefficient  "network flooding" strategy, and [gossipsub](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub) defines an extensible gossip protocol.  There is also active development in progress on [episub](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/episub.md), an extended `gossipsub` that is optimized for single source multicast and scenarios with a few fixed sources broadcasting to a large number of clients in a topic.

[glossary]: {{< ref "/reference/glossary.md" >}}
[definition_dht]: {{< ref "/reference/glossary.md#dht" >}}
[definition_p2p]: {{< ref "/reference/glossary.md#p2p" >}}
[definition_peer]: {{< ref "/reference/glossary.md#peer" >}}
[definition_peerid]: {{< ref "/reference/glossary.md#peerid" >}}
[definition_secio]: {{< ref "/reference/glossary.md#secio" >}}
[definition_muiltiaddress]: {{< ref "/reference/glossary.md#multiaddr" >}}
[definition_client_server]: {{< ref "/reference/glossary.md#client-server" >}}

[interface_content_routing]: https://github.com/libp2p/js-libp2p-interfaces/tree/master/packages/interfaces/src/content-routing
[interface_pubsub]: https://github.com/libp2p/specs/tree/master/pubsub


[built_with_libp2p]: https://discuss.libp2p.io/c/ecosystem-community
[help_improve_docs]: https://github.com/libp2p/docs/issues

[wiki_kademlia]: https://en.wikipedia.org/wiki/Kademlia
