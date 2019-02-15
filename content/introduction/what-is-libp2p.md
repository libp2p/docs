---
title: "What is libp2p?"
menu:
    introduction:
      weight: 1
---

Good question! The one-liner pitch is that libp2p is a modular system of *protocols*, *specifications* and *libraries* that enable the development of peer-to-peer network applications.

<!--more-->

## Peer-to-peer basics

There's a lot to unpack in that one-liner! Let's start with the last bit, "peer-to-peer network applications." You may be here because you're knee-deep in development of a peer-to-peer system and are looking for help.  Likewise, you may be here because you're just exploring the world of peer-to-peer networking for the first time.  Either way, we ought to spend a minute defining our terms upfront, so we can have some shared vocabulary to build on.



A [peer-to-peer network][definition_p2p] is one in which the participants (referred to as [peers][definition_peer] or nodes) communicate with one another directly, on more or less "equal footing". This does not necessarily mean that all peers are identical; some may have different roles in the overall network.  However, one of the defining characteristics of a peer-to-peer network is that they do not require a priviliged set of "servers" which behave completely differently from their "clients", as is the case in the the predominant [client / server model][definition_client_server].



Because the definition of peer-to-peer networking is quite broad, many different kinds of systems have been built that all fall under the umbrella of "peer-to-peer".  The most culturally prominent examples are likely the file sharing networks like bittorrent, and, more recently, the proliferation of blockchain networks that communicate in a peer-to-peer fashion.

## What problems can libp2p solve?

While peer-to-peer networks have many advantages over the client / server model, there are also challenges that are unique and require careful thought and practice to overcome.  In our process of overcoming these challenges while building [IPFS](https://ipfs.io), we took care to build our solutions in a modular, composable way, into what is now libp2p. Although libp2p grew out of IPFS, it does not require or depend on IPFS, and today [many projects][built_with_libp2p] use libp2p as their network transport layer. Together we can leverage our collective experience and solve these foundational problems in a way that benefits an entire ecosystem of developers and a world of users.



Here I'll try to briefly outline the main problem areas that are addressed by libp2p today (early 2019). This is an ever-growing space, so don't be surprised if things change over time.  We'll do our best to keep this section up-to-date as things progress, but if you notice something missing or have other ideas for improving this documentation, please [reach out to let us know][help_improve_docs].

<!-- TODO: fill these in with summary of problem, link to concept articles (TBD) -->

### Identity

> who are you, again?

### Transport

> Tcp, websockets, carrier pigeon, we've got you covered!

### Security

> Caveat emptor!

### Routing

> I know a guy who knows a guy...

#### Circuit relay & packet switching

> Marge, will you please ask Lisa to pass the syrup?

### Discovery

> It's always in the last place you look...



[definition_p2p]: {{< ref "/reference/glossary.md#peer-to-peer-p2p" >}}
[definition_peer]: {{< ref "/reference/glossary.md#peer" >}}
[definition_client_server]: {{< ref "/reference/glossary.md#client-server" >}}

[built_with_libp2p]: {{< ref "/community/applications/built_with_libp2p.md" >}}
[help_improve_docs]: {{< ref "/community/contribute/how_to_help.md" >}}
