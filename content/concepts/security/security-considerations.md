---
title: "Security Considerations"
description: "libp2p makes it simple to establish encrypted, authenticated communication channels between two peers, but there are other important security issues to consider when building robust peer-to-peer systems."
weight: 240
aliases:
   - "/concepts/security-considerations"
   - "/concepts/security/security-considerations"
---

## Security in libp2p

libp2p makes it simple to establish encrypted, authenticated communication
channels between two peers, but there are other important
security issues to consider when building robust peer-to-peer systems.

Many of the issues described here have no known "perfect solution," and the
solutions and mitigation strategies that do exist may come with tradeoffs and
compromises in other areas. As a general-purpose framework, libp2p tries to
provide the tools for application developers to address these problems, rather
than taking arbitrary approaches to security that may not be acceptable to all
systems built with libp2p.

Another aspect to consider is that the fact that a particular type of attack is
theoretically feasible, does not automatically imply that it is practical,
sensible, worthwhile, or efficient to carry out. To evaluate the actual
exploitability of a theoretical attack vector, consider the volume, class, and
cost of resources that the attacker would have to expend for their attack to
reasonably succeed.

## Identity and Trust

Every libp2p peer is uniquely identified by their [Peer ID]({{< relref "/concepts/fundamentals/peers.md#peer-id" >}}), which
is derived from a private cryptographic key. Peer ids and their corresponding
keys allow us to _authenticate_ remote peers, so that we can be sure we're
talking to the correct peer and not an imposter.

However, authentication is generally only half of the "auth" story when it comes
to security. Many systems will also require _authorization_, or the ability to
determine "who is allowed to do what."

libp2p does not provide an authorization framework "out of the box", since the
requirements vary widely across peer-to-peer systems. For example, some networks
may not need authorization at all and can simply accept requests from any peer,
while others may need to explicitly grant fine-grained permissions based on a
hierarchy of roles, the requested resources or services, etc.

To design an authorization system on libp2p, you can rely on the authentication
of peer ids and build an association between peer ids and permissions, with the
Peer ID serving the same function as the "username" in traditional authorization
frameworks, and the peer's private key serving as the "password".
Your [protocol handler]({{< relref "/concepts/fundamentals/protocols.md#handler-functions" >}}) could then
reject requests from untrusted peers.

Of course, it's also possible to build other kinds of authorization systems on
libp2p that are not based on peer ids. For example, you may want a single libp2p
peer to be usable by many human operators, each with a traditional username and
password. This could be accomplished by defining an authorization protocol that
accepts usernames and passwords and responds with a signed token if the
credentials are valid. Protocols that expose sensitive resources could then
require the token before allowing access.

Systems that are designed to be fully decentralized are often "open by default,"
allowing any peer to participate in core functions. However, such systems may
benefit from maintaining some kind "reputation" system to identify faulty or
malicious participants and block or ignore them. For example, each peer could
assign scores to other peers based on how useful and "correct" their behavior is
according to the design of the protocol, taking the score into account when
deciding whether to handle a given request.

A fully decentralized reputation management system, in which peers collaborate
to evaluate each other, is outside the scope of libp2p. However, many of
libp2p's core developers and community members are excited by research and
development in this area, and would welcome your thoughts [on the libp2p
forums](https://discuss.libp2p.io).

## Cooperative Systems with Abuse Potential

Some of libp2p's most useful built-in protocols are cooperative, leveraging
other peers in the network to perform tasks that benefit everyone. For example,
data stored on the Kad-DHT is replicated across the set of peers that are
"closest" to the data's associated key, whether those peers have any particular
interest in the data or not.

Cooperative systems are inherently susceptible to abuse by bad actors, and
although we are researching ways to limit the impact of such attacks, they are
possible in libp2p today.

### Kad-DHT

The Kad-DHT protocol is a [distributed hash table][glossary-dht] that provides a
shared key/value storage system for all participants. In addition to key/value
lookups, the DHT is the default implementation of libp2p's peer
routing and content routing interfaces, and thus serves an important role in
discovering other peers and services on the network.

#### Sybil Attacks

DHTs, and p2p systems in general are vulnerable to a class of attacks called
[Sybil attacks][wikipedia-sybil], in which one operator spins up a large number
of DHT peers with distinct identities (generally called "Sybils") to flood the
network and gain an advantageous position.

A DHT query may need to be routed through several peers before completion, each
of which has the opportunity to modify query responses, either by returning
incorrect data or by not returning data at all. By controlling a large number of
Sybil nodes (in proportion to the size of the network), a bad actor increases
the probability of being in the lookup path for queries. To target a specific
key, they could improve their chances of being in the lookup path further by
generating IDs that are "close" to the target key according the DHT's distance
metric.

Applications can guard against modification of data by signing values that are
stored in the DHT, or by using content addressing, where a cryptographic hash of
the stored value is used as the key, as in [IPFS](https://ipfs.io). These
strategies allow you to detect if the data has been tampered with, however, they
cannot prevent tampering from occurring in the first place, nor can they prevent
malicious nodes from simply pretending the data doesn't exist and omitting it
entirely.

Very similar to Sybil attacks, an Eclipse attack also uses a large number of
controlled nodes, but with a slightly different goal. Instead of modifying data
in flight, an Eclipse attack is targeted at a specific peer with the goal of
distorting their "view" of the network, often to prevent them from reaching any
legitimate peers (thus "eclipsing" the real network). This kind of attack is
quite resource-intensive to perform, requiring a large number of malicious nodes
to be fully effective.

Eclipse and Sybil attacks are difficult to defend against because it is possible
to generate an unlimited number of valid peer ids. Many practical mitigations
for Sybil attacks rely on making ID generation "expensive" somehow, for example,
by requiring a proof-of-work with real-world associated costs, or by "minting"
and signingIDs from a central trusted authority. These mitigations are outside
the scope of libp2p, but could be adopted at the application layer to make Sybil
attacks more difficult and/or prohibitively expensive.

We are currently planning to implement a strategy of querying multiple disjoint
lookup paths (paths that do not share any common intermediary peers) in
parallel, inspired by the [S/Kademlia paper][paper-s-kademlia]. This will
greatly increase the chances of finding "honest" nodes, even if some nodes are
returning dishonest routing information.

### Publish / Subscribe

libp2p's [publish/subscribe protocol]({{< relref "/concepts/pubsub/overview.md" >}}) allows a peer
to broadcast messages to other peers within a given "topic."

By default, the `gossipsub` implementation will sign all messages with the
author's private key, and require a valid signature before accepting or
propagating a message further. This prevents messages from being altered in
flight, and allows recipients to authenticate the sender.

However, as a cooperative protocol, it may be possible for peers to interfere
with the message routing algorithm in a way that disrupts the flow of messages
through the network.

We are actively researching ways to mitigate the impact of malicious nodes on
`gossipsub`'s routing algorithm, with a particular focus on preventing Sybil
attacks. We expect this to lead to a more robust and attack-resistant pubsub
protocol, but it is unlikely to prevent all classes of possible attack by
determined bad actors.

[glossary-dht]: {{< relref "/concepts/appendix/glossary#dht" >}}
[wikipedia-sybil]: https://en.wikipedia.org/wiki/Sybil_attack
[paper-s-kademlia]: https://telematics.tm.kit.edu/publications/Files/267/SKademlia_2007.pdf
