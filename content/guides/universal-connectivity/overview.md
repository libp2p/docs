---
title: "Introducing the Universal Connectivity Application"
description: An overview and tutorial of the Universal Connectivity application
weight: 20
---

As you may know, libp2p is implemented in different programming languages such as Go, Rust, and Javascript to name a few.
The diversity of implementations enables libp2p to run on many different runtime environments i.e. libp2p nodes can run as server nodes (on personal PCs or datacenters) thanks to [rust-libp2p](https://github.com/libp2p/rust-libp2p) and [go-libp2p](https://github.com/libp2p/go-libp2p) or as browser nodes (within the browser) thanks to [js-libp2p](https://github.com/libp2p/js-libp2p).

Most importantly, these different libp2p nodes running on different runtime environments can all interoperate, or communicate, with one another!
This interoperability is made possible by the wide range of transport protocols supported by different the libp2p implementations.

In this guide, we will show you how browser nodes can interoperate with other browser nodes, how server nodes can interoperate with other server nodes, and how browser nodes can interoperate with server nodes.
To do this, we will go over the [universal-connectivity](https://github.com/libp2p/universal-connectivity) project: a decentralized chat application that can run in your browser and on your personal computer.
The goal of the universal-connectivity app was to demonstrate the power of libp2p's browser capabilities and show how libp2p can connect everything, everywhere, all at once!

To start off, we'll begin by building the browser based node in js-libp2p and an equivalent node that can run on your laptop using rust-libp2p.
As we go further, it'll be evident why we need to build both at once and we'll make it clear for you.

So without further ado, let's go right on ahead.

## Getting universal-connectivity working in the browser

Note: we will focus strictly on the libp2p aspects of the browser node and will not cover the details of how to build the chat application itself (i.e. how to build the React app from scratch and how it's frontend works etc.) Instead, our focus will be on how we configure js-libp2p, what each configuration means and so that you can extract this bit of knowledge and apply it to your own application.

### Creating and initializing js-libp2p
Lets begin with how libp2p is created and initialized in our application.

The universal-connectivity chat application is a ReactApp.
When initializing the application, we utilize [React's `useEffect` hook](https://react.dev/reference/react/useEffect), which is a way to [synchronize our application with an external system](https://react.dev/learn/synchronizing-with-effects), in this case, libp2p.

Here is what [the snippet](https://github.com/libp2p/universal-connectivity/blob/main/packages/frontend/src/context/ctx.tsx#L32) looks like:

```JavaScript
  useEffect(() => {
    const init = async () => {
      if (loaded) return
      try {
        loaded = true
        const libp2p = await startLibp2p()

        // @ts-ignore
        window.libp2p = libp2p

        setLibp2p(libp2p)
      } catch (e) {
        console.error('failed to start libp2p', e)
      }
    }

    init()
  }, [])
```

As you can see, inside `useEffect` we call the async `startLibp2p()` method.
Let's take a look at what `startLibp2p()` does.


```JavaScript
export async function startLibp2p() {
  // localStorage.debug = 'libp2p*,-*:trace'
  // application-specific data lives in the datastore

  const libp2p = await createLibp2p({
    addresses: {
      listen: [
        '/webrtc'
      ]
    },
    transports: [
      webTransport(),
      webSockets({
        filter: filters.all,
      }),
      webRTC({
        rtcConfiguration: {
          iceServers:[{
            urls: [
              'stun:stun.l.google.com:19302',
              'stun:global.stun.twilio.com:3478'
            ]
          }]
        }
      }),
      webRTCDirect(),
      circuitRelayTransport({
        discoverRelays: 1,
      })
    ],
    connectionManager: {
      maxConnections: 10,
      minConnections: 5
    },
    connectionEncryption: [noise()],
    streamMuxers: [yamux()],
    connectionGater: {
      denyDialMultiaddr: async () => false,
    },
    peerDiscovery: [
      bootstrap({
        list: [
          WEBRTC_BOOTSTRAP_NODE,
          WEBTRANSPORT_BOOTSTRAP_NODE,
        ],
      }),
    ],
    services: {
      pubsub: gossipsub({
        allowPublishToZeroPeers: true,
        msgIdFn: msgIdFnStrictNoSign,
        ignoreDuplicatePublishError: true,
      }),
      dht: kadDHT({
        protocolPrefix: "/universal-connectivity",
        maxInboundStreams: 5000,
        maxOutboundStreams: 5000,
        clientMode: true,
      }),
      identify: identifyService()
    }
  })

  libp2p.services.pubsub.subscribe(CHAT_TOPIC)

  libp2p.addEventListener('self:peer:update', ({detail: { peer }}) => {
    const multiaddrs = peer.addresses.map(({ multiaddr }) => multiaddr)

    console.log(`changed multiaddrs: peer ${peer.id.toString()} multiaddrs: ${multiaddrs}`)
  })

  return libp2p
}
```