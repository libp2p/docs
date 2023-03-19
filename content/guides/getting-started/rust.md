[//]: # (https://github.com/libp2p/rust-libp2p/blob/master/libp2p/src/tutorials/ping.rs)
---
title: "Run a rust-libp2p node"
weight: 3
description: "Learn how to run a rust-libp2p node and use the ping protocol"
aliases:
    - "/tutorials/rust"
    - "/guides"
    - "/guides/rust"
---

Check out [tutorials of the Rust libp2p implementation](https://docs.rs/libp2p/newest/libp2p/tutorials/index.html).

This is the first in a series of tutorials on working with libp2p's Rust implementation,
[js-libp2p](https://github.com/libp2p/rust-libp2p).
We will walk you through setting up a fully functional libp2p node with some basic functionality,
and finally we'll send ping messages back and forth between two peers.

### Install Rustup and Cargo

Working with rust-libp2p requires [Rust](https://www.rust-lang.org/tools/install)
Some crates may require the Nightly Rust release channel.

We recommend using the latest stable version of Rust, but anything in Stable or Nightly should work fine.
If you want to change the current channel type information can always be found at the [Rust Language Book](https://rust-lang.github.io/rustup/concepts/channels.html).

Install Rust; `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`

Change release Channel; `rustup default nightly` or `rustup default stable` followed by `rustup update`.

### Create an empty project

We need a place to put our work, so open a terminal to make a new directory for your project somewhere and set it up as an npm project:

```shell
# Cargo creates a directory for the project then we can `cd` into it
> cargo new hello-libp2p
> cd hello-libp2p

# Cargo creates a git repository for us
> git status

# Cargo initializes new projects with a Test 'helloworld', let's run that.
> cargo run
```

Side note: throughout this tutorial, we use the `>` character to indicate your terminal's shell prompt. When following along, don't type the `>` character, or you'll get some weird errors.

### Configure libp2p

libp2p is a very modular framework, which allows rust devs to target different runtime targets and opt-in to various features by including a custom selection of modules.

Because every application is different, we recommend configuring your libp2p node with just the modules you need. You can even make more than one configuration, if you want to target multiple rust runtime targets with different features.

> In a production application, it may make sense to create a separate module for your libp2p node, which will give you one place to manage the libp2p dependencies for all your javascript projects. In that case, you should not depend on `libp2p` directly in your application. Instead you'd depend on your libp2p configuration module, which would in turn depend on `libp2p` and whatever modules (transports, etc) you might need.

If you're new to libp2p, we recommend configuring your node in stages, as this can make troubleshooting configuration issues much easier. In this tutorial, we'll do just that. If you're more experienced with libp2p, you may wish to jump to the [Coding Guidelines](https://github.com/libp2p/rust-libp2p/blob/master/docs/coding-guidelines.md).

As an initial step, you should install libp2p module.

```shell
# Add the following lines to your Cargo.toml file, located in the root of the project directory.
# [dependencies]
libp2p = {version="0.51.1", features = ["noise","tcp", "yamux","mplex", "websocket", "async-std", "dns", "ping"]}
tokio = { version="1.26.0", features=["full"] }


```

#### Basic setup

Now that we have libp2p installed, let's configure the minimum needed to get your node running. Libp2p requires at minimum a **Transport** module, 'tcp', and a **Crypto** module, 'noise'. However, we recommend that a basic setup should also have a **Stream Multiplexer**, 'yamux', configured. Which we will explain shortly. Let's start by setting up a Transport.

#### PeerID for Crypto

[Peers](https://docs.libp2p.io/concepts/fundamentals/peers/) are what make up a libp2p network.
As well as serving as a unique identifier for each peer, a Peer ID is a verifiable link between a peer and its public cryptographic key.

Each libp2p peer controls a private key, which it keeps secret from all other peers. Every private key has a corresponding public key, which is shared with other peers.

Together, the public and private key (or “key pair”) allow peers to establish secure communication channels with each other.

Lets create a peer ID for our node so that we can then setup a Transport and Crypto.

```rust
use std::error::Error;
use libp2p::{identity, PeerId, tcp};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {

    // create a keypair for our peer to use.
    let local_key = identity::Keypair::generate_ed25519();

    // create a peerid from our keypair.
    let local_peer_id = PeerId::from(local_key.public());

    // print the Peer ID cryptographic hash
    println!("Local peer id: {:?}", local_peer_id);

    Ok(())
}
```

#### Transport
You should select Transports according to the runtime target of your application. You can see a list of some of the available Transports in the [rust-libp2p readme](https://github.com/libp2p/rust-libp2p/blob/master/README.md). For this guide let's use the `tcp` feature, which we have already added to our Cargo.toml file.

A transport in libp2p provides connection-oriented communication channels (e.g. TCP) as well as upgrades on top of those like authentication and encryption protocols.

Technically, a libp2p transport is anything that implements the [`Transport`] trait.

Instead of constructing a transport ourselves, for this tutorial, we use the convenience function [`development_transport`](crate::development_transport). This creates a TCP transport with [`noise`](crate::noise) for authenticated encryption.

[`development_transport`] builds a multiplexed transport, in which multiple logical substreams can coexist on the same underlying (TCP) connection.

For further details on substream multiplexing, take a look at [`crate::core::muxing`] and [`yamux`](crate::yamux).

```rust
use std::error::Error;
use libp2p::{identity, PeerId, tcp};

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {

    // create a keypair for our peer to use.
    let local_key = identity::Keypair::generate_ed25519();

    // create a peerid from our keypair.
    let local_peer_id = PeerId::from(local_key.public());

    // print the Peer ID cryptographic hash
    println!("Local peer id: {:?}", local_peer_id);

    // create TCP transport with [`noise`](crate::noise) for authenticated encryption.
    let transport = libp2p::development_transport(local_key).await?;

Ok(())
}
```

## Network behaviour

Now it is time to look at another core trait of rust-libp2p: the
[`NetworkBehaviour`]. While the previously introduced trait [`Transport`]
defines _how_ to send bytes on the network, a [`NetworkBehaviour`] defines
_what_ bytes to send on the network.

To make this more concrete, let's take a look at a simple implementation of
the [`NetworkBehaviour`] trait: the [`ping::Behaviour`](crate::ping::Behaviour).
As you might have guessed, similar to the good old `ping` network tool,
libp2p [`ping::Behaviour`](crate::ping::Behaviour) sends a ping to a peer and expects
to receive a pong in turn. The [`ping::Behaviour`](crate::ping::Behaviour) does not care _how_
the ping and pong messages are sent on the network, whether they are sent via
TCP, whether they are encrypted via [noise](crate::noise) or just in
[plaintext](crate::plaintext). It only cares about _what_ messages are sent
on the network.

The two traits [`Transport`] and [`NetworkBehaviour`] allow us to cleanly
separate _how_ to send bytes from _what_ bytes to send.

With the above in mind, let's extend our example, creating a [`ping::Behaviour`](crate::ping::Behaviour) at the end:

```rust
use std::error::Error;
use libp2p::{identity, PeerId, tcp};
use libp2p::ping;
use libp2p::swarm::keep_alive; // add ping::Behaviour import

#[derive(NetworkBehaviour, Default)]
struct Behaviour {
    keep_alive: keep_alive::Behaviour,
    ping: ping::Behaviour,
}


#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {

    // create a keypair for our peer to use.
    let local_key = identity::Keypair::generate_ed25519();

    // create a peerid from our keypair.
    let local_peer_id = PeerId::from(local_key.public());

    // print the Peer ID cryptographic hash
    println!("Local peer id: {:?}", local_peer_id);

    // create TCP transport with [`noise`](crate::noise) for authenticated encryption.
    let transport = libp2p::development_transport(local_key).await?;

    // create ping behaviour
    let behaviour = Behaviour::default();

    Ok(())

}
```
For illustrative purposes, this includes the [`KeepAlive`](behaviour::KeepAlive) behaviour so a continuous sequence of
pings can be observed.

## WORK IN PROGRESS


[//]: # ()
[//]: # (#### Multiplexing)

[//]: # ()
[//]: # (While multiplexers are not strictly required, they are highly recommended as they improve the effectiveness and efficiency of connections for the various protocols libp2p runs.)

[//]: # ()
[//]: # (Looking at the [available stream multiplexing]&#40;https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md#stream-multiplexing&#41; modules, js-libp2p currently only supports `@libp2p/mplex`, so we will use that here. You can install `@libp2p/mplex` and add it to your libp2p node as follows in the next example.)

[//]: # ()
[//]: # (```sh)

[//]: # (npm install @libp2p/mplex)

[//]: # (```)

[//]: # ()
[//]: # (```js)

[//]: # (import { createLibp2p } from 'libp2p')

[//]: # (import { tcp } from '@libp2p/tcp')

[//]: # (import { noise } from '@chainsafe/libp2p-noise')

[//]: # (import { mplex } from '@libp2p/mplex')

[//]: # ()
[//]: # (const node = await createLibp2p&#40;{)

[//]: # (  transports: [tcp&#40;&#41;],)

[//]: # (  connectionEncryption: [noise&#40;&#41;],)

[//]: # (  streamMuxers: [mplex&#40;&#41;])

[//]: # (}&#41;)

[//]: # ()
[//]: # (```)

[//]: # ()
[//]: # (#### Running libp2p)

[//]: # ()
[//]: # (Now that you have configured a **Transport**, **Crypto** and **Stream Multiplexer** module, you can start your libp2p node. We can start and stop libp2p using the [`libp2p.start&#40;&#41;`]&#40;https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#start&#41; and [`libp2p.stop&#40;&#41;`]&#40;https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#stop&#41; methods.)

[//]: # ()
[//]: # (```js)

[//]: # (import { createLibp2p } from 'libp2p')

[//]: # (import { tcp } from '@libp2p/tcp')

[//]: # (import { noise } from '@chainsafe/libp2p-noise')

[//]: # (import { mplex } from '@libp2p/mplex')

[//]: # ()
[//]: # (const main = async &#40;&#41; => {)

[//]: # (  const node = await createLibp2p&#40;{)

[//]: # (    addresses: {)

[//]: # (      // add a listen address &#40;localhost&#41; to accept TCP connections on a random port)

[//]: # (      listen: ['/ip4/192.0.2.0/tcp/0'])

[//]: # (    },)

[//]: # (    transports: [tcp&#40;&#41;],)

[//]: # (    connectionEncryption: [noise&#40;&#41;],)

[//]: # (    streamMuxers: [mplex&#40;&#41;])

[//]: # (  }&#41;)

[//]: # ()
[//]: # (  // start libp2p)

[//]: # (  await node.start&#40;&#41;)

[//]: # (  console.log&#40;'libp2p has started'&#41;)

[//]: # ()
[//]: # (  // print out listening addresses)

[//]: # (  console.log&#40;'listening on addresses:'&#41;)

[//]: # (  node.getMultiaddrs&#40;&#41;.forEach&#40;&#40;addr&#41; => {)

[//]: # (    console.log&#40;addr.toString&#40;&#41;&#41;)

[//]: # (  }&#41;)

[//]: # ()
[//]: # (  // stop libp2p)

[//]: # (  await node.stop&#40;&#41;)

[//]: # (  console.log&#40;'libp2p has stopped'&#41;)

[//]: # (})

[//]: # ()
[//]: # (main&#40;&#41;.then&#40;&#41;.catch&#40;console.error&#41;)

[//]: # ()
[//]: # (```)

[//]: # ()
[//]: # (Try running the code with `node src/index.js`. You should see something like:)

[//]: # ()
[//]: # (```shell)

[//]: # (libp2p has started)

[//]: # (listening on addresses:)

[//]: # (/ip4/192.0.2.0/tcp/50626/p2p/QmYoqzFj5rhzFy7thCPPGbDkDkLMbQzanxCNwefZd3qTkz)

[//]: # (libp2p has stopped)

[//]: # (```)

[//]: # ()
[//]: # (### Lets play ping pong!)

[//]: # ()
[//]: # (Now that we have the basic building blocks of transport, multiplexing, and security in place, we can start communicating!)

[//]: # ()
[//]: # (We can use [`libp2p.ping&#40;&#41;`]&#40;https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#ping&#41; to dial and send ping messages to another peer. That peer will send back a "pong" message, so that we know that it is still alive. This also enables us to measure the latency between peers.)

[//]: # ()
[//]: # (We can have our application accepting a peer multiaddress via command line argument and try to ping it. To do so, we'll need to add a couple things. First, require the `process` module so that we can get the command line arguments. Then we'll need to parse the multiaddress from the command line and try to ping it:)

[//]: # ()
[//]: # (```sh)

[//]: # (npm install multiaddr)

[//]: # (```)

[//]: # ()
[//]: # (```javascript)

[//]: # (import process from 'node:process')

[//]: # (import { createLibp2p } from 'libp2p')

[//]: # (import { tcp } from '@libp2p/tcp')

[//]: # (import { noise } from '@chainsafe/libp2p-noise')

[//]: # (import { mplex } from '@libp2p/mplex')

[//]: # (import { multiaddr } from 'multiaddr')

[//]: # ()
[//]: # (const node = await createLibp2p&#40;{)

[//]: # (  addresses: {)

[//]: # (    // add a listen address &#40;localhost&#41; to accept TCP connections on a random port)

[//]: # (    listen: ['/ip4/192.0.2.0/tcp/0'])

[//]: # (  },)

[//]: # (  transports: [tcp&#40;&#41;],)

[//]: # (  connectionEncryption: [noise&#40;&#41;],)

[//]: # (  streamMuxers: [mplex&#40;&#41;])

[//]: # (}&#41;)

[//]: # ()
[//]: # (// start libp2p)

[//]: # (await node.start&#40;&#41;)

[//]: # (console.log&#40;'libp2p has started'&#41;)

[//]: # ()
[//]: # (// print out listening addresses)

[//]: # (console.log&#40;'listening on addresses:'&#41;)

[//]: # (node.getMultiaddrs&#40;&#41;.forEach&#40;&#40;addr&#41; => {)

[//]: # (  console.log&#40;addr.toString&#40;&#41;&#41;)

[//]: # (}&#41;)

[//]: # ()
[//]: # (// ping peer if received multiaddr)

[//]: # (if &#40;process.argv.length >= 3&#41; {)

[//]: # (  const ma = multiaddr&#40;process.argv[2]&#41;)

[//]: # (  console.log&#40;`pinging remote peer at ${process.argv[2]}`&#41;)

[//]: # (  const latency = await node.ping&#40;ma&#41;)

[//]: # (  console.log&#40;`pinged ${process.argv[2]} in ${latency}ms`&#41;)

[//]: # (} else {)

[//]: # (  console.log&#40;'no remote peer address given, skipping ping'&#41;)

[//]: # (})

[//]: # ()
[//]: # (const stop = async &#40;&#41; => {)

[//]: # (  // stop libp2p)

[//]: # (  await node.stop&#40;&#41;)

[//]: # (  console.log&#40;'libp2p has stopped'&#41;)

[//]: # (  process.exit&#40;0&#41;)

[//]: # (})

[//]: # ()
[//]: # (process.on&#40;'SIGTERM', stop&#41;)

[//]: # (process.on&#40;'SIGINT', stop&#41;)

[//]: # ()
[//]: # (```)

[//]: # ()
[//]: # (Now we can start one instance with no arguments:)

[//]: # ()
[//]: # (```shell)

[//]: # (> node src/index.js)

[//]: # (libp2p has started)

[//]: # (listening on addresses:)

[//]: # (/ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN)

[//]: # (no remote peer address given, skipping ping)

[//]: # (```)

[//]: # ()
[//]: # (Grab the `/ip4/...` address printed above and use it as an argument to another instance.  In a new terminal:)

[//]: # ()
[//]: # (```shell)

[//]: # (> node src/index.js /ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN)

[//]: # (libp2p has started)

[//]: # (listening on addresses:)

[//]: # (/ip4/192.0.2.0/tcp/50777/p2p/QmYZirEPREz9vSRFznxhQbWNya2LXPz5VCahRCT7caTLGm)

[//]: # (pinging remote peer at /ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN)

[//]: # (pinged /ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN in 3ms)

[//]: # (libp2p has stopped)

[//]: # (```)

[//]: # ()
[//]: # (Success! Our two peers are now communicating over a multiplexed, secure channel.  Sure, they can only say "ping", but it's a start!)

[//]: # ()
[//]: # (### What's next?)

[//]: # ()
[//]: # (After finishing this tutorial, you should have a look into the [js-libp2p getting started]&#40;https://github.com/libp2p/js-libp2p/blob/master/doc/GETTING_STARTED.md&#41; document, which goes from a base configuration like this one, to more custom ones.)

[//]: # ()
[//]: # (You also have a panoply of examples on [js-libp2p repo]&#40;https://github.com/libp2p/js-libp2p/tree/master/examples&#41; that you can leverage to learn how to use `js-libp2p` for several different use cases and runtimes.)

[//]: # ()
[//]: # ([definition_multiaddress]: /reference/glossary/#multiaddr)

[//]: # ([definition_multiplexer]: /reference/glossary/#multiplexer)

[//]: # ([definition_peerid]: /reference/glossary/#peerid)
