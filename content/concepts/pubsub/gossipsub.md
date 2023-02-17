---
title: "GossipSub"
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

## Types of peering

In gossipsub, peers connect via either **full-message** peerings
or **metadata-only** peerings. The overall network structure is made up of these
two networks:

<img src="../../assets/publish-subscribe/types_of_peering.png">

### Full-message

Full-message peerings are used to transmit the full contents of messages
throughout the network. This network is sparsely connected, with each peer only
being connected to a few others. (In the
[gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md)
this sparsely-connected network is called a *mesh*, and peers within it are
called *mesh members*.)

Limiting the number of full-message peerings is helpful because it keeps the
amount of network traffic under control; each peer only forwards messages to a
few others rather than all. Each peer has a target number of peers
it wants to be connected to. In this example, each peer would ideally like to be
connected to <mark style=" background-color:lavender">3</mark> other peers but would settle
for <mark style=" background-color:lavender">2</mark>–<mark style=" background-color:lavender">4</mark>
connections:

<img src="../../assets/publish-subscribe/full_message_network.png">

{{< alert icon="💡" context="note">}}
Throughout this guide, numbers <mark style= "background-color:lavender">highlighted in purple</mark> can be configured
by the developer.
{{< /alert >}}

The peering degree (also called the *network degree* or *D*) controls the
trade-off between speed, reliability, resilience, and efficiency of the network.
A higher peering degree helps messages get delivered faster, with a better
chance of reaching all subscribers and less chance of any peer disrupting
the network by leaving. However, a high peering degree also causes additional
redundant copies of each message to be sent throughout the network, increasing
the bandwidth required to participate.

### Metadata-only

In addition to the sparsely-connected network of full-message peerings, there is
also a densely-connected network of metadata-only peerings. This network is made
up of all the network connections between peers that aren't full-message
peerings.

The metadata-only network shares gossip about which messages are available and
performs functions to help maintain the network of full-message peerings.

<img src="../../assets/publish-subscribe/metadata_only_network.png">

## Grafting and pruning

Peerings are **bidirectional**, meaning that for any two connected peers, both
peers consider their connection to be full-message, or both peers consider their
connection to be metadata-only.

Either peer can change the connection type by notifying the other. **Grafting** is
converting a metadata-only connection to a full message. **Pruning**
is the opposite process, converting a full-message peering to metadata-only:

<img src="../../assets/publish-subscribe/graft_prune.png">

When a peer has too few full-message peerings, it will randomly graft some of its
metadata-only peerings to become full-message peerings:

<img src="../../assets/publish-subscribe/maintain_graft.png">

Conversely, when a peer has too many full-message peerings, it will randomly
prune some of them back to metadata-only:

<img src="../../assets/publish-subscribe/maintain_prune.png">

In libp2p's implementation, each peer performs a series of checks every
<mark style= "background-color:lavender">1</mark> second. These checks are called the
*heartbeat*. Grafting and pruning happen during this time.

### Peering Agreements

GossipSub v1.1 introduces explicit peering agreements, a mechanism for node operators to establish
and maintain connections with a predefined set of peers, regardless of the peer scoring system and
other defensive measures.

The router must establish and maintain a connection
with every explicit peer. The connections are initially set when the router boots and are
periodically checked for connectivity and reconnected if the connectivity is lost. With explicit
peering, the application can specify a list of peers to remain connected and
forward messages to each other unconditionally.

Explicit peers exist outside the mesh: every new valid incoming message is forwarded to the direct
peers, and incoming RPCs are always accepted. It is an error to GRAFT on an explicit peer, and such
an attempt should be logged and rejected with a PRUNE.

### PRUNE Backoff and Peer Exchange

Gossipsub v1.1 introduces PRUNE backoff and peer exchange, a mechanism for bootstrapping the network
and mitigating oversubscription. When a peer is pruned from the mesh because of oversubscription,
instead of simply telling the pruned peer to go away, the pruning peer may provide a set of other
peers whom the pruned peer can connect to reform its mesh. This allows for more efficient bootstrapping
of the network, as the pruned peer can quickly find new peers to form its mesh without relying on an
external peer discovery service.

When a peer tries to regraft too early, the pruning peer may apply a behavioral penalty for the action
and penalize the peer. In addition, both the pruned and the pruning peer add a backoff period from each
other, within which they will not try to regraft. This helps prevent constant regrafting attempts and
allows for a more stable network.

When unsubscribing from a topic, the backoff period should be finished before subscribing to the topic
again. Otherwise, a healthy mesh will be difficult to reach. A shorter backoff period can be used in case
of an unsubscribe event, allowing faster resubscribing.

## Peer Scoring

GossipSub uses a peer scoring system to decide which peers to keep in the mesh and which to prune.
The scoring system considers parameters such as time in mesh, message delivery rate,
and invalid messages. The scoring function is configurable by the application and can be tuned to
the specific needs of the application.

### The Score Function

A scoring function evaluates the quality of a peer's participation in the
mesh for each topic. The score function determines which peers to prune,
retain, and accept when new peers want to join the mesh. The score is a weighted combination of several
parameters, some of which are specific to a topic and others that apply globally.

### Topic Parameter Calculation and Decay

Topic parameters are used by the score function and are maintained by the router. These parameters are
updated whenever an event of interest occurs, such as when a message is forwarded, or a peer is pruned.
To prevent these parameters from continuously increasing, they are subject to decay. The application
can configure the decay interval with shorter intervals resulting in a faster decay of the parameters.

### Guidelines for Tuning the Scoring Function

The scoring function has several configurable parameters that can be adjusted to suit the needs of an
application. However, determining the optimal configuration for these parameters can be challenging.
The GossipSub v1.1 specification provides guidelines for tuning the scoring
function based on simulation results to aid in this process. These guidelines will help developers
understand how to adjust their specific use case parameters.

## Gossip Protocol

GossipSub uses "gossiping" for message dissemination and topic-based subscription.
Each peer maintains a set of connections to other peers in the network, called the *mesh*.
Peers exchange and control messages to keep their mesh state up to date.

Peers gossip about messages they have recently seen. Every
<mark style="background-color:lavender">1</mark> second, each peer randomly selects
<mark style="background-color:lavender">6</mark> metadata-only peers and sends them a list of messages
recently seen.

<img src="../../assets/publish-subscribe/gossip_deliver.png">

Gossiping lets peers notice if they missed a message on the
full-message network. If a peer notices it is repeatedly missing messages, it can set up new
full-message peerings with peers that do have the messages.

Here is an example of how a specific message can be requested across a
metadata-only peering:

<img src="../../assets/publish-subscribe/request_gossiped_message.png">

In the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#control-messages),
gossip announcing recently seen messages are called `IHAVE` messages and
requests for specific messages are called `IWANT` messages.

### Topic-based Subscription

A peer can subscribe to one or more topics by sending a `SUBSCRIBE` control message
to its mesh peers. The message includes a list of topics the peer is interested in.
When a peer receives a `SUBSCRIBE` message, it adds the peer to its mesh for the
specified topics.

Peers keep track of which topics their directly-connected peers are subscribed
to. Using this information, each peer can build up a picture of the topics
around them and which peers are subscribed to each topic:

<img src="../../assets/publish-subscribe/subscriptions_local_view.png">

Keeping track of subscriptions happens by sending SUBSCRIBE and
UNSUBSCRIBE messages. When a new connection is established between two peers,
they start by sending each other the list of topics they are subscribed to:

<img src="../../assets/publish-subscribe/subscription_list_first_connect.png">

Then over time, whenever a peer subscribes or unsubscribes from a topic, it will
send each of its peers a subscribe or unsubscribe message. These messages are
sent to all connected peers regardless of whether the receiving peer is
subscribed to the topic in question:

<img src="../../assets/publish-subscribe/subscription_list_change.png">

Subscribe and unsubscribe messages go hand-in-hand with graft and prune
messages. When a peer subscribes to a topic, it will pick some peers that will
become its full-message peers for that topic and send them graft messages at the
same time as their subscribe messages:

<img src="../../assets/publish-subscribe/subscribe_graft.png">

When a peer unsubscribes from a topic, it will notify its full-message peers that
their connection has been pruned at the same time as sending their unsubscribe
messages:

<img src="../../assets/publish-subscribe/unsubscribe_prune.png">

## Sending messages

When a peer wants to publish a message, it sends a copy to all full-message peers
it is connected to the following:

<img src="../../assets/publish-subscribe/full_message_send.png">

Similarly, when a peer receives a new message from another peer, it stores the
message and forwards a copy to all other full-message peers it is connected to:

<img src="../../assets/publish-subscribe/full_message_forward.png">

In the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#controlling-the-flood),
peers are also known as *routers* because of the function they have in routing
messages through the network.

Peers remember a list of recently seen messages. This lets peers act upon a
message only the first time they see it and ignore retransmissions of already
seen messages.

Peers might also choose to validate the contents of each message received. What
counts as valid and invalid depends on the application. For example, a chat
application might enforce that all messages must be shorter than 100 characters.
If the application tells libp2p that a message is invalid, then that message will
be dropped and not replicated further through the network.

### Message Forwarding

When a peer receives a message for a topic it is subscribed to, it forwards the message to
all its mesh peers. The protocol uses a flooding algorithm to ensure that all messages are
disseminated throughout the network promptly. However, to prevent overloading the
network, a peer may choose only to forward a subset of messages to its mesh peers using a
configurable parameter called the `GossipFactor`.

## Fan-out

Peers are allowed to publish messages to topics they are not subscribed to.
There are some special rules about how to do this to help ensure these messages
are delivered reliably.

The first time a peer wants to publish a message on a topic, it is not subscribed
to, it randomly picks <mark style="background-color:lavender">6</mark> peers
(<mark style="background-color:lavender">3</mark> shown below) that are
subscribed to that topic and remembers them as **fan-out** peers for that topic:

<img src="../../assets/publish-subscribe/fanout_initial_pick.png">

Unlike the other types of peering, fan-out peerings are unidirectional; they
always point from the peer outside the topic to a peer subscribed to the topic.
Peers subscribed to the topic are not told they have been selected
and still treat the connection as any other metadata-only peering.

Each time the sender wants to send a message, it sends the message to its
fan-out peers, who then distribute the message within the topic:

<img src="../../assets/publish-subscribe/fanout_message_send.png">

If the sender goes to send a message but notices some of their fan-out peers
went away since last time, they will randomly select additional fan-out peers
to top them back up to <mark style="background-color:lavender">6</mark>.

When a peer subscribes to a topic, if it already has some fan-out peers, it will
prefer them to become full-message peers:

<img src="../../assets/publish-subscribe/fanout_grafting_preference.png">

After <mark style="background-color:lavender">2</mark> minutes of not sending any messages to
a topic, all the fan-out peers for that topic are forgotten:

<img src="../../assets/publish-subscribe/fanout_forget.png">

### Extended Validators

Gossipsub v1.1 introduces the concept of extended validators, which allows the application
to specify a more fine-grained message validation process. Extended validators provide more
control over how messages are handled, allowing the application to ignore particular messages
without triggering the penalty for invalid messages.

## Network packets

The packets that peers send each other over the network combine all the
different message types in this guide (application messages, have/want,
subscribe/unsubscribe, graft/prune). This structure allows several requests to
be batched and sent in a single network packet.

Here is a graphical representation of the overall network packet structure:

<img src="../../assets/publish-subscribe/network_packet_structure.png">

{{< alert icon="💡" context="note" text="See the GossipSub v1.1 <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/gossipsub-v1.1.md\">technical specification</a> for more details." />}}
