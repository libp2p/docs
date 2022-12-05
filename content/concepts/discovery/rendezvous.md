---
title : "Rendezvous"
description: "The rendezvous protocol can facilitate the routing and discovery of nodes in a peer-to-peer network using a common location."
weight: 223
---

## What is Rendezvous?

A rendezvous protocol is a routing protocol that enables nodes and resources
in a peer-to-peer network to discover each other. Rendezvous is used
as a common location (point) to route between two routes.

Rendezvous points are typically nodes that are well-connected and stable in
a network and can handle large amounts of traffic and data. They
serve as a hub for nodes to discover and connect with the primary
responsibility of relaying packets between other nodes.

## Rendezvous in libp2p

{{< alert icon="💡" context="info" text="The current rendezvous implementation replaces the initial ws-star-rendezvous implementation with rendezvous daemons and a fleet of p2p-circuit relays." />}}

The libp2p rendezvous protocol can be used for different use cases. It is used
during bootstrap to discover circuit relays that provide connectivity for browser
nodes. Generally, a peer can use known rendezvous points to find peers that provide
critical network services. Rendezvous is also used throughout the lifetime of
an application for real-time peer discovery by registering and polling rendezvous points
in a decentralized manner. In an application-specific setting, rendezvous points are
used to progressively discover peers that can answer specific queries or host shards of
content.

The libp2p rendezvous protocol allows peers to connect to a rendezvous point and register
their presence by sending a `REGISTER` message containing their serialized peer record in
one or more namespaces. Any node implementing the rendezvous protocol can act as a rendezvous
point, and any peer can connect to a rendezvous point. However, only peers initiating a
registration can register themselves at a rendezvous point.

By registering with a rendezvous point, peers allow for their discovery by other peers who
query the rendezvous point. The query may:

- provide namespace(s), such as `test-app`;
- optionally provide a maximum number of peers to return;
- can include a cookie that is obtained from the response to a previous query which would only
  contain registrations that weren't part of the previous response.
  > This simplifies real-time discovery as it reduces the overhead of queried peers and allows for
  > the pagination of query responses.

There is a default peer registration lifetime of 2 hours. Peers can optionally specify the
lifetime using a TTL parameter in the `REGISTER` message, with an upper bound of 72 hours.

The rendezvous protocol runs over libp2p streams using the protocol ID `/rendezvous/1.0.0`.

<!-- TO ADD: Interaction diagrams and context -->

### Rendezvous and publish-subscribe

For effective real-time discovery, rendezvous can be combined with [libp2p publish/subscribe](../messaging/pubsub/overview). At a basic level, rendezvous can bootstrap pubsub by discovering peers
subscribed to a topic. The rendezvous would be responsible for publishing packets, subscribing,
or unsubscribing from packet shapes.

Pubsub can also be used as a mechanism for building rendezvous services, where a number
of rendezvous points can federate using pubsub for internal real-time distribution while still
providing a simple interface to clients.

<!-- TO ADD: Interaction diagrams and context -->

{{< alert icon="💡" context="note" text="See the rendezvous <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/rendezvous/README.md\">technical specification</a> for more details." />}}
