---
title: Transport
weight: 1
---

When you make a connection from your computer to a machine on the internet,
chances are pretty good you're sending your bits and bytes using TCP/IP, the
wildly successful combination of the Internet Protocol, which handles addressing
and delivery of data packets, and the Transmission Control Protocol, which
ensures that the data that gets sent over the wire is received completely and in
the right order.

Because TCP/IP is so ubiquitous and well-supported, it's often the default
choice for networked applications. In some cases, TCP adds too much overhead,
so applications might use [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol),
a much simpler protocol with no guarantees about reliability or ordering.

While TCP and UDP (together with IP) are the most common protocols in use today,
they are by no means the only options. Alternatives exist at lower levels
(e.g. sending raw ethernet packets or bluetooth frames), and higher levels
(e.g. QUIC, which is layered over UDP).

In libp2p, we call these foundational protocols that move bits around
**transports**, and one of libp2p's core requirements is to be
*transport agnostic*. This means that the decision of what transport protocol
to use is up to the developer, and in fact one application can support many
different transports at the same time.

## Listening and Dialing
Transports are defined in terms of two core operations, **listening** and
**dialing**.

Listening means that you can accept incoming connections from other peers,
using whatever facility is provided by the
transport implementation. For example, a TCP transport on a unix platform could
use the `bind` and `listen` system calls to have the operating system route
traffic on a given TCP port to the application.

Dialing is the process of opening an outgoing connection to a listening peer.
Like listening, the specifics are determined by the implementation, but every
transport in a libp2p implementation will share the same programmatic interface.

## Addresses

Before you can dial up a peer and open a connection, you need to know how to
reach them. Because each transport will likely require its own address scheme,
libp2p uses a convention called a "multiaddress" or `multiaddr` to encode
many different addressing schemes.

The [addressing doc](/concepts/addressing/) goes into more detail, but an overview of
how multiaddresses work is helpful for understanding the dial and listen
interfaces.

Here's an example of a multiaddr for a TCP/IP transport:

```
/ip4/7.7.7.7/tcp/6543
```

This is equivalent to the more familiar `7.7.7.7:6543` construction, but it
has the advantage of being explicit about the protocols that are being
described. With the multiaddr, you can see at a glance that the `7.7.7.7`
address belongs to the IPv4 protocol, and the `6543` belongs to TCP.

For more complex examples, see [Addressing](/concepts/addressing/).

Both dial and listen deal with multiaddresses. When listening, you give the
transport the address you'd like to listen on, and when dialing you provide the
address to dial to.

When dialing a remote peer, the multiaddress should include the
[PeerId](/concepts/peer-id/) of the peer you're trying to reach.
This lets libp2p establish a [secure communication channel](/concepts/secure-comms/)
and prevents impersonation.

An example multiaddress that includes a `PeerId`:

```
/ip4/1.2.3.4/tcp/4321/p2p/QmcEPrat8ShnCph8WjkREzt5CPXF2RwhYxYBALDcLC1iV6
```

The `/p2p/QmcEPrat8ShnCph8WjkREzt5CPXF2RwhYxYBALDcLC1iV6` component uniquely
identifies the remote peer using the hash of its public key.
For more, see [Peer Identity](/concepts/peer-id/).

{{% notice "tip" %}}

When [peer routing](/concepts/peer-routing/) is enabled, you can dial peers
using just their PeerId, without needing to know their transport addresses
before hand.

{{% /notice %}}

## Supporting multiple transports

libp2p applications often need to support multiple transports at once. For
example, you might want your services to be usable from long-running daemon
processes via TCP, while also accepting websocket connections from peers running
in a web browser.

The libp2p component responsible for managing the transports is called the
[switch][definition_switch], which also coordinates
[protocol negotiation](/concepts/protocols/#protocol-negotiation),
[stream multiplexing](/concepts/stream-multiplexing),
[establishing secure communication](/concepts/secure-comms/) and other forms of
"connection upgrading".

The switch provides a single "entry point" for dialing and listening, and frees
up your application code from having to worry about the specific transports
and other pieces of the "connection stack" that are used under the hood.

{{% notice "note" %}}
The term "swarm" was previously used to refer to what is now called the "switch",
and some places in the codebase still use the "swarm" terminology.
{{% /notice %}}

[definition_switch]: /reference/glossary/#switch

## QUIC

QUIC is a new transport protocol that provides an always-encrypted, stream-multiplexed 
connection built on top of UDP. It started as an experiment by Google on Google Chrome 
in 2014, and was later standardized by the IETF in 
[RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000).

### Key challenges with TCP

1. Head-of-line blocking (HoL blocking): TCP is a single byte stream exposed by the kernel, 
   so streams layered on top of TCP experience HoL blocking.

   {{% notice "info" %}}
   HoL blocking occurs when a the head packet holds up the other packets in the transmission 
   queue. 
   {{% /notice %}}

2. Ossification: Because TCP is unencrypted, middleboxes can inspect and modify
   TCP header fields and may break unexpectedly when they encounter anything they don’t like.

   {{% notice "info" %}}
   Middleboxes are intermediary networking devices that can perform special functions to 
   inspect, transform, and even manipulate network traffic. Examples of middleboxes are 
   firewalls, NATs, proxies, and load balancers.
   {{% /notice %}}

3. Handshake inefficiency: the 3-way handshake is inefficient, as it spends 1-RTT on verifying 
   the client’s address.

   {{% notice "info" %}}
   TCP requires a 3-way handshake to establish a reliable, bidirectional connection as it intends to.
   {{% /notice %}}

We need a transport protocol that:

- Understands streams 
- Overcomes HOL blocking (Head-of-line blocking)
- Overcomes the latency of connection setup
- Overcomes the ossification risks of TCP

and, ideally, keeps the guarantees of TCP.

A web browser connection typically entails the following (TCP+TLS+HTTP/2):

1. Transport layer: TCP runs on top of the IP layer to provide a reliable 
   byte stream.
   - TCP provides a reliable, bidirectional connection between two end systems.
2. Secure communication layer: A TLS handshake runs on top of TCP to,
   establishing an encrypted and authenticated connection.
   - Standard TLS over TCP requires 3-RTT. A typical TLS 1.3 handshake takes 1-RTT.
3. Application layer: HTTP runs on a secure transport connection to transfer 
   information and applies a stream muxer to serve multiple requests.
   - Application data starts to flow.

<!-- to add diagram -->

### What is QUIC?

QUIC combines the functionality of these layers: it sends UDP packets. Therefore, 
it is responsible for loss detection and repair itself. By using encryption, 
QUIC avoid middleboxes. The TLS 1.3 handshake is performed in the first flight, 
removing the 1-RTT cost of verifying the client’s address. QUIC also exposes multiple 
streams, so no stream multiplexer is needed at the application layer. Part of the application 
layer is also built directly into QUIC; when you run HTTP on top of QUIC; only a small shim 
layer exists that maps 
[HTTP semantics](https://httpwg.org/http-core/draft-ietf-httpbis-semantics-latest.html) 
onto QUIC streams.

QUIC supports the resumption of connections (0-RTT connections), allowing a 
client to send application data right away, even before the QUIC handshake has finished.

<!-- to add diagram -->

### QUIC in libp2p

libp2p only supports bidirectional streams and uses TLS 1.3 by default. 
The streams in libp2p map cleanly to QUIC streams.

When a connection starts, peers will take their host key and create a self-signed CA 
certificate. They then sign an intermediate chain using their self-signed CA and put it 
as a certificate chain in the TLS handshake. View the full TLS specification
[here](https://github.com/libp2p/specs/blob/master/tls/tls.md).

{{% notice "note" %}}

To be clear, there is no additional security handshake and stream muxer needed as QUIC 
provides all of this by default.

{{% /notice %}}

Following the multiaddress format described earlier, a standard QUIC connection will
look like: `/ip4/127.0.0.1/udp/65432/quic/`.

In this section, we offered an overview of QUIC and how QUIC works in libp2p.
