---
title: "WebRTC"
description: "WebRTC is a protocol for real-time communication and is used to establish connections between browsers and other nodes."
weight: 110
aliases:
    - "/concepts/transports/webrtc"
---

## What is WebRTC?

[WebRTC (Web Real-Time Communications)](https://webrtc.org/) is a framework for real-time communication
and is used to establish browser-to-server and browser-to-browser connections between applications.
WebRTC serves as a good choice for applications that need built-in support for media
communication and do not have specific requirements for the underlying transport
protocol.

### Key features for libp2p


- Peer connections: WebRTC enables [direct peer-to-peer connections](https://webrtc.org/getting-started/peer-connections)
  between browsers and other nodes through a process called [signaling](https://webrtc.org/getting-started/peer-connections#signaling).
  In non-decentralized WebRTC, this is facilitated by a [TURN server.](https://webrtc.org/getting-started/turn-server)
  This allows for faster and more efficient communication. Peers can also retrieve or consume the media and
  also produce it.

- Data channel: WebRTC also provides peer-to-peer data channels called
  [WebRTC data channels](https://developer.mozilla.org/en-US/docs/Games/Techniques/WebRTC_data_channels),
  which works on
  [SCTP (Stream Control Transmission Protocol)](https://en.wikipedia.org/wiki/Stream_Control_Transmission_Protocol).
  A WebRTC data channel allows applications to send text or binary data over an active connection to a peer.
  Data channels can be [ordered or unordered](https://developer.mozilla.org/en-US/docs/Web/API/RTCDataChannel/ordered),
  where ordered channels guarantee the message delivery order (like running on TCP), and unordered channels increase
  speed but deliver messages out of order (like UDP.)

- [NAT traversal](../nat/overview): WebRTC includes mechanisms (like
  [ICE](https://datatracker.ietf.org/doc/rfc5245/))to connect to nodes that live behind
  NATs and firewalls.

- [Security](../secure-comm/overview): WebRTC includes built-in security features, and
  connections are always encrypted by using [DTLS](https://en.wikipedia.org/wiki/Datagram_Transport_Layer_Security)
  or [SRTP](https://en.wikipedia.org/wiki/Secure_Real-time_Transport_Protocol).

WebRTC includes several APIs to help create a secure connection
over the web. The
[`RTCPeerConnection`](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection)
API allows two applications on different endpoints to communicate using a peer-to-peer protocol. WebRTC enables
a node to send and receive streams that include media content and arbitrary binary data
through the `DataChannel`.

## WebRTC in libp2p

libp2p WebRTC enables browsers to connect to public server nodes (and eventually,
browsers to connect to other browsers) without those endpoints providing a TLS
certificate within the browser's trustchain.

In libp2p:

- WebRTC multiaddresses are composed of a standard UDP multiaddr,
  followed by `webrtc` and the `multihash` of the certificate that
  the node uses, as such:
  `/ip4/1.2.3.4/udp/1234/webrtc/certhash/<hash>/p2p/<peer-id>`;
- WebRTC offers security via TLS 1.2. Peers still need to authenticate remote peers
  by their libp2p identity.
- the TLS certificate fingerprint in `/certhash` is a multibase encoded multihash;
- WebRTC can support UDP and TCP, but implementations must always support UDP.

### Browser-to-Server

A browser can connect to a server node without needing a trusted TLS
certificate. View [this example](https://github.com/libp2p/specs/blob/master/webrtc/README.md#browser-to-public-server) on browser-to-server connection establishment in the technical
specification.

In general, a server will act as an [ICE Lite](https://www.rfc-editor.org/rfc/rfc5245)
agent and binds to a UDP port waiting for incoming STUN and SCTP packets and multiplexes
based on source IP and source port. It multiplexes based on a source IP and source port.

Once a browser discovers a server's multiaddr, it instantiates an `RTCPeerConnection`.
The browser will construct the server's SDP answer locally based on the browser's multiaddr.
The browser creates a local offer via `RTCPeerConnection.createOffer()`. A sets the same
username and password on the local offer as in the remote SDP answer.

{{< alert icon="💡" context="info" text="SDP (Session Description Protocol) is a protocol that is used to describe multimedia sessions. The SDP answer is a message sent by a server in response to an SDP offer from a client. The offer and answer are used to establish a session between a client and server, allowing them to exchange media." />}}

Once the browser sets the SDP offer and answer, it will send STUN requests to
the server. The browser and server then execute the DTLS handshake as part of the standard
WebRTC connection establishment. It is similar to the TLS handshake described
[here](../secure-comm/tls##comparing-tls-1.3-to-tls-1.2), with the differences being that DTLS is
datagram-based and how the server generates session keys.

1. The browser sends a `ClientHello` message to advertise its supported cipher suites
   and other protocol options to the server.
2. The server responds with a `ServerHello` message to indicate which cipher suite
   and other options it has selected for communication.
3. The server sends its certificate along with a `ServerKeyExchange` message to the client
   that includes the necessary information for the client to generate a premaster secret.
4. The browser verifies the server's certificate and sends a `ClientKeyExchange` message,
   which contains the premaster secret encrypted using the server's public key.
5. The server decrypts the premaster secret and uses it, along with its private key, to
   generate the session keys.

A successful DTLS handshake only provides confidentiality and integrity. Authenticity is
achieved by succeeding a [Noise handshake](../secure-comm/noise) following
the DTLS handshake. Messages on each `RTCDataChannel` are framed using a message-framing
mechanism described
[here](https://github.com/libp2p/specs/blob/master/webrtc/README.md#multiplexing).

<!-- TO ADD: DIAGRAMS ONCE READY + CONTEXT -->

### Coming soon: Browser-to-Browser

Eventually, libp2p will have support for communication between two
browsers in real-time.

The technical specification and initial implementations of WebRTC
Browser-to-Browser connectivity is planned for release in early 2023.
Track the progress [here](https://github.com/libp2p/specs/issues/475).

{{< alert icon="💡" context="note" text="See the WebRTC <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/webrtc/README.md\">technical specification</a> for more details." />}}

## Comparing WebRTC and WebTransport

While WebRTC and WebTransport are both web-based approaches that enable real-time
communication between nodes, there are key differences. WebRTC supports peer-to-peer
connections, while WebTransport only supports client-server connections.

The underlying protocols in WebRTC and WebTransport are different, although both
protocols share many of the same properties. WebTransport is also an
alternative to the data channels available in WebRTC.

WebRTC is also more complex, as there are many underlying protocols involved in order
to create a connection, as opposed to WebTransport, that uses QUIC.

When connecting to a WebSocket server or when using plain TCP or QUIC connections,
browsers require the server to present a TLS certificate signed by a trusted CA
(certificate authority). Few nodes have such a certificate. One method to overcome
this is to use the [WebTransport](webtransport) browser API that offers a way to
accept a server's certificate by checking the (SHA-256) hash of the certificate.

However, a certificate is still needed, even if it is "just" self-signed.
The browser must also know the certificate hash. WebRTC can overcome this and
does not require a trusted certificate.
{{< alert icon="💡" context="note" text="While WebRTC does not require the use of trusted certificates, it does not eliminate their usage, as WebRTC relies on TLS to establish secure connections between peers and to protect the data being transferred." />}}
