---
title: "browser-to-browser p2p with js-libp2p"
weight: 3
description: "Learn how to use js-libp2p to establish a connection between browsers"
aliases:
  - "/tutorials/browser-to-browser"
  - "/guides/js-browser-to-browser"
---

## Introduction

In this guide, you will learn how to establish direct peer-to-peer (p2p) connections between browsers using [js-libp2p](https://github.com/libp2p/js-libp2p) and WebRTC.

Browser-to-browser connectivity is the foundation for distributed apps with a mesh topology. When combined with GossipSub, like in the [universal connectivity](https://github.com/libp2p/universal-connectivity) chat app, gives you the building blocks for peer-to-peer event-based apps with mesh topologies.

By the end of the guide, you should be familiar with the requisite libp2p and WebRTC protocols and concepts and how to use them to establish libp2p connections between browsers.

WebRTC is a set of open standards and Web APIs that enable Web apps to establish direct connectivity for audio/video conferencing and exchanging arbitrary data. Today, it is [broadly adopted by most browsers](https://caniuse.com/?search=webrtc), and powers a lot of popular web conferencing apps.

Both js-libp2p and WebRTC are quite complicated technologies due to the complex nature of peer-to-peer networking, browser standards, and security. In favor of brevity, this guide will skim over some details while linking out to relevant resources.

## Why WebRTC & libp2p

WebRTC and libp2p can be used independently of each other. This begs the question, why use the two together? The **TL;DR is that they complement each other.**

WebRTC's goal is to enable applications to establish direct connections between their users in the browser, i.e. _peer-to-peer "browser-to-browser" connectivity_.

Libp2p gives you the tools to build interoperable cross-platform peer-to-peer applications that work both on the web and as stand-alone binaries.

![](https://www.apizee.com/scripts/files/6523f1722d11f6.39197111/websockets-vs-webrtc-768x403.webp)

Direct connections are especially useful for video and audio calling, because they allow traffic, i.e. the packets, to flow directly from one peer to another without an additional network hop to a server that may be geographically far (network latency is still bound to distances and the speed of light).

However, the reality of public internet networking given routers, NAT layers, VPNs, and firewalls is such p2p connectivity is riddled with challenges. These challenges are commonly overcome by running additional infrastructure such as signaling, [STUN](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Protocols), and TURN](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Protocols) servers, some of which are standardized as part of WebRTC.

WebRTC solves peer-to-peer connectivity in the context of browsers. Libp2p expands on that with building blocks for building peer-to-peer apps that support WebRTC in addition to [other protocols, such as QUIC, WebTransport](https://connectivity.libp2p.io/). It can be thought of as a super-category of WebRTC.

As an example, every peer in libp2p is identified by a keypair known as a [Peer ID](https://docs.libp2p.io/concepts/fundamentals/peers/). Each Peer can have multiple addresses depending on the transport protocols it can be dialed with, e.g. WebRTC in the browser.

## Peer-to-peer connections: when two aren't enough to tango

Perhaps the most important thing to note about WebRTC and the connection flow is that you need additional server(s) to establish a direct connection between two browsers.
The role of these servers is to assist the two browsers in discovering their public IP address so that they can set up a direct connection.

Specifically, these include:

- **STUN** server: helps the browser discover its observed public address and is necessary in almost all cases, due to NAT making it hard for a browser to know its observed public IP. There are many [free public STUN servers](https://gist.github.com/mondain/b0ec1cf5f60ae726202e) that you can use.
- **TURN** (Relay) server: relays traffic if the browsers fail to establish a direct connection and is defined as part of the WebRTC specification. Unlike signaling and STUN servers can be costly to run because they route all traffic between peers. This guide will not use TURN servers. Instead, it will lean on GossipSub to ensure delivery of messages when direct connections cannot be established.
- **signaling**: helps the browsers exchange their [SDPs (Session Description Protocol)](https://developer.mozilla.org/en-US/docs/Glossary/SDP): the metadata necessary to establish a connection. Most importantly, signaling is not part of the WebRTC specification. This means that applications are free to implement signaling as they see fit. In this guide, you will use Libp2p's [protocol for signaling](https://github.com/libp2p/specs/blob/master/webrtc/webrtc.md#signaling-protocol) over Circuit Relay v2 connections.
- **Libp2p relay/bootstrapper**: The libp2p peer will serve two roles:
  - **Circuit Relay V2**: A publicly reachable libp2p peer that can serve as a relay between browser nodes that have yet to establish a direct connection between each other. Unlike TURN servers, which are WebRTC-specific and can be costly to run, Circuit Relay V2 is a libp2p protocol that is resource-constrained by design. It's also decentralized and trustless, in the sense that any publicly reachable libp2p peer supporting the protocol can help browsers libp2p nodes as a (time and bandwidth-constrained) relay.
  - **GossipSub Peer Discovery**: For browser peers to discover each other, they will need some mechanism to announce their multiaddresses to other browsers. GossipSub will help by relaying those peer discovery messages between browsers which kick off the direct connection establishment.

In summary, as part of this guide, you will need to run a publicly reachable long-running libp2p peer that will serve as both a circuit relay and a GossipSub message relay. This guide will refer to the libp2p peer as the **bootstrapper** or **relay** peer depending on the context.

## Connection flow diagram

The following diagram visualizes the connection flow between two browsers using js-libp2p and WebRTC:

![WebRTC connection flow diagram](/webrtc-diagram.svg)

The connection flow can seem complex, but thankfully, libp2p abstracts some of that complexity, and whatever isn't will be explained by this guide.

Either way, there are several noteworthy things about the connection flow:

1. There's no prescribed mechanism in libp2p for how the two browsers discover each other's multiaddress. This guide will use a [dedicated GossipSub channel for the application where you publish your own multiaddrs (periodically) similar to mdns](https://github.com/libp2p/js-libp2p-pubsub-peer-discovery/), other approaches include the [Rendezvous Protocol](https://github.com/libp2p/specs/blob/master/rendezvous/README.md) and the [in-progress ambient peer discovery spec](https://github.com/libp2p/specs/pull/590).
1. Since this guide uses a GossipSub channel for peer discovery, the bootstrapper/relay node will listen to the discovery topic too, so that it can relay messages between browsers who've yet to establish a direct connection.

## Pre-requisites

- [Go](https://go.dev/doc/install) compiler to compile and run the bootstrapper. Ensure your Go version is at least 1.20.
- [Node.js](https://nodejs.org/en) installed to build the frontend

This guide assumes a basic understanding of libp2p concepts such as:

- Peer IDs
- Multiaddresses
- Libp2p transports

Besides that, you will primarily need to know JavaScript and basic Golang (though Go knowledge isn't strictly necessary, it's useful).

## Step 1: Clone the repository and install dependencies

Clone the repository:

```bash
git clone https://github.com/libp2p/libp2p-browser-guide
```

Once the repository is cloned, enter the `libp2p-browser-guide` folder, and install the npm dependencies

```
cd libp2p-browser-guide
npm install
```

Once installed, go into the `bootstrapper` directory and install dependencies

```
cd bootstrapper
go get .
```

## Step 2: Start the bootstrapper

From the `bootstrapper` folder, run the following command to compile and run the bootstrapper:

```bash
go run .
```

This will compile and run the bootstrapper. It will also output the PeerID and the multiaddrs it's listening on and should look similar to:

```
2024/05/21 17:43:43 PeerID: 12D3KooWMEZEwzATAoXFbPmb1kgD7p4Ue3jzHGQ8ti2UrsFg11YJ
2024/05/21 17:43:43 Listening on: /ip4/127.0.0.1/udp/9095/quic-v1/p2p/12D3KooWMEZEwzATAoXFbPmb1kgD7p4Ue3jzHGQ8ti2UrsFg11YJ
2024/05/21 17:43:43 Listening on: /ip4/127.0.0.1/udp/9095/quic-v1/webtransport/certhash/uEiAbhhQxJeJ6nAWdpB6NdSV4UPaTwEcy9eA76p22SoKyvg/certhash/uEiBTPUrn6BebjshxC80Uarqi4ZsMhrPPQNu2RDu1N4n_Ww/p2p/12D3KooWMEZEwzATAoXFbPmb1kgD7p4Ue3jzHGQ8ti2UrsFg11YJ
2024/05/21 17:43:43 Listening on: /ip4/192.168.3.174/udp/9095/quic-v1/p2p/12D3KooWMEZEwzATAoXFbPmb1kgD7p4Ue3jzHGQ8ti2UrsFg11YJ
2024/05/21 17:43:43 Listening on: /ip4/192.168.3.174/udp/9095/quic-v1/webtransport/certhash/uEiAbhhQxJeJ6nAWdpB6NdSV4UPaTwEcy9eA76p22SoKyvg/certhash/uEiBTPUrn6BebjshxC80Uarqi4ZsMhrPPQNu2RDu1N4n_Ww/p2p/12D3KooWMEZEwzATAoXFbPmb1kgD7p4Ue3jzHGQ8ti2UrsFg11YJ
```

Note that it's listening on two interfaces (the loopback and the private network) and two transports: QUIC and WebTransport (which is on top of QUIC). QUIC can be used for connections to other go-libp2p bootstrappers, while WebTransport for connections from browsers. That means that QUIC isn't strictly necessary, but it's useful, if you deploy another bootstrapper for resilience or leverage the DHT for peer discovery (covered later).

Another thing worth noting is that the WebTransport multiaddr contains two certificate hashes. These are needed by the browser to verify a self-signed certificate of the go-libp2p bootstrapper peer. So why two certificate hashes? The reason is that self-signed certificates are valid for at most 14 days. So by convention, go-libp2p generates two consecutively valid certificates to ensure a smooth transition when the new certificate is rolled out.

## Step 2: Starting the js-libp2p peer in the browser

In this step, you will start the js-libp2p peer in the browser and learn about how the js-libp2p configuration options.

Start by opening the `src/index.js` file in your code editor and find the call to `createLibp2p`:

```js
const libp2p = await createLibp2p({
  transports: [
    webTransport(),
    webRTC({
      rtcConfiguration: {
        iceServers: [
          {
            // STUN servers help the browser discover its own public IPs
            urls: ['stun:stun.l.google.com:19302', 'stun:global.stun.twilio.com:3478'],
          },
        ],
      },
    }),
  ],
  connectionEncryption: [noise()],
  connectionGater: {
    // Allow private addresses for local testing
    denyDialMultiaddr: async () => false,
  },
  services: {
    identify: identify(),
  },
})
```

The `createLibp2p` invokcation creates a libp2p peer which has its own associated key pair and PeerID with support for the WebTransport and WebRTC transports, as well as the [identify](TODO) protocol. It also uses noise for to ensure that all connections are encrypted.

This is the the minimal configuration needed in order to establish a connection to the local bootstrapper. In the next step, you will use the frontend to connect to the bootstrapper.

## Step 3: Connecting to a bootstrapper from a browser

In this step, you will connect the browser js-libp2p peer to the go-libp2p bootstrapper peer.

In a new terminal window, open the repository cloned in the previous step:
```
cd libp2p-browser-guide
```

Run the following command to start the development server:

```
npm run start
```

You should see the address of the local development server:

```
 > Local:   http://127.0.0.1:8000/
```

## connectivity notes (could be redacted)

Connectivity between the Browser and Bootstrapper is constrained by supported transports of the browser and the specific libp2p implementation.

At the time of writing, js-libp2p connectivity between node.js and the browser is constrained to:

1.  WebSockets: this works well and is broadly adopted by browsers and libp2p implementations, but requires the bootstrapper to have CA signed TLS certificate and a domain name to work in [Secure Contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts).
2.  WebTransport: Supported by [Chrome, Firefox and Opera](https://caniuse.com/webtransport), but not Safari. Currently, only
3.  WebRTC: this one is rather confusing because [unlike](https://github.com/libp2p/js-libp2p/tree/main/packages/transport-webrtc#webrtc-vs-webrtc-direct) [WebRTC direct](https://github.com/libp2p/specs/blob/master/webrtc/webrtc-direct.md), it requires a third party for the handshake which complicates matters too much.
