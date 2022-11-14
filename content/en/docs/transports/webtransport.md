---
title: "WebTransport"
weight: 4
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
summary: WebTransport is a new specification that uses QUIC to offer an alternative to WebSocket. Conceptually, it can be considered WebSocket over QUIC.Learn about WebTransport and how it is used in libp2p.
---

While browsers perform HTTP request using HTTP/3, so far they don't offer an API to allow 
applications to gain access to the underlying QUIC stream.
WebTransport is a new specification that uses QUIC to offer an alternative to
WebSocket. Conceptually, it can be considered WebSocket over QUIC. 
It allows browsers to establish a stream-multiplexed and bidirectional connection 
to servers, and use streams to send and receive application data.

While WebSocket provides a single bidirectional, full-duplex communication between a 
browser and a server over a TCP connection, WebTransport exposes allows the endpoints to use multiple
streams in parallel.

When connecting to a WebSocket server, browsers require the server to present a
TLS certificate signed by a trusted CA (certificate authority). Few nodes have such
a certificate, which is the reason that WebSocket never saw widespread adoption in the
libp2p network. libp2p WebTransport offers a browser API that includes a way to 
accept the server's certificate by checking the (SHA-256) hash of the certificate 
(using the 
[`serverCertificateHashes` option](https://www.w3.org/TR/webtransport/#dom-webtransportoptions-servercertificatehashes)), 
even if the certificate is "just" a self-signed certificate. This allows us to connect 
any browser node to any server node, as long as the browser knows the certificate hash in 
advance (see [WebTransport in libp2p](#webtransport-in-libp2p) for how WebTransport addresses 
achieve this).

Therefore, WebTransport exhibits all the advantages of QUIC over TCP, that being 
faster handshakes, no HoL blocking, and being future-proof.

<!-- ADD NOTICE -->
There is an experimental WebTransport transport in go-libp2p that is part 
of the [v0.23 release](https://github.com/libp2p/go-libp2p/releases/tag/v0.23.0). 
The implementation should be used experimentally and is not recommended for production 
environments.

js-libp2p also plans to release 
[WebTransport support](https://github.com/libp2p/js-libp2p-webtransport) very soon.

There are currently no concrete plans to support WebTransport beyond the Go and JS 
implementations.

<!-- ends -->

For network stacks like libp2p, WebTransport is a pluggable
protocol that fits well with a modular network design.

For a standard WebSocket connection, the roundtrips required are as follows:

- 1 RTT for TCP handshake
- 1 RTT for TLS 1.3 handshake
- 1 RTT for WebSocket upgrade
- 1 RTT for multistream security negotiation (Noise or TLS 1.3)
- 1 RTT for security handshake (Noise or TLS 1.3)
- 1 RTT for multistream muxer negotiation (mplex or yamux)

In total, 6 RTTs.

WebTransport running over QUIC only requires 3 RTTs, as:

- 1 RTT for QUIC handshake
- 1 RTT for WebTransport handshake
- 1 RTT for libp2p handshake; one for multistream and one for authentication 
  (with a Noise handshake)

In principle, the WebTransport protocol would even allow running the WebTransport 
handshake and the Noise handshake in parallel. However, this is currently not 
possible since the [browser API doesn't allow that yet](https://github.com/w3c/webtransport/issues/409).

### WebTransport in libp2p

WebTransport multiaddresses are composed of a QUIC multiaddr, followed 
by `/webtransport` and a list of multihashes of the node certificates that the server uses.

For instance, for multiaddress `/ip4/127.0.0.1/udp/123/quic/webtransport/certhash/<hash1>`, 
a standard local QUIC connection is defined up until and including `/quic.` 
Then, `/webtransport/` runs over QUIC. The self-signed certificate hash that the 
server will use to verify the connection.

The WebTransport CONNECT request is sent to an HTTPS endpoint. libp2p WebTransport server use
`/.well-known/libp2p-webtransport`. For instance, the WebTransport URL of a WebTransport 
server advertising `/ip4/1.2.3.4/udp/1234/quic/webtransport/` would be 
`https://1.2.3.4:1234/.well-known/libp2p-webtransport?type=noise` 
(the ?type=noise refers to the authentication scheme using Noise).
