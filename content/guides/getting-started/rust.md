---
title: "Run a rust-libp2p node"
weight: 4
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

[//]: # (https://github.com/libp2p/rust-libp2p/blob/master/libp2p/src/tutorials/ping.rs)
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
libp2p = {version="0.51.1", features = ["noise","tcp", "yamux","mplex", "websocket", "async-std", "dns", "ping", "macros"]}
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
use libp2p::swarm::{keep_alive, NetworkBehaviour};


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


## Swarm

Now that we have a [`Transport`] and a [`NetworkBehaviour`], we need something that connects the two, allowing both to make progress.

This job is carried out by a [`Swarm`]. Put simply, a [`Swarm`] drives both a [`Transport`] and a [`NetworkBehaviour`] forward, passing commands from the [`NetworkBehaviour`] to the [`Transport`] as well as events from the [`Transport`] to the [`NetworkBehaviour`].

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

    // create swarm
    let mut swarm = Swarm::with_async_std_executor(transport, behaviour, local_peer_id);

    Ok(())

}


```

## Multiaddr

With the [`Swarm`] in place, we are all set to listen for incoming connections. We only need to pass an address to the [`Swarm`], just like for [`std::net::TcpListener::bind`]. But instead of passing an IP address, we pass a [`Multiaddr`] which is yet another core concept of libp2p worth taking a look at.

A [`Multiaddr`] is a self-describing network address and protocol stack that is used to establish connections to peers.

A good introduction to [`Multiaddr`] can be found at [docs.libp2p.io/concepts/addressing](https://docs.libp2p.io/concepts/addressing/) and its specification repository [github.com/multiformats/multiaddr](https://github.com/multiformats/multiaddr/).

Let's make our local node listen on a new socket.

This socket is listening on multiple network interfaces at the same time. For each network interface, a new listening address is created. These may change over time as interfaces become available or unavailable.

For example, in case of our TCP transport it may (among others) listen on the loopback interface (localhost) `/ip4/127.0.0.1/tcp/24915` as well as the local network `/ip4/192.168.178.25/tcp/24915`.

In addition, if provided on the CLI, let's instruct our local node to dial a remote peer.

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

    // create swarm
    let mut swarm = Swarm::with_async_std_executor(transport, behaviour, local_peer_id);


    // Tell the swarm to listen on all interfaces and a random, OS-assigned port.

    swarm.listen_on("/ip4/0.0.0.0/tcp/0".parse()?)?;

    // Dial the peer identified by the multi-address given as the second command-line argument, if any.

    if let Some(addr) = std::env::args().nth(1) {

        let remote: Multiaddr = addr.parse()?;

        swarm.dial(remote)?;

        println!("Dialed {addr}")
    }

    Ok(())

}



```

[//]: # (## Continuously polling the Swarm)

[//]: # (We have everything in place now. The last step is to drive the [`Swarm`] in)

[//]: # (a loop, allowing it to listen for incoming connections and establish an)

[//]: # (outgoing connection in case we specify an address on the CLI.)

[//]: # (```no_run)

[//]: # (use futures::prelude::*;)

[//]: # (use libp2p::swarm::{keep_alive, NetworkBehaviour, Swarm, SwarmEvent};)

[//]: # (use libp2p::{identity, ping, Multiaddr, PeerId};)

[//]: # (use std::error::Error;)

[//]: # (#[async_std::main])

[//]: # (async fn main&#40;&#41; -> Result<&#40;&#41;, Box<dyn Error>> {)

[//]: # (let local_key = identity::Keypair::generate_ed25519&#40;&#41;;)

[//]: # (let local_peer_id = PeerId::from&#40;local_key.public&#40;&#41;&#41;;)

[//]: # (println!&#40;"Local peer id: {local_peer_id:?}"&#41;;)

[//]: # (let transport = libp2p::development_transport&#40;local_key&#41;.await?;)

[//]: # (let behaviour = Behaviour::default&#40;&#41;;)

[//]: # (let mut swarm = Swarm::with_async_std_executor&#40;transport, behaviour, local_peer_id&#41;;)

[//]: # (// Tell the swarm to listen on all interfaces and a random, OS-assigned)

[//]: # (// port.)

[//]: # (swarm.listen_on&#40;"/ip4/0.0.0.0/tcp/0".parse&#40;&#41;?&#41;?;)

[//]: # (// Dial the peer identified by the multi-address given as the second)

[//]: # (// command-line argument, if any.)

[//]: # (if let Some&#40;addr&#41; = std::env::args&#40;&#41;.nth&#40;1&#41; {)

[//]: # (let remote: Multiaddr = addr.parse&#40;&#41;?;)

[//]: # (swarm.dial&#40;remote&#41;?;)

[//]: # (println!&#40;"Dialed {addr}"&#41;)

[//]: # (})

[//]: # (loop {)

[//]: # (match swarm.select_next_some&#40;&#41;.await {)

[//]: # (SwarmEvent::NewListenAddr { address, .. } => println!&#40;"Listening on {address:?}"&#41;,)

[//]: # (SwarmEvent::Behaviour&#40;event&#41; => println!&#40;"{event:?}"&#41;,)

[//]: # (_ => {})

[//]: # (})

[//]: # (})

[//]: # (})

[//]: # (/// Our network behaviour.)

[//]: # (///)

[//]: # (/// For illustrative purposes, this includes the [`KeepAlive`]&#40;behaviour::KeepAlive&#41; behaviour so a continuous sequence of)

[//]: # (/// pings can be observed.)

[//]: # (#[derive&#40;NetworkBehaviour, Default&#41;])

[//]: # (struct Behaviour {)

[//]: # (keep_alive: keep_alive::Behaviour,)

[//]: # (ping: ping::Behaviour,)

[//]: # (})

[//]: # (```)

[//]: # (## Running two nodes)

[//]: # (For convenience the example created above is also implemented in full in)

[//]: # (`examples/ping.rs`. Thus, you can either run the commands below from your)

[//]: # (own project created during the tutorial, or from the root of the rust-libp2p)

[//]: # (repository. Note that in the former case you need to ignore the `--example)

[//]: # (ping` argument.)

[//]: # (You need two terminals. In the first terminal window run:)

[//]: # (```sh)

[//]: # (cargo run --example ping)

[//]: # (```)

[//]: # (It will print the PeerId and the new listening addresses, e.g.)

[//]: # (```sh)

[//]: # (Local peer id: PeerId&#40;"12D3KooWT1As4mwh3KYBnNTw9bSrRbYQGJTm9SSte82JSumqgCQG"&#41;)

[//]: # (Listening on "/ip4/127.0.0.1/tcp/24915")

[//]: # (Listening on "/ip4/192.168.178.25/tcp/24915")

[//]: # (Listening on "/ip4/172.17.0.1/tcp/24915")

[//]: # (Listening on "/ip6/::1/tcp/24915")

[//]: # (```)

[//]: # (In the second terminal window, start a new instance of the example with:)

[//]: # (```sh)

[//]: # (cargo run --example ping -- /ip4/127.0.0.1/tcp/24915)

[//]: # (```)

[//]: # (Note: The [`Multiaddr`] at the end being one of the [`Multiaddr`] printed)

[//]: # (earlier in terminal window one.)

[//]: # (Both peers have to be in the same network with which the address is associated.)

[//]: # (In our case any printed addresses can be used, as both peers run on the same)

[//]: # (device.)

[//]: # (The two nodes will establish a connection and send each other ping and pong)

[//]: # (messages every 15 seconds.)

[//]: # ([`Multiaddr`]: crate::core::Multiaddr)

[//]: # ([`NetworkBehaviour`]: crate::swarm::NetworkBehaviour)

[//]: # ([`Transport`]: crate::core::Transport)

[//]: # ([`PeerId`]: crate::core::PeerId)

[//]: # ([`Swarm`]: crate::swarm::Swarm)

[//]: # ([`development_transport`]: crate::development_transport)

## WORK IN PROGRESS
