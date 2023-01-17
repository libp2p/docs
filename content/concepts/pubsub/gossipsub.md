---
title: "Gossipsub"
description: "GossipSub is a gossip-based Publish/Subscribe protocol that allows for efficient message dissemination and topic-based subscription."
weight: 232
---

## Overview

GossipSub is a gossip-based Publish/Subscribe protocol in libp2p. It allows for efficient
message dissemination and topic-based subscription. The protocol is designed to be
scalable, resilient to network partitions, and resistant to malicious actors.

**GossipSub v1.1** is the latest version of the protocol, and it introduces several new features
and improvements over v1.0. These include:

- **Explicit peering agreements**: a mechanism for node operators to establish and maintain
  connections with a predefined set of peers, regardless of the peer scoring system and other
  defensive measures.
- **PRUNE backoff and peer exchange**: a mechanism for bootstrapping the network and mitigating
  oversubscription by providing a set of alternative peers for a pruned peer to connect to.
- **Improved peer scoring**: a more sophisticated scoring function that considers
  various metrics such as time in mesh, message delivery rate, and invalid messages.
- **Extended validators**: a mechanism for application-specific message validation, allowing for
  more fine-grained control over message delivery and forwarding.

## Gossip Protocol

GossipSub uses "gossiping" for message dissemination and topic-based subscription.
Each peer maintains a set of connections to other peers in the network, called the mesh.
Peers exchange and control messages to keep their mesh state up to date.

### Message Forwarding

When a peer receives a message for a topic it is subscribed to, it forwards the message to
all its mesh peers. The protocol uses a flooding algorithm to ensure that all messages are
disseminated throughout the network promptly. However, to prevent overloading the
network, a peer may choose only to forward a subset of messages to its mesh peers using a
configurable parameter called the GossipFactor.

### Topic-based Subscription

A peer can subscribe to one or more topics by sending a SUBSCRIBE control message to its mesh
peers. The message includes a list of topics the peer is interested in. When a peer receives
a SUBSCRIBE message, it adds the peer to its mesh for the specified topics.

### Peer Scoring

GossipSub uses a peer scoring system to decide which peers to keep in the mesh and which to prune.
The scoring system considers parameters such as time in mesh, message delivery rate,
and invalid messages. The scoring function is configurable by the application and can be tuned to
the specific needs of the application.

## Peering Agreements

GossipSub v1.1 introduces explicit peering agreements, a mechanism for node operators to establish
and maintain connections with a predefined set of peers, regardless of the peer scoring system and
other defensive measures.

With explicit peering, the application can specify a list of peers to remain connected and
forward messages to each other unconditionally. The router must establish and maintain a connection
with every explicit peer. The connections are initially established when the router boots and are
periodically checked for connectivity and reconnected if the connectivity is lost.

Explicit peers exist outside the mesh: every new valid incoming message is forwarded to the direct
peers, and incoming RPCs are always accepted. It is an error to GRAFT on an explicit peer, and such
an attempt should be logged and rejected with a PRUNE.

## PRUNE Backoff and Peer Exchange

Gossipsub v1.1 introduces PRUNE backoff and peer exchange, a mechanism for bootstrapping the network
and mitigating oversubscription. When a peer is pruned from the mesh because of oversubscription,
instead of simply telling the pruned peer to go away, the pruning peer may provide a set of other peers
whom the pruned peer can connect to reform its mesh. This allows for more efficient bootstrapping of
the network, as the pruned peer can quickly find new peers to form its mesh without relying on an external
peer discovery service.

When a peer tries to regraft too early, the pruning peer may apply a behavioral penalty for the action and
penalize the peer through P₇ (as described in the Peer Scoring section). In addition, both the pruned and
the pruning peer add a backoff period from each other, within which they will not try to regraft.
This helps prevent constant regrafting attempts and allows for a more stable network.


When unsubscribing from a topic, the backoff period should be finished before subscribing to the topic
again. Otherwise, a healthy mesh will be difficult to reach. A shorter backoff period can be used in case of
an unsubscribe event, allowing for faster resubscribing.

## The Score Function

The score function is a way to evaluate the quality of a peer's participation in the mesh for each topic.
The score is a weighted mix of several parameters, some of them specific to a topic and others that apply
globally. The score function is used to determine which peers to prune, which peers to retain when the mesh
is oversubscribed, and which peers to accept when a new peer wants to join the mesh.

## Topic Parameter Calculation and Decay

Topic parameters are used by the score function and are maintained by the router. These parameters are
updated whenever an event of interest occurs, such as a message being forwarded or a peer being pruned.
To prevent these parameters from continuously increasing, they are subject to decay. The application
configures the decay interval with shorter intervals resulting in a faster decay of the parameters.

## Guidelines for Tuning the Scoring Function

The scoring function has several parameters that can be configured to suit the needs of an application.
However, determining the optimal configuration for these parameters can be challenging. To aid in this
process, the gossipsub v1.1 specification provides guidelines for tuning the scoring function based
on simulation results. These guidelines will help developers understand how to adjust their specific
use case parameters.

## Extended Validators

Gossipsub v1.1 introduces the concept of extended validators, which allows the application to specify a more
fine-grained message validation process. Extended validators provide more control over how messages are handled,
allowing the application to ignore particular messages without triggering the penalty for invalid messages.
