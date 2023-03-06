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
  [SCTP (Stream Control Transmission Protocol)](https://en.wikipedia.org/wiki/Stream_Control_Transmission_Protocol) and use [SDP (Session Description Protocol)](https://en.wikipedia.org/wiki/Session_Description_Protocol) to negotiate the parameters of the data channel.

  A WebRTC data channel allows applications to send a text or binary data over an active connection
  to a peer. This means libp2p can utilize data channels as a transport to send raw data to peers and
  enables applications to build anything they like.

- [NAT traversal](../nat/overview): WebRTC includes mechanisms (like
  [ICE](https://datatracker.ietf.org/doc/rfc5245/)) to connect to nodes that run behind
  NATs and firewalls. In non-decentralized WebRTC, this can be facilitated by a
  [TURN server.](https://webrtc.org/getting-started/turn-server),
  but other signaling channels, such as WebSocket running on a central server, can also be used.
  Using a custom [signaling protocol](https://en.wikipedia.org/wiki/Signaling_protocol) or a
  different signaling service is also possible.

- Security: WebRTC connections are encrypted using
  [DTLS](https://en.wikipedia.org/wiki/Datagram_Transport_Layer_Security). DTLS is similar to TLS but is
  designed to work on an unreliable transport instead of an ordered byte stream like TCP.

- API: Browsers expose an API to establish WebRTC connections. The
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
exchange the SDP Offer and Answer. Instead, they employ a technique known as
[SDP munging](https://webrtc.github.io/samples/src/content/peerconnection/munge-sdp/).
This technique allows the browser node to simulate the exchange of an SDP, but in reality,
it constructs it locally using the information provided by the server node's multiaddress.

When establishing a WebRTC connection, the browser and server perform a standard DTLS
handshake as part of the connection setup. Of the three primary focuses of information
security, a successful DTLS handshake only provides two: confidentiality and integrity.
Authenticity is achieved by succeeding the
[Noise handshake](../secure-comm/noise) following the DTLS handshake.

<!-- TO ADD DIAGRAM -->

### WebRTC W3C (Hole punching to achieve Browser-to-Browser connectivity)

Thanks to js-libp2p and rust-libp2p (complied to Wasm), libp2p can run in the browser environment.
However, browsers impose certain restrictions on application code (such as libp2p browser nodes).
Applications are sandboxed and face constraints on security and networking.
For instance, browsers do not permit direct access to raw network sockets.
Additionally, it's a sure bet that libp2p browser nodes will be behind a NAT/firewall.
Due to these restrictions, browser nodes cannot listen for incoming connections,
and as a result, they cannot communicate with other browser nodes.

Thankfully, libp2p solves this problem and enables browser node to browser node connectivity by supporting a transport called WebRTC W3C.

{{< alert icon="" context="info">}}
Due to the restrictions mentioned above, libp2p browser nodes are private nodes (meaning they cannot be dialed from outside of their local network).
However, in principle, this use case can be thought of not just as browser-to-browser but private node to private node.
This WebRTC solution enables connectivity between two non browser nodes behind a NAT/firewall as well
{{< /alert >}}

#### Transport Internals

The libp2p WebRTC W3C transport is enabled by supporting the [W3C defined](https://w3c.github.io/webrtc-pc/#introduction) `RTCPeerConnection` API.
This core API enables p2p connectivity and provides methods for establishing connections and transferring streams of data between peers.
Running instances of libp2p that support this transport will have `/webrtc-w3c` in their multiaddr.

However, there's more to p2p connections that what `RTCPeerConnection` provides. Crucially, signaling isn't built into the WebRTC API.
{{< alert icon="" context="info">}}
Signaling is the process of coordinating communication and exchanging metadata about the communication (i.e. initializing, closing, or reporting errors about connections).
{{< /alert >}}

For this transport, libp2p supports its own signaling protocol which has the protocol id: `webrtc-w3c-signaling`.

#### How browser-to-browser connectivity works

<!-- TO ADD DIAGRAM -->

Suppose we have three network entities:

- _Node A_ - a libp2p node running in the browser
- _Node B_ - another browser libp2p node running on a different browser instance
- _Relay R_ - a libp2p relay node

In this connectivity scenario, _A_ wants to connect to _B_.
This roughly works as follows:

- _A_ and _B_ are both connected to _R_
- _B_ appends `webrtc-w3c` to its multiaddress and that multiaddress is relayed by _R_.
- _A_ will discover _B_'s multiaddress via _R_
- _A_ sees that _B_ supports `webrtc-w3c` and establishes a relayed connection to _B_
- Over the relayed connection, _A_ will:
  - Create an _outbound_ `RTCPeerConnection`
  - Send a SDP offer via the WebRTC API
  - Initiate the `webrtc-w3c-signaling` signaling protocol via a stream
- On _B_'s end (over the same relayed connection), _B_ will
  - Receive _A_'s SDP offer sent via the signaling protocol stream
  - Create an _inbound_ `RTCPeerConnection` and provide the offer to its peer connection via the WebRTC API
  - Send an answer back to _A_ over the signaling protocol stream
- Once _A_ gets the answer from _B_, _A_ sets the session description with answer
- Via the signaling protocol stream, _A_ and _B_ now both exchange information about the network connection (in WebRTC parlance this is called [exchanging ICE candidates](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Connectivity#ice_candidates))
- After this whole process is done, there can be one of two results:
  - A successful direct connection is established between _A_ and _B_
    - In this case, both browser nodes will close the signaling protocol stream
    - The relayed connection is closed
  - A failed direction connection
    - In this case, the signaling stream is reset
    - It's important to note that libp2p does not specify transferring data over the relayed connection if the direct connection fails

{{< alert icon="" context="info">}}
As mentioned, a browser node is private and behind a NAT/firewall.
It needs to discover it's public IP address and port to send to the remote peer.
To do this, libp2p's `webrtc-w3c` solution depends on STUN servers.
STUN servers are the only way to discover ones own public IP address and port in the browser.
Public STUN servers can be used or you may choose to operate a dedicate STUN server(s) for your libp2p network.
In the above connectivity example, the browser nodes need not use the same STUN server.
{{< /alert >}}

In summary, `webrtc-w3c` makes us of the WebRTC API to establish connectivity.
It also relies on relay nodes and STUN servers to create relay connections to discover a browser node's public IP address and port.
Lastly, it uses the signaling protocol to hole punch across NATs/firewalls and establish a direct connection between two browser nodes.

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
