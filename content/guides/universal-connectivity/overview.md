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

# Getting universal-connectivity working in the browser

Note: we will focus strictly on the libp2p aspects of the browser node and will not cover the details of how to build the chat application itself (i.e. how to build the React app from scratch and how its frontend works etc.)
Instead, our focus will be on how to configure libp2p for the browser app and explain what each configuration means.
Our aim is for you to extract this bit of knowledge and apply it to your own application!

## Creating and initializing js-libp2p
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

#### Browser to server connectivity
##### WebTransport
The first transport option specified is WebTransport.
This is primarily specified in order to get the browser node to establish a browser-to-server connection with the go peer.
Today only js-libp2p and go-libp2p support WebTransport.
Learn more about the WebTransport transport here.

```JavaScript
transports: [
  webTransport()
]
```

##### WebRTC Direct
The second and third transport options we specify are for `webRTCDirect` and for `webRTC`:

```JavaScript
transports: [
  webRTCDirect()
]
```

The `webRTCDirect` transport enables browser to server connections i.e. it enables the browser node to connect with server nodes that also support `webRTCDirect`.
Today, apart from js-libp2p, only rust-libp2p supports the WebRTC direct transport.
In terms of establishing browser to server connections, it is similar to WebTransport.
Therefore, enabling both WebTransport and WebRTC direct is important for our browser app if we want to make direct connections from the browser to a go-libp2p peer or a rust-lib2p peer.
To learn more about WebRTC direct, please go here.

#### Browser to browser connectivity

##### WebRTC

The `webRTC` transport serves a different purpose.
This transport enables browser nodes to make direct connections with other browser nodes.
You can learn more about how this direct connectivity is established in the docs.

```JavaScript
transports: [
  webRTC({
    rtcConfiguration: {
      iceServers:[{
        urls: [
          'stun:stun.l.google.com:19302',
          'stun:global.stun.twilio.com:3478'
        ]
      }]
    }
  })
]
```
As mentioned in the documentation, browser nodes do not have their public IP address at their disposal.
To learn their public IP address, they must get that information from a STUN server.
Here you can see that we provide the addresses of public STUN servers (one operated by Google, another by Twilio) as configuration options to the `webRTC` transport.
Note: two different browser nodes may use different STUN servers.

##### Circuit Relay

Configuring `webRTC` is not quite enough to establish direct connections with other browser peers.
Before two browser peers can establish a direct connection, they must first establish a relayed connection.
Learn more about how circuit relay works here and how it works in the context of WebRTC browser-to-browser here.

In our `transports` configuration, we can enable Circuit Relay like so:

```JavaScript
transports: [
  circuitRelayTransport({
    discoverRelays: 1,
  })
]
```

By default, our application only makes use of one circuit relay, therefore, we have set `discoverRelays` to `1`.

The relay node that we use in our application is the rust peer.
In the rust-peer section, we'll discuss more on how to set it up as a relay node that can be used by other libp2p nodes in your network.


#### Summarizing the Transports

With that, our complete list of transporst for the browser node looks like:

```JavaScript
transports: [
  webTransport(),
  webRTCDirect(),
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
  circuitRelayTransport({
    discoverRelays: 1,
  })
]
```

In summary:
- WebTransport enables us to make browser to server connections with go-libp2p peers
- WebRTC Direct enables us to make browser to server connections with rust-libp2p peers
- WebRTC enables us to make direct browser to browser connections
- Circuit Relay is enables us to make connections to relay nodes on the network and helps set up the WebRTC browser-to-browser connections


### Peer Discovery

Transport protocols give our application the ability to connect and send data across runtime environments (i.e. browser to server and browser to browser).
However, we still need the ability to discover peers on the network.
So the next configurations we provide to `createLibp2p` are those for peer discovery.

#### Bootstrap

The first of these is the `peerDiscovery` option to specify a a list of `bootstrap` nodes.
To learn more about the bootstrapping process, please refer to this doc.

```
peerDiscovery: [
  bootstrap({
    list: [
      WEBRTC_BOOTSTRAP_NODE,
      WEBTRANSPORT_BOOTSTRAP_NODE,
    ],
  }),
]
```

This is a list of multiaddrs and here we provide two variables:
- `WEBRTC_BOOTSTRAP_NODE`: the multiaddr for a peer that we make a `webRTCDirect` connection with.
- `WEBTRANSPORT_BOOTSTRAP_NODE`: the multiaddr for a peer that we make a `webTransport` connection with





- An example of a local multiaddr is `/ip4/127.0.0.1/udp/9090/webrtc-direct/certhash/uEiBy_U1UNQ0IDvot_PKlQM_QeU3yx-zCAVaMxxVm2JxWBg/p2p/12D3KooWSFfVyasFDa4NBQMzTmzSQBehUV92Exs9dsGjr9DL5TS3`
- An example of a local multiaddr is `/ip4/127.0.0.1/udp/9095/quic-v1/webtransport/certhash/uEiAvY5RHCUKqnnCRWnFs0S0AGP76-hifxZMLA8FjskcAvQ/certhash/uEiABdqm3hcMoQ6_NoDB6drEJLRgIX-lQ_0f-IGDH7ESPfA/p2p/12D3KooWEMhCiXfgYuo6kzep7F5gLbj8rGnncSxvS8zShKgeEnGS`