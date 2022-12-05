---
title: "WebRTC"
description: "WebRTC is a protocol for real-time communication and is used to establish connections between browsers and other applications."
weight: 110
aliases:
    - "/concepts/transports/webrtc"
---

## What is WebRTC?

WebRTC (Web Real-Time Communications) is a framework for real-time communication
and is used to establish connections between browsers and other applications.
WebRTC serves as a good choice for applications that need built-in support for media
communication and do not have specific requirements for the underlying transport
protocol.

### Key features

- Audio and video support: WebRTC provides built-in support via a media stream API
  that controls the multimedia activities of a device over the data consumed. This
  allows applications to incorporate real-time audio and video streams easily.

- Peer-to-peer communication: WebRTC enables direct communication between browsers
  and other nodes without needing an intermediate server. This allows for faster
  and more efficient communication. Peers can also retrieve or consume the media and
  also produce it.

- Data channel: WebRTC provides a data channel that allows applications to transfer
  arbitrary data between peers. This works on
  [SCTP (Stream Control Transmission Protocol)](https://en.wikipedia.org/wiki/Stream_Control_Transmission_Protocol) and reduces network congestion over UDP.

- [NAT traversal](../nat/overview): WebRTC includes mechanisms (like
  [ICE](https://datatracker.ietf.org/doc/rfc5245/))to connect to nodes that live behind
  NATs and firewalls.

- [Security](../secure-comm/overview): WebRTC includes built-in security features, and
  connections are always encrypted by using [DTLS](https://en.wikipedia.org/wiki/Datagram_Transport_Layer_Security) or [SRTP](https://en.wikipedia.org/wiki/Secure_Real-time_Transport_Protocol).

WebRTC includes several APIs to help facilitate the creation of a secure connection
over the web.

The `RTCPeerConnection` API allows two applications on different
endpoints to communicate using a peer-to-peer protocol. The `PeerConnection` API
interacts closely with a `getUserMedia` API for accessing a node's media-based peripheral
device and uses the `getDisplayMedia` API to capture screen content. WebRTC allows a node
to send and receive streams that include media content and arbitrary binary data
through the `DataChannel`.

### WebRTC and WebTransport

While WebRTC and WebTransport are both web-based approaches that enable real-time
communication between nodes, there are key differences. WebRTC supports peer-to-peer
connections, while WebTransport only supports client-server connections.

The underlying protocols in WebRTC and WebTransport are different, although both
protocols share many of the same properties. WebTransport is also an
alternative to the data channels available in WebRTC.

WebRTC is also more complex, as there are many underlying protocols involved in order
to create an active transport, as opposed to WebTransport, that uses QUIC.

When connecting to a WebSocket server or when using plain TCP or QUIC connections,
browsers require the server to present a TLS certificate signed by a trusted CA
(certificate authority). Few nodes have such a certificate. One method to overcome
this is to use the [WebTransport](webtransport) browser API that offers a way to
accept a server's certificate by checking the (SHA-256) hash of the certificate.

However, a certificate is still needed, even if it is "just" self-signed.
The browser must also know the certificate hash. WebRTC can overcome this and
does not require a trusted certificate.
> While WebRTC does not require the use of trusted certificates, it does not
> eliminate their usage, as  WebRTC relies on TLS to establish secure connections
> between peers and to protect the data being transferred.

## WebRTC in libp2p

Libp2p WebRTC enables browsers to connect to public server nodes (and eventually,
browsers to connect to other browsers) without those endpoints providing a TLS
certificate within the browser's trustchain.

In libp2p:

- the `RTCPeerConnection` API allows an application to establish peer-to-peer
  communications;
- the `RTCDataChannel` API supports peer-to-peer data channels;
- a WebRTC multiaddresses are composed of a standard UDP multiaddr,
  followed by `webrtc` and the `multihash` of the certificate that
  the node uses, as such:
  `/ip4/1.2.3.4/udp/1234/webrtc/certhash/<hash>/p2p/<peer-id>`.
- The TLS certificate fingerprint in `/certhash` is a multibase encoded multihash.
- WebRTC can support UDP and TCP, but implementations must always support UDP.

### Browser-to-Server

A browser can connect to a server node without needing a trusted TLS
certificate. View [this example](https://github.com/libp2p/specs/blob/master/webrtc/README.md#browser-to-public-server) on browser-to-server connection establishment in the technical
specification for reference.

<!-- TO ADD: DIAGRAMS ONCE READY + CONTEXt -->

### Coming soon: Browser-to-Browser

Eventually, libp2p will have support for two-way communication between two
browsers in real-time.

The technical specification and initial implementations of WebRTC
Browser-to-Browser connectivity is planned for release in early 2023.
Track the progress [here](https://github.com/libp2p/specs/issues/475).

{{< alert icon="💡" context="note" text="See the WebRTC <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/webrtc/README.md\">technical specification</a> for more details." />}}
