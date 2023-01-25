---
title: "WebRTC"
description: "WebRTC is a protocol for real-time communication and is used to establish connections between browsers and other nodes."
weight: 110
aliases:
    - "/concepts/transports/webrtc"
---

## What is WebRTC?

[WebRTC (Web Real-Time Communications)](https://webrtc.org/) is a framework for real-time
communication and in libp2p is used to establish browser-to-server and browser-to-browser
connections between applications.

WebRTC was originally designed to make audio, video, and data
communication between browsers user-friendly and easy to implement.
It was first developed by [Global IP Solutions (or GIPS)](http://www.gipscorp.com/).
In 2011, GIPS was acquired by Google where the [W3C](https://www.w3.org/) started to work
on a standard for WebRTC.

It serves as a good choice for applications that need built-in support
for media communication and do not have specific requirements for the underlying
transport protocol.

## WebRTC in libp2p

In libp2p, WebRTC is used as a transport protocol to connect from browsers to other nodes.
However, libp2p does not make use of any of WebRTC's multimedia features.
The features employed in libp2p are:

### Key features

- Peer connections: WebRTC enables
  [direct peer-to-peer connections](https://webrtc.org/getting-started/peer-connections)
  between browsers and other nodes.

- Data channels: WebRTC provides peer-to-peer [data channels](https://developer.mozilla.org/en-US/docs/Games/Techniques/WebRTC_data_channels),
  which works on
  [SCTP (Stream Control Transmission Protocol)](https://en.wikipedia.org/wiki/Stream_Control_Transmission_Protocol) and use
  [SDP (Session Description Protocol)](https://en.wikipedia.org/wiki/Session_Description_Protocol) to negotiate the parameters
  of the data channel, such as the type of data that will be sent, the codecs that will be used to encode the data, and
  other properties.

  A WebRTC data channel allows applications to send a text or binary data over an active connection
  to a peer. This means libp2p can utilize data channels as a transport to send raw data to peers and
  enables applications to build anything they like.

- [NAT traversal](../nat/overview): WebRTC includes mechanisms (like
  [ICE](https://datatracker.ietf.org/doc/rfc5245/)) to connect to nodes that run behind
  NATs and firewalls. In non-decentralized WebRTC, this can be facilitated by a
  [TURN server.](https://webrtc.org/getting-started/turn-server),
  but other signaling channels, such as WebSocket running on a central server, can also be used.
  Using a custom [signaling protocol](https://en.wikipedia.org/wiki/Signaling_protocol) or a
  different signaling service is also possible. Overall, this allows for faster and more efficient communication.

- Security: WebRTC connections are encrypted using
  [DTLS](https://en.wikipedia.org/wiki/Datagram_Transport_Layer_Security). DTLS is similar to TLS but is
  designed to work on an unreliable transport instead of an ordered byte stream like TCP.

- Web API: Browsers expose an API to establish WebRTC connections. The
  [`RTCPeerConnection`](https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/RTCPeerConnection)
  API allows two applications on different endpoints to communicate.

### Browser-to-Server

The first use case supported by a native WebRTC transport in libp2p is browser-to-server
(as described in the [specifications](https://github.com/libp2p/specs/tree/master/webrtc#browser-to-public-server)).

libp2p WebRTC enables browsers nodes to connect to public server nodes without those
endpoints providing a [TLS certificate](https://aws.amazon.com/what-is/ssl-certificate/)
within the browser's trustchain.

{{< alert icon="" context="info">}}
"When connecting to a WebSocket server, browsers require the server to present a TLS certificate
signed by a trusted certificate authority (CA). Few libp2p nodes meet this requirement, primarily
because it's hard to get a certificate in a decentralized manner. This is the reason that WebSocket
never saw widespread adoption in the libp2p network. WebRTC
(and [WebTransport](#comparing-webrtc-and-webtransport)) supports encrypted communication without
requiring a signed certificate from a trusted CA.
{{< /alert >}}

In libp2p:

- WebRTC multiaddresses are composed of a standard UDP multiaddr,
  followed by `webrtc` and the `multihash` of the certificate that
  the node uses, as such:
  `/ip4/1.2.3.4/udp/1234/webrtc/certhash/<hash>/p2p/<peer-id>`;
- WebRTC encrypts connections using DTLS. However, an additional handshake is required to
  authenticate a peer's peer ID once the WebRTC connection has been established.
- A browser can connect to a server node without needing a trusted TLS
  certificate.

Contrary to the standard WebRTC handshake process, the browser and server do not
exchange the SDP. Instead, they employ a technique known as
[SDP munging](https://webrtc.github.io/samples/src/content/peerconnection/munge-sdp/).
This technique allows the browser node to simulate the exchange of an SDP, but in reality,
it constructs it locally using the information provided by the server node's multiaddress.

When establishing a WebRTC connection, the browser and server perform a standard DTLS
handshake as part of the connection setup. DTLS is similar to TLS but is designed to
work on an unreliable transport instead of an ordered byte stream like TCP.

Of the three primary focuses of information security, a successful DTLS handshake only
provides two: confidentiality and integrity. Authenticity is achieved by succeeding a
[Noise handshake](../secure-comm/noise) following the DTLS handshake.

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

Regarding connectivity, WebTransport only supports client-server connections,
while WebRTC supports peer-to-peer connections. WebRTC is also more complex, as many
underlying protocols are involved in creating a connection, as opposed to WebTransport,
which only depends on QUIC.

Check out the
[WebTransport](https://connectivity.libp2p.io/#webtransport) and
[WebRTC](https://connectivity.libp2p.io/#webrtc) sections of the libp2p
connectivity site to learn more.
