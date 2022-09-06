---
title: "Introduction"
weight: 1
pre: '<i class="fas fa-fw fa-comments"></i> '
---

Welcome to the official libp2p documentation hub!

Whether you’re just starting to dive into peer-to-peer concepts and 
solutions, learning how to build peer-to-peer systems with libp2p, or 
are looking for detailed reference information, this is the place to 
start.

## What is libp2p?

libp2p is a modular system of *protocols*, *specifications* and *libraries* 
that enable the development of peer-to-peer network applications. 

**The networking protocol of web3**

Because of libp2p's peer-to-peer and distributed architecture, most of the 
needs and considerations that the current web was built on no longer apply.
The internet, such as it is, with firewalls and NATs, was designed to [securely] 
provide data by relying on trust assumptions. There are many distributed
peer-to-peer network models with different challenges and tradeoffs that try
to improve on the way we network. Libp2p aims to be a modular, general-purpose 
toolkit for any peer-to-peer application.

## Peer-to-peer basics

Let's start with what a peer-to-peer network application is:

A [peer-to-peer network][definition_p2p] is one in which the participants 
(referred to as [peers][definition_peer]) communicate directly with one another 
on a relative "equal footing". This does not mean that all peers are identical 
as some may have different roles in the overall network. However, one of the 
defining characteristics of a peer-to-peer network is that the network does not 
require a privileged set of "servers" which behave completely differently from 
their "clients", as is the case in the predominant 
[client / server model][definition_client_server].

Because the definition of peer-to-peer networking is quite broad, many different 
kinds of systems have been built that all fall under the umbrella of "peer-to-peer". 
The most culturally prominent examples are likely file-sharing networks like BitTorrent, 
and, more recently, the proliferation of blockchain networks that communicate in a 
peer-to-peer fashion.

### What problems can libp2p solve?

While peer-to-peer networks have many advantages over the client-server model, 
there are unique challenges that require careful thought and practice to overcome.

libp2p lets all users preserve their network identity, overcome network censorship, 
and communicate over different transport protocols.

In overcoming these challenges while building [IPFS](https://ipfs.io),
we took care to build our solutions in a modular, composable way into what is 
now libp2p. Although libp2p grew out of IPFS, it is not dependent on IPFS, and 
today, [many projects][built_with_libp2p] use libp2p as their networking layer. 

Together, we can leverage our collective experience and solve these foundational 
problems in a way that benefits an entire ecosystem of developers and a world of users.

Here, we'll briefly outline the main problem areas that libp2p attempts to address. 
This is an ever-growing space, so don't be surprised if things change over time. 
If you notice something missing or have other ideas for improving this documentation, 
please [reach out to let us know][help_improve_docs].

### Data transmission

The transport layer is at the foundation of libp2p, which is responsible for 
the actual transmission and receipt of data from one peer to another. There are many 
ways to send data across networks in use today, with more in development and still more yet 
to be designed. 

libp2p provides a list of specifications [specifcations](https://github.com/libp2p/specs) 
that can be adapted to support existing and future protocols, allowing libp2p applications 
to operate in many different runtime and networking environments.

### Peer identity

Knowing who you're talking to is key to secure and reliable communication in a world 
with billions of networked devices. libp2p uses 
[public key cryptography](https://en.wikipedia.org/wiki/Public-key_cryptography) 
as the basis of peer identity, which serves two complementary purposes.

1. It gives each peer a globally unique "name", in the form of a 
   [PeerId][definition_peerid]. 
2. The `PeerId` allows anyone to retrieve the public key for the identified 
   peer, which enables secure communication between peers.

### Secure communication

There needs to be a method to securely send and receive data between peers, 
where peers are able to trust the [identity](#peer-identity) of the peer they're
communicating with while ensuring that no external entity can access or tamper with
the communication.

All libp2p connections are encrypted and authenticated. Some [transport protocol](#transport) 
protocols are encrypted at the transport layer (e.g. QUIC). For other protocols, libp2p runs 
a cryptographic handshake on top of an unencrypted connection (e.g. TCP).

For secure communication channels, libp2p currently supports 
[TLS 1.3](https://www.ietf.org/blog/tls13/) and [Noise](https://noiseprotocol.org/), 
though not every language implementation of libp2p supports both of these. 

> (Older versions of libp2p may support a 
> [deprecated](https://blog.ipfs.io/2020-08-07-deprecating-secio/) protocol called SECIO; 
> all projects should switch to TLS 1.3 or Noise instead.)

### Peer routing

When you want to send a message to another peer, you need two key pieces 
of information: their [PeerId][definition_peerid], and a way to locate them 
on the network to open a connection.

There are many cases where we only have the `PeerId` for the peer we want to 
contact, and we need a way to discover their network address. Peer routing is 
the process of discovering peer addresses by leveraging the knowledge of other 
peers.

In a peer routing system, a peer can either give us the address we need if they 
have it, or else send our inquiry to another peer who's more likely to have the 
answer. As we contact more and more peers, we not only increase our chances of 
finding the peer we're looking for, we build a more complete view of the network 
in our own routing tables, which enables us to answer routing queries from others.

The current stable implementation of peer routing in libp2p uses a 
[distributed hash table][definition_dht] to iteratively route requests closer 
to the desired `PeerId` using the [Kademlia][wiki_kademlia] routing algorithm.

### Content discovery

In some systems, we care less about who we're speaking with than what they can offer us. 
For example, we may want some specific piece of data, but we don't care who we get it from 
since we can verify its integrity.

libp2p provides a [content routing specification][spec_content_routing] for this 
purpose, with the primary stable implementation using the same 
[Kademlia][wiki_kademlia]-based DHT as used in peer routing.

### Peer messaging

Sending messages to other peers is at the heart of most peer-to-peer systems, 
and pubsub (short for publish/subscribe) is an instrumental pattern for sending 
a message to groups of interested receivers.

libp2p defines a [pubsub specification][spec_pubsub] for sending messages to all 
peers subscribed to a given "topic". The specification currently has two stable 
implementations; `floodsub` uses a very simple but inefficient  "network flooding" 
strategy, and [gossipsub](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub) 
defines an extensible gossip protocol.  There is also active development in progress on 
[episub](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/episub.md), an 
extended `gossipsub` that is optimized for single source multicast and scenarios with a 
few fixed sources broadcasting to a large number of clients in a topic.

Head over to [What is libp2p?](/introduction/what-is-libp2p/) for an introduction to 
the basics of libp2p and an overview of the problems it addresses.

## Related projects

libp2p began as part of the [IPFS](https://ipfs.io) project and is still an 
essential component of IPFS. As such, libp2p composes well with the abstractions 
and tools provided by other projects in the IPFS "family". Check their sites for 
specific information and references:

- [IPFS](https://libp2p.io) is the InterPlanetary File System, which uses libp2p as 
  its networking layer.
- [Multiformats](https://multiformats.io) is a variety of *self-describing* data formats.
- [IPLD](https://ipld.io) is a set of tools for describing links between content-addressed 
  data, like IPFS files, Git commits, or Ethereum blocks.
- [The Permissive License Stack](https://protocol.ai/blog/announcing-the-permissive-license-stack) 
  is a licensing strategy for software development that embraces open-source values.

[glossary]: {{< ref "/reference/glossary.md" >}}
[definition_dht]: {{< ref "/reference/glossary.md#dht" >}}
[definition_p2p]: {{< ref "/reference/glossary.md#p2p" >}}
[definition_peer]: {{< ref "/reference/glossary.md#peer" >}}
[definition_peerid]: {{< ref "/reference/glossary.md#peerid" >}}
[definition_secio]: {{< ref "/reference/glossary.md#secio" >}}
[definition_muiltiaddress]: {{< ref "/reference/glossary.md#multiaddr" >}}
[definition_client_server]: {{< ref "/reference/glossary.md#client-server" >}}

[spec_content_routing]: https://github.com/libp2p/specs/blob/master/kad-dht/README.md
[spec_pubsub]: https://github.com/libp2p/specs/blob/master/pubsub/README.md
[built_with_libp2p]: https://discuss.libp2p.io/c/ecosystem-community
[help_improve_docs]: https://github.com/libp2p/docs/issues
[wiki_kademlia]: https://en.wikipedia.org/wiki/Kademlia
