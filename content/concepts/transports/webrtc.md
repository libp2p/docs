---
title: "WebRTC"
description: "WebRTC is a protocol for real-time communication and is used to establish connections between browsers and other nodes."
weight: 110
aliases:
    - "/concepts/transports/webrtc"
---

## What is WebRTC?

[WebRTC (Web Real-Time Communications)](https://webrtc.org/) is a framework for real-time
communication and is used to establish browser-to-server and browser-to-browser connections
between applications. WebRTC serves as a good choice for applications that need built-in support
for media communication and do not have specific requirements for the underlying transport
protocol.

## WebRTC in libp2p

### Key features

- Peer connections: WebRTC enables [direct peer-to-peer connections](https://webrtc.org/getting-started/peer-connections)
  between browsers and other nodes.

- Data channel: WebRTC also provides peer-to-peer data channels called
  [WebRTC data channels](https://developer.mozilla.org/en-US/docs/Games/Techniques/WebRTC_data_channels),
  which works on
  [SCTP (Stream Control Transmission Protocol)](https://en.wikipedia.org/wiki/Stream_Control_Transmission_Protocol).
  A WebRTC data channel allows applications to send text or binary data over an active connection to a peer.

- [NAT traversal](../nat/overview): WebRTC includes mechanisms (like
  [ICE](https://datatracker.ietf.org/doc/rfc5245/))to connect to nodes that run behind
  NATs and firewalls. In non-decentralized WebRTC, this can be facilitated by a
  [TURN server.](https://webrtc.org/getting-started/turn-server),
  but other signaling channels, such as WebSocket running on a central server, can also be used.
  It is also possible to use a custom signaling protocol or a different signaling service.
  Overall, this allows for faster and more efficient communication.

- Security: WebRTC connections are encrypted using
  [DTLS](https://en.wikipedia.org/wiki/Datagram_Transport_Layer_Security).

Browsers expose an API to establish WebRTC connections. The
[`RTCPeerConnection`](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection)
API allows two applications on different endpoints to communicate. WebRTC enables
a node to send and receive data through the `DataChannel`.

### Browser-to-Server

libp2p WebRTC enables browsers to connect to public server nodes (and eventually,
browsers to connect to other browsers) without those endpoints providing a TLS
certificate within the browser's trustchain.

{{< alert icon="" context="info" text="When connecting to a WebSocket server, browsers require the server to present a TLS certificate signed by a trusted CA (certificate authority). Few nodes have such a certificate, which is the reason that WebSocket never saw widespread adoption in the libp2p network. WebRTC and WebTransport support encrypted communication without requiring a signed certificate from a trusted CA in the same way that WebSockets do." />}}

In libp2p:

- WebRTC multiaddresses are composed of a standard UDP multiaddr,
  followed by `webrtc` and the `multihash` of the certificate that
  the node uses, as such:
  `/ip4/1.2.3.4/udp/1234/webrtc/certhash/<hash>/p2p/<peer-id>`;
- WebRTC offers security via DTLS. Peers still need to authenticate remote peers
  by their libp2p identity.

A browser can connect to a server node without needing a trusted TLS
certificate. View [this scenario](https://github.com/libp2p/specs/blob/master/webrtc/README.md#browser-to-public-server) on browser-to-server connection establishment
in the technical specification.

In general, a server will act as an [ICE Lite](https://www.rfc-editor.org/rfc/rfc5245)
agent and binds to a UDP port waiting for incoming STUN and SCTP packets and multiplexes
based on source IP and source port.

When a browser wants to establish a WebRTC connection to a server, it instantiates
an `RTCPeerConnection`. The browser constructs the server's SDP answer locally
based on the browser's multiaddr. The browser creates a local offer via
`RTCPeerConnection.createOffer()`. A sets the same username and password on the
local offer as in the remote SDP answer.

{{< alert icon="" context="info" text="SDP (Session Description Protocol) is a protocol that is used to describe multimedia sessions. The SDP answer is a message sent by a server in response to an SDP offer from a client. The offer and answer are used to establish a session between a client and server, allowing them to exchange media." />}}

Once the browser sets the SDP offer and answer, it will send STUN requests to
the server. The browser and server then execute the DTLS handshake as part of the
standard WebRTC connection establishment. DTLS is similar to TLS but runs on an
unreliable transport instead of on top of an ordered byte stream (like TCP).

A successful DTLS handshake only provides confidentiality and integrity. Authenticity
is achieved by succeeding a [Noise handshake](../secure-comm/noise) following
the DTLS handshake.

<!-- TO ADD DIAGRAM -->

### Coming soon: Browser-to-Browser

Eventually, libp2p will have support for communication between two
browsers.

The technical specification and initial implementations of WebRTC
Browser-to-Browser connectivity is planned for release in early 2023.
Track the progress [here](https://github.com/libp2p/specs/issues/475).

<!-- TO ADD DIAGRAM -->

{{< alert icon="💡" context="note" text="See the WebRTC <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/webrtc/README.md\">technical specification</a> for more details." />}}

## Comparing WebRTC and WebTransport

In general, WebRTC was primarily built for in-browser audio and video communication,
whereas WebTransport aims to offer a general-purpose bidirectional byte-stream interface
between a browser and a server.

In terms of connectivity, WebTransport only supports client-server connections,
while WebRTC supports peer-to-peer connections. WebRTC is also more complex, as many
underlying protocols are involved in creating a connection, as opposed to WebTransport,
which only depends on QUIC.

Check out the
[WebTransport](https://connectivity.libp2p.io/#webtransport) and
[WebRTC](https://connectivity.libp2p.io/#webrtc) sections of the libp2p
connectivity site to learn more.
