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
connection built on top of UDP. It started as an experiment by Google between Google 
services and Chrome in 2014, and was later standardized by the IETF in 
[RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000), 
[RFC 9001](https://datatracker.ietf.org/doc/html/rfc9001), and
[RFC 9002](https://datatracker.ietf.org/doc/html/rfc9002).

### Key challenges with TCP

1. Head-of-line blocking (HoL blocking): TCP is a single byte stream exposed by the 
   kernel, so streams layered on top of TCP experience head-of-line (HoL) blocking.

   {{% notice "info" %}}
   In TCP, head-of-line blocking occurs when a single packet is lost, and packets delivered 
   after that need to wait in the kernel buffer until a retransmission for the lost packet 
   is received.
   {{% /notice %}}

2. Ossification: Because the header of TCP packet is not encrypted, middleboxes can 
   inspect and modify TCP header fields and may break unexpectedly when they encounter 
   anything they don’t understand. This makes it practically impossible to deploy any 
   changes to the TCP protocol that change the wire format.

3. Handshake inefficiency: TCP spends one network round-trip (RTT) on verifying the 
   client's address. Only after this can TLS start the cryptographic handshake, consuming 
   another RTT. Setting up an encrypted connection therefore always takes 2-RTTs.

QUIC was designed with the following goals in mind:

- Making the transport layer aware of streams, so that packet loss doesn't cause HoL blocking 
  between streams.
- Reducing the latency of connection establishment to a single RTT for new connections, and to 
  allow sending of 0-RTT application data for resumed connections.
- Encrypting as much as possible. This eliminates the ossification risk, as middleboxes aren't 
  able to read any encrypted fields. This allows future evolution of the protocol.

### Comparing HTTP/2 and HTTP/3

The IETF introduced a new hypertext transfer protocol standard in late 2018, 
which turned into a proposed standard for HTTP/3 in 
[RFC 9114](https://datatracker.ietf.org/doc/html/rfc9114). HTTP/3 combines the advantages 
of the existing transfer protocols HTTP/2 and HTTP over QUIC in one standard for faster and 
more stable data transmission.

The following diagram illustrates the OSI model for HTTP/2 and HTTP/3 [1]:

![HTTP/2 & HTTP/3 OSI model](https://cloudspoint.xyz/wp-content/uploads/2022/03/http3.png)

A web browser connection typically entails the following **(TCP+TLS+HTTP/2)**:

1. Transport layer: TCP runs on top of the IP layer to provide a reliable 
   byte stream.
   - TCP provides a reliable, bidirectional connection between two end systems.
2. Security layer: A TLS handshake runs on top of TCP to
   establish an encrypted and authenticated connection.
   - Standard TLS over TCP requires 3-RTT. A typical TLS 1.3 handshake takes 1-RTT.
3. Application layer: HTTP runs on a secure transport connection to transfer 
   information and applies a stream muxer to serve multiple requests.
   - Application data starts to flow.

In contrast, HTTP/3 runs over [QUIC](##what-is-quic), where QUIC is similar to 
TCP+TLS+HTTP/2 and runs over UDP. Building on UDP allows HTTP/3 to bypass the challenges 
found in TCP and use all the advantages of HTTP/2 and HTTP over QUIC.

### What is QUIC?

QUIC combines the functionality of these layers. Instead of TCP, it builds on UDP. 
When a UDP datagram is lost, it is not automatically retransmitted by the kernel. 
QUIC therefore takes responsibility for loss detection and repair itself. By using 
encryption, QUIC avoids ossified middleboxes. The TLS 1.3 handshake is performed in 
the first flight, removing the cost of verifying the client’s address and saving an 
RTT. QUIC also exposes multiple streams (and not just a single byte stream), so 
no stream multiplexer is needed at the application layer. Part of the application 
layer is also built directly into QUIC.

In addition, a client can make use of QUIC's 0-RTT feature for subsequent connections 
when it has already communicated with a certain server. The client can then send 
(encrypted) application data even before the QUIC handshake has finished.

### QUIC in libp2p

libp2p only supports bidirectional streams and uses TLS 1.3 by default. 
Since QUIC already provides an encrypted, stream-multiplexed connection, 
libp2p directly uses QUIC streams, without any additional framing.

To authenticate each others' peer IDs, peers encode their peer ID into a self-signed 
certificate, which they sign using their host's private key. This is the same way peer 
IDs are authenticated in the 
[libp2p TLS handshake](https://github.com/libp2p/specs/blob/master/tls/tls.md).

{{% notice "note" %}}

To be clear, there is no additional security handshake and stream muxer needed as QUIC 
provides all of this by default. This also means that establishing a libp2p connection between
two nodes using QUIC only takes a single RTT.

{{% /notice %}}

Following the multiaddress format described earlier, a standard QUIC connection will
look like: `/ip4/127.0.0.1/udp/65432/quic/`.

## References

[1] [What is HTTP/3 by Cloudspoint](https://cloudspoint.xyz/what-is-http3/)
