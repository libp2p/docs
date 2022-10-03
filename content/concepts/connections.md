---
title: Connections
weight: 3
---

A libp2p connection is a communication channel that allows two peers to read 
and write data to each other. Peers can connect to each other through transport 
protocols. Transport protocols are core abstractions of libp2p and offer 
extensibility. Being a modular networking stack, libp2p is transport-agnostic 
and does not enforce the implementation of a specific transport protocol. 
Though, the support of modern transport protocols are a primary focus for 
libp2p and implementers may choose to support multiple transports. Learn 
more about transport protocols in libp2p on the 
[transport guide]((/concepts/transports/)). 

Lets first outline key terminology to help us understand connections in libp2p.

## Core libp2p components

- **Peer**: a participant in a libp2p network.
- **Peer-to-Peer (P2P)**: a distributed network in which workloads are 
  shared between *Peers*.
- **Connection**: a network layer connection between two peers in a libp2p 
  network.
- **Transport**: a mechanism of communication that creates a *Connection*, 
  e.g. TCP, QUIC, WebRTC, etc.
- **Upgrader**: a mechanism that takes a *Connection* returned by a *Transport*, 
  and performs protocol negotiation to set up a secure, multiplexed channel on 
  top of which *Streams* can be opened.
- **Stream**: an abstraction on top of a *Connection* representing a bidirectional 
  communication channel between two *Peers*.
- **Multiplexer**: a mechanism that manages multiple streams and ensures parallel 
  messages reach the correct *Stream*, based on stream identification.
- **Secure channel**: establishes a secure, encrypted, and authenticated channel 
  over a *Connection*.

## Opening a libp2p connection

A libp2p connection only requires two core operations: dialing and listening. 
Both operations exist as interfaces in libp2p, where a transport protocol is used 
to expose the dialing and listening interfaces. The listening interface allows a 
peer to listen to connection requests from other peers, while the dialing interface 
allows a peer to send connection requests to a listening peer. Most of the connection 
initation process is abstracted through libp2p's interfaces.

### How do peers prevent multiple connections from being established? 

An interface called a [switch](/concepts/stream-multiplexing/#switch/swarm) 
(and sometimes swarm) implements a basic dial queue that manages the dialing
and listening state of an application. This prevents multiple, 
simultaneous dial requests to the same peer. Peers will generally dial other
peers using the switch interface, which initiates a stream to read from and write 
to. The switch will find the appropriate transport protocol to open a connection. 

### How do peers know what transports other peers support?

A data store known as a Peer Store in libp2p holds an updated data registry of 
all known peers and their Peer Info. Other peers can dial the Peer Store and listen 
for updates and learn about any peer within the network. More information about peers
is available on the [peers guide](/concepts/peers).

### How do peers establish a connection once they find other peers to connect to?

A peer sends its multiaddr to the switch when it is ready to connect. 
The dialing peer then triggers a dialing request to the listening peer via its 
multiaddr over the transport that the switch initated. 

To accept connections, a libp2p application registers handler functions for 
protocols using their protocol ID with the switch.

The handler function will be invoked when an incoming stream is tagged with the 
registered protocol id

More information on multiaddrs, peers, and protocols is available on the
[addressing](/concepts/addressing), [peers](/concepts/peers),
[protocol](/concepts/protocols) guides, respectively.

### How does the switch decide on which transport protocol to use?

The switch conducts a protocol negotiation process between two peers through an 
interface known as [`multistream-select`](https://github.com/multiformats/multistream-select).
In particular, the multicodec is negotiated between two peers.

### What happens when two peers do not support the same transports?

If a listener doesn't support a certain protocol, they may respond with "na" 
(not available), and the dialer can either try another protocol, request a list 
of supported protocols, or stop sending dialing requests.

Another option is using the [circuit relay](/concepts/circuit-relay) transport 
protocol, which routes network traffic between two peers over a relay peer. 
A peer can advertise itself as being reachable through a remote relay node. 

### How can the listening peer dial back to the peer that just dialed to it?

In general, a peer multiaddr is typically discovered with their Peer ID, which
acts as a unique identifer for each peer in a libp2p network.

If a peer relies on a relay node to listen to a dial request, circuit relaying 
creates a peer-to-peer circuit by adding the connection path to the connection 
multiaddr. Thus, a listening peer can use the same path to dial back to a peer 
that dialed to it.

### What if peers can’t find other peers to dial?

Libp2p offers a discovery mechanism to discover peers on a libp2p network, 
known as peer discovery. Once the network successfully discovers a peer multiaddr 
(and able to establish a connection), the peer discovery protocol adds the Peer 
Info and multiaddr to the Peer Store. Learn more about how to discover 
un-{known, identified} peers on the peer routing guide.

### How do peers check if other peers are dialable?

Peers can use the AutoNAT interface to check if a peer can be dialed too.

### What if a peer is not dialable?

Libp2p includes a decentralized hole punching feature that allows for firewall 
and NAT traversal. Learn more about establishing direct connections with non-public
nodes on the [hole punching guide](/concepts/circuit-relay).

## Constructing a libp2p connection

Before two peers can transmit data, the communication channel they established 
with a transport protocol should be secure. Each peer must also be able to open 
multiple independent streams of communication over a single channel. A transport 
protocol like QUIC provides these guarantees out-of-the-box, but other transports 
in libp2p do not provide the necessary logic to secure their channel and support 
multiple streams. This requires an upgrade to the *Transport* using an *Upgrader*.

{{% notice "info" %}}
Several security protocols are supported in libp2p for encryption, the two primary 
ones being Noise and TLS 1.3. See the secure channel guide for more information on 
protocol security. Learn more about Noise and TLS 1.3 on the secure channels guide.
<!-- to reference secure channels guide when available -->
Stream multiplexing (or *stream muxing*) is a way of sending and managing multiple 
streams of data over one communication link. The stream muxer combines multiple 
signals into one unified signal and then demulitiplexed (*demuxed*) to the correct 
output, distinguished by a unique identifer. Learn more about stream muxing on the 
[stream multiplexing guide](/concepts/stream-multiplexing).
{{% /notice %}}

Security is always established first over the raw connection. The negotiation for 
stream multiplexing then takes place over the encrypted channel.

## Protocol negotiation

To upgrade a transport connection in libp2p -

...
...

If there was an existing connection made to a remote peer, the switch will simply 
use the existing connection and open another multiplexed stream over it.

{{% notice "note" %}}
Connections in libp2p are meant to be flexible, allowing communication to be 
future-proof. Connections should evolve as technology evolves, meaning that the construct 
of a libp2p connection can change. An example of this is the now deprecated SECIO secure 
channel protocol. SECIO used to be the default libp2p encryption method, but has been since 
phased out and replaced with more 
{{% /notice %}}
