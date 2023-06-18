---
title: "Introducing the Universal Connectivity Application"
description: An overview and tutorial of the Universal Connectivity application
weight: 20
---

As you may know, libp2p is implemented in different programming languages such as Go, Rust, and Javascript to name a few.
The diversity of implementations enables libp2p to run on many different runtime environments i.e. libp2p nodes can run as server nodes (on personal PCs or datacenters) (thanks to [rust-libp2p](https://github.com/libp2p/rust-libp2p) and [go-libp2p](https://github.com/libp2p/go-libp2p)) or as nodes inside the browser (thanks to [js-libp2p](https://github.com/libp2p/js-libp2p)).

Most importantly, these different libp2p nodes running on different runtime environments can all interoperate, or communicate, with one another!
This interoperability is made possible by the wide range of transport protocols supported by different the libp2p implementations.

In this guide, we will show you how browser nodes can interoperate with other browser nodes, how server nodes can interoperate with other server nodes, and how browser nodes can interoperate with server nodes.
To do this, we will go over the [universal-connectivity](https://github.com/libp2p/universal-connectivity) project: a decentralized chat application that can run in your browser and on your personal computer.
The goal of the universal-connectivity app is to demonstrate the power of libp2p's browser capabilities and show how libp2p can connect everything, everywhere, all at once!

To start off, we'll begin by building the browser based node in js-libp2p and an equivalent node that can run on your laptop using rust-libp2p.
<!-- As we go further, it'll be evident why we need to build both at once and we'll make it clear for you. -->

<!-- So without further ado, let's go right on ahead. -->

## Getting universal-connectivity working in the browser

Note: we will focus strictly on the libp2p aspects of the browser node and will not cover the details of how to build the chat application itself (i.e. how to build the React app from scratch and how its frontend works etc.)
Instead, our focus will be on how to configure libp2p for the browser app and explain what each configuration means.
Our aim is for you to extract this bit of knowledge and apply it to your own application!

### Creating and initializing js-libp2p
Lets begin with how libp2p is created and initialized in our application.

The universal-connectivity chat application is a ReactApp.
When initializing the app, we utilize [React's `useEffect` hook](https://react.dev/reference/react/useEffect), a way to [synchronize the app with an external system](https://react.dev/learn/synchronizing-with-effects), in this case, libp2p.

Here is what [the `useEffect` snippet](https://github.com/libp2p/universal-connectivity/blob/main/packages/frontend/src/context/ctx.tsx#L32) looks like:

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

Inside `useEffect` we call the async `startLibp2p()` method, which itself is actually a wrapper for the `createLibp2p()` method:


```JavaScript
export async function startLibp2p() {

  const libp2p = await createLibp2p({
    // Options
  })

  return libp2p
}
```

Our application has many options specified in `createLibp2p`, let's describe them:

### Transport Options

Central to libp2p and to our sample app are libp2p transports.
These transport protocols enable connectivity between nodes.
The transport options we've specified for our browser application (in no particular order) are WebTransport, WebSockets, WebRTC & WebRTC direct, and the Circuit Relay transport.
Please checkout the linked documentation to learn more about each.

```JavaScript
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
```

#### WebTransport
The first transport option specified is WebTransport. This is primarily specified in order to get the browser node to establish a browser-to-server connection with the go peer.
Learn more about the WebTransport transport here.

### WebSockets
The second transport option specified is WebSockets.
We have configured this ot
