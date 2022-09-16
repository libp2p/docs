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

Transport protocols continue to improve transport methods in an attempt to alleviate 
the shortcomings of the transport layer. 

{{% notice "note" %}}

Recalling the purpose of transports

The IP service model provides logical communication between hosts (or nodes) but 
is considered a best-effort delivery service, as segment delivery is not guaranteed. 
The primary responsibility of transport protocols is to extend the IP 
delivery service between two end systems. TCP connects the unreliable service of IP 
between end systems into a reliable transport service between processes (i.e., the 
processes running on the end systems). The purpose of newer transport protocols is not 
only to improve current transport methods but also to allow for efficient connections 
that distributed and peer-to-peer network stacks can utilize, like libp2p.

{{% /notice %}}

We need a transport protocol that:

- Understands streams 
- Is not byte-ordered
- Overcomes HOL blocking (Head-of-line blocking)
- Overcomes the latency of connection setup
- Overcomes the ossification risks of TCP

and, ideally, with the guarantees of TCP.

In 2014, a new transport protocol 
called QUIC (which, at the time, stood for Quick UDP Internet Connections, but now 
is only referred to as QUIC and does not use the original acronym) was launched as an 
experiment on Google Chrome. It has since been refined and maintained by an official 
working group under the IETF (Internet Engineering Task Force). 

QUIC is a UDP-based multiplexed and secure transport. 
The official standard is defined in [RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000).

Being UDP-based, QUIC optimizes for speedy transmission, as opposed to the latency 
that exists in HTTP leveraging TLS over TCP.

A web browser connection typically entails the following (TCP+TLS+HTTP/2):

1. IP layer: the connection will run on the IP layer, which is responsible for 
   packet routing. 
2. Transport layer: TCP then runs on top of the IP layer to provide a reliable 
   byte stream.
3. Secure communication layer: Secure communication (i.e., TLS) runs on TCP to 
   encrypt the bytes.
   - Negotiation (SYN-ACK) of encryption parameters for TLS. Standard TLS over 
     TCP requires 3 RTT.
4. Application layer: HTTP runs on a secure transport connection to transfer 
   information.
   - Data starts to flow.

Secure TCP-based connections offer a multi-layered approach for secure communication 
over IP, whereas QUIC, by design, is an optimized transport consolidation of layers. 
QUIC has to deal with TCP-like congestion control, loss recovery, and encryption. 
Part of the application layer is also built directly into QUIC; when you
run HTTP on top of QUIC; only a small shim layer exists that maps 
[HTTP semantics](https://httpwg.org/http-core/draft-ietf-httpbis-semantics-latest.html) 
onto QUIC streams.

To establish a connection, QUIC assumes that the node sends the right address over
the packet. QUIC saves one round-trip by doing this. If there is suspicion of an 
attack, QUIC has a defense mechanism that can require a three-way handshake, but only 
under particular conditions. A minimum packet size rule exists for the first packet to 
ensure that small malicious packets like SYN packets cannot be sent and consume excessive 
resources, as can be done with TCP.

QUIC saves another round-trip in using TLS 1.3 by optimistically providing keyshares. 
If you have established a connection before, the host can send you a session ticket 
that can be used to establish a new secure connection instantly, without any round-trips.

> Over the last several years, the IETF has been working on a new version of TLS, TLS 1.3.
> Learn more about TLS 1.3 and how it is used in libp2p on the secure communication concept guide.

<!-- to add link to secure comm guide, and later to the specific doc that covers TLS -->

libp2p only supports bidirectional streams and uses TLS 1.3 by default (but can use other
cryptography methods). The streams in libp2p map cleanly to QUIC packets.

When a connection starts, peers will take their host key and create a self-signed CA 
certificate. They then sign an intermediate chain using their self-signed CA and put it 
as a certificate chain in the TLS handshake.

At the end of the handshake, each peer knows the certificate of the other. The peer can 
verify if the connection was established with the correct peer by looking up the first 
CA certificate on the certificate chain, retreive the public key, and using it to calculate 
the opposing peer ID. QUIC acts like a record layer with TLS 1.3  as the backend as TLS is 
responsible for all the cryptography.

{{% notice "info" %}}

To be clear, there is no additional security handshake and stream muxer need as QUIC provides 
all of this by default.

{{% /notice %}}

Following the multiaddress format described earlier, a standard QUIC connection will
look like:

```
/ip4/127.0.0.1/udp/65432/quic/
```

In this section, we offered an overview of QUIC and how QUIC works in libp2p.

{{% notice "tip" %}}

For more details on QUIC, including its limitations 
check out the following resources:

{{% /notice %}}

## WebTransport

Another transport protocol under development at the IETF is WebTransport.
WebTransport is a new specification that uses QUIC to offer an alternative to
WebSockets. Instead, it can be considered WebSockets over QUIC by allowing 
browsers to establish a stream-multiplexed and bidirectional 
connection to servers. 

The specification can depend on and reuse the QUIC infrastructure in place 
to offer WebSockets that take the benefits of UDP and offer sockets without head-of-line 
blocking.

Recall that WebSockets are bidirectional, full-duplex communication between two 
points over a single-socket connection. WebTransports, as a result, can be used
like WebSockets, but with the support of multistreams.

WebTransport streams can be arbitrary in size and independent when possible. 
They are reliable but can be canceled when possible. The datagrams in a 
WebTransport connections are MTU-sized and can be unreliable when possible.

{{% caution "note" %}}

There is a functioning WebTransport implementation in go-libp2p that is part 
of the v0.23 release.

The implementation should be used experimentally and is not recommended for
production environments.

{{% /notice %}}

For network stacks like libp2p, WebTransport is a pluggable
protocol that fits well with a modular network design.

For a standard WebSocket connection:

- 1 RTT for DNS resolution
- 1 RTT for TCP handshake
- 1 RTT for TLS handshake
- 1 RTT for WebSocket handshake
- 1 RTT for Multistream Security handshake
- 1 RTT for libp2p handshake

Plenty of handshakes and roundtrips: 6 RTTs: 5 handshakes + 1 DNS resolution

WebTransport running over QUIC only requires 4 RTTs, as:

- 1 RTT for QUIC handshake
- 1 RTT for WebTransport handshake
- 2 RTT for libp2p handshake; one for multistream and one for the secure 
  communication (TLS 1.3 or Noise)

> With protocol select, the WebTransport handshake and the libp2p handshake 
> can run in parallel, bringing down the total round trips to 2.

WebTransport multiaddresses are composed of a QUIC multiaddr, followed 
by `/webtransport` and a list of multihashes of the node certificates that the server uses.

For instance, for multiaddress `/ip4/127.0.0.1/udp/123/quic/webtransport/certhash/<hash1>`, 
a standard local QUIC connection is defined up until and including `/quic.` 
Then, `/webtransport/` runs over QUIC and the self-signed certificate hash that the 
server will use to verify the connection.

WebTransport requires an HTTPS URL to establish a WebTransport session - 
e.g., `https://docs.libp2p.com/webtransport` and the multiaddresses use an HTTP URL
instead. Since multiaddrs don't allow the encoding of URLs, the HTTP endpoint of a libp2p 
WebTransport servers must be located at `/.well-known/libp2p-webtransport`.

For instance, the WebTransport URL of a WebTransport server advertising 
`/ip4/1.2.3.4/udp/1234/quic/webtransport/` would be `https://1.2.3.4:1234/.well-known/libp2p-webtransport?type=tls`.
