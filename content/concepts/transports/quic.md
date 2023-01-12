---
title: "QUIC"
description: "QUIC is a new transport protocol that provides an always-encrypted, stream-multiplexed connection built on top of UDP. Learn about QUIC and how it is used in libp2p."
weight: 90
aliases:
    - "/concepts/transports/quic"
---

## What is QUIC?

QUIC is a new transport protocol that provides an always-encrypted, stream-multiplexed
connection built on top of UDP. It started as an experiment by Google between Google
services and Chrome in 2014, and was later standardized by the IETF in
[RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000),
[RFC 9001](https://datatracker.ietf.org/doc/html/rfc9001), and
[RFC 9002](https://datatracker.ietf.org/doc/html/rfc9002).

### Key challenges with TCP

1. Head-of-line blocking (HoL blocking): TCP is a single byte stream exposed by the
   kernel, so streams layered on top of TCP experience head-of-line (HoL) blocking.

   {{< alert icon="💡" context="info" text="In TCP, head-of-line blocking occurs when a single packet is lost, and packets delivered after that need to wait in the kernel buffer until a retransmission for the lost packet is received." />}}

2. Ossification: Because the header of TCP packet is not encrypted, middleboxes can
   inspect and modify TCP header fields and may break unexpectedly when they encounter
   anything they don’t understand. This makes it practically impossible to deploy any
   changes to the TCP protocol that change the wire format.

3. Handshake inefficiency: TCP spends one network round-trip (RTT) on verifying the
   client's address. Only after this can TLS start the cryptographic handshake, consuming
   another RTT. Setting up an encrypted connection therefore always takes 2 RTTs.

QUIC was designed with the following goals in mind:

- Making the transport layer aware of streams, so that packet loss doesn't cause HoL blocking
  between streams.
- Reducing the latency of connection establishment to a single RTT for new connections, and to
  allow sending of 0 RTT application data for resumed connections.
- Encrypting as much as possible. This eliminates the ossification risk, as middleboxes aren't
  able to read any encrypted fields. This allows future evolution of the protocol.

### Comparing HTTP/2 and HTTP/3

In addition to defining the QUIC transport, the IETF also standardized a new version of HTTP that runs on top of QUIC: HTTP/3 (
[RFC 9114](https://datatracker.ietf.org/doc/html/rfc9114)). HTTP/3 combines the advantages
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
   - Standard TLS over TCP requires 3 RTT. A typical TLS 1.3 handshake takes 1 RTT.
3. Application layer: HTTP runs on a secure transport connection to transfer
   information and applies a stream muxer to serve multiple requests.
   - Application data starts to flow.

In contrast, HTTP/3 runs over [QUIC](#what-is-quic), where QUIC is similar to
TCP+TLS+HTTP/2 and runs over UDP. Building on UDP allows HTTP/3 to bypass the challenges
found in TCP and use all the advantages of HTTP/2 and HTTP over QUIC.

### How does QUIC work?

QUIC combines the functionality of these layers. Instead of TCP, it builds on UDP.
When a UDP datagram is lost, it is not automatically retransmitted by the kernel.
QUIC therefore takes responsibility for loss detection and repair itself. By using
encryption, QUIC avoids ossified middleboxes. The TLS 1.3 handshake is performed in
the first flight, removing the cost of verifying the client’s address and saving an
RTT. QUIC also exposes multiple streams (and not just a single byte stream), so
no stream multiplexer is needed at the application layer. Part of the application
layer is also built directly into QUIC.

In addition, a client can make use of QUIC's 0 RTT feature for subsequent connections
when it has already communicated with a certain server. The client can then send
(encrypted) application data even before the QUIC handshake has finished.

### QUIC native multiplexing

A single QUIC packet can include multiple frames from one or more
streams. Since QUIC packets can be decrypted even when they're received out of order, this solves the problem of HOL (head-of-line) blocking: If a packet that contains
stream data for one stream is lost, this only blocks progress on this one stream. All
other streams can still make progress.

## QUIC in libp2p

libp2p only supports bidirectional streams and uses TLS 1.3 by default.
Since QUIC already provides an encrypted, stream-multiplexed connection,
libp2p directly uses QUIC streams, without any additional framing.

To authenticate each others' peer IDs, peers encode their peer ID into a self-signed
certificate, which they sign using their host's private key. This is the same way peer
IDs are authenticated in the
[libp2p TLS handshake](https://github.com/libp2p/specs/blob/master/tls/tls.md).

{{< alert icon="💡" context="note" text="To be clear, there is no additional security handshake and stream muxer needed as QUIC provides all of this by default. This also means that establishing a libp2p connection between two nodes using QUIC only takes a single RTT." />}}

Following the multiaddress format described earlier, a standard QUIC connection will
look like: `/ip4/127.0.0.1/udp/65432/quic/`.

## References

[1] [What is HTTP/3 by Cloudspoint](https://cloudspoint.xyz/what-is-http3/)
