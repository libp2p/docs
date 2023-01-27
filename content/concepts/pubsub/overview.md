---
title: "What is Publish/Subscribe"
description: "Publish/Subscribe is a system where peers congregate around topics they are interested in. Peers interested in a topic are said to be subscribed to that topic. Learn about how peers can message data in libp2p."
weight: 230
aliases:
    - "/concepts/publish-subscribe"
    - "/concepts/pubsub"
---

## Overview

Publish/Subscribe (PubSub) is a messaging pattern where senders of messages, known as
publishers, do not send them directly to specific receivers; instead, they send them to
a topic or a channel that contains subscribers. Subscribers can express interest
in one or more topics and only receive messages that are of interest to them.
This allows for a decoupling of senders and receivers and multiple subscribers to receive
the same message.

PubSub systems that are centralized rely on a centralized broker, known as a message
broker, which is responsible for filtering and forwarding messages. In P2P PubSub systems,
however, there is no centralized broker. Instead, each node in the network is both a
publisher and a subscriber and is responsible for forwarding messages to other nodes.
All peers participate in delivering messages throughout the network.

There are different types of PubSub models, like event-based, data-centric, content-based,
and topic-based, each with its use cases and advantages. The event-based model is useful
for systems that react to specific events in real time, while the data-centric model is best
suited for systems that share and synchronize data among multiple nodes. Content-based and
topic-based models provide more fine-grained control over message filtering and routing.
In general, desirable model properties include:

- **Reliability**: All messages get delivered to all peers subscribed to the topic.
- **Speed**: Messages are delivered quickly.
- **Efficiency**: The network is not flooded with excess copies of messages.
- **Resilience**: Peers can join and leave the network without disrupting it.
  There is no central point of failure.
- **Scale**: Topics can have enormous subscribers and handle a large throughput of messages.
- **Simplicity**: The system is simple to understand and implement. Each peer only needs to
  remember a small amount of state.

### PubSub for the distributed web

There are many P2P applications that can stem from using a P2P-based PubSub system, including:

- **Decentralized Social Networking**: Each user is a peer and can create and join different
  groups or topics, where they can post and receive updates, messages, and comments in real time.
- **Decentralized File Sharing**: Peers can publish files on a specific topic, and others can subscribe
  to  that topic to download the file. The peers can also share information about the availability
  of different parts of the file, allowing for faster and more efficient downloads.
- **Distributed Gaming**: Each game room is a topic, and players can publish and receive updates,
  messages, and events in real time as they play.
- **IoT and Smart Home**: IoT devices can publish sensor data on specific topics, and other devices or
  applications can subscribe to these topics to receive the data and take appropriate actions.
- **Decentralized Marketplaces**: Peers can publish and discover goods and services on specific topics
  and communicate and transact with each other through the PubSub system.
- **Decentralized Streaming**: Peers can broadcast live streams on specific topics, and others can subscribe
  to these topics to watch the streams in real time.
- **Decentralized Chat and Video Conferencing**: Peers can create and join specific chat rooms or video
  conference rooms and publish and receive real-time messages and audio/video streams.

## Publish/Subscribe in libp2p

The PubSub system in libp2p allows peers to congregate around topics of interest and communicate in
real-time. Peers can express interest in one or more topics and send and receive messages on these topics.

While the PubSub system in libp2p is scalable and fault-tolerant, P2P-based PubSub systems pose new
challenges. One of the main challenges is ensuring that messages are delivered to all interested parties
promptly and efficiently. This is particularly challenging in large and dynamic networks, where the topology
and the set of subscribers can change frequently.

To address this challenge and many others (described here), libp2p uses a PubSub protocol called
[GossipSub](gossipsub.md), a gossip-based protocol named after the fact that peers gossip to each other about
which messages they have seen, and uses this information to maintain a message delivery network.

Learn more about GossipSub [here](gossipsub.md).
