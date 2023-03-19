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
libp2p = {version="0.51.1", features = ["async-std", "dns", "macros", "mplex", "noise", "ping", "tcp", "websocket", "yamux"]}


```

#### Basic setup

Now that we have libp2p installed, let's configure the minimum needed to get your node running. The only modules libp2p requires are a **Transport** and **Crypto** module. However, we recommend that a basic setup should also have a **Stream Multiplexer** configured, which we will explain shortly. Let's start by setting up a Transport.

#### Transports

Libp2p uses Transports to establish connections between peers over the network. You can configure any number of Transports, but you only need 1 to start with.

You should select Transports according to the runtime target of your application. You can see a list of some of the available Transports in the [configuration readme](https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md#transport). For this guide let's install `@libp2p/tcp`.

```sh
npm install @libp2p/tcp
```

Now that we have the module installed, let's configure libp2p to use the Transport. We'll use the `createLibp2pNode` method, which takes a single configuration object as its only parameter. We can add the Transport by passing it into the `transports` array. Create a `src/index.js` file and have the following code in it:

```js
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'

const node = await createLibp2p({
  transports: [tcp()]
})

```

You can add as many transports as you like to `transports` in order to establish connections with as many peers as possible.

#### Connection Encryption

Every connection must be encrypted to help ensure security for everyone. As such, Connection Encryption (Crypto) is a required component of libp2p.

There are a growing number of Crypto modules being developed for libp2p. As those are released they will be tracked in the [Connection Encryption section of the configuration readme](https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md#connection-encryption). For now, we are going to configure our node to use the `@chainsafe/libp2p-noise` module.

```sh
npm install @chainsafe/libp2p-noise
```

```js
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'

const node = await createLibp2p({
  transports: [tcp()],
  connectionEncryption: [noise()]
})

```

#### Multiplexing

While multiplexers are not strictly required, they are highly recommended as they improve the effectiveness and efficiency of connections for the various protocols libp2p runs.

Looking at the [available stream multiplexing](https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md#stream-multiplexing) modules, js-libp2p currently only supports `@libp2p/mplex`, so we will use that here. You can install `@libp2p/mplex` and add it to your libp2p node as follows in the next example.

```sh
npm install @libp2p/mplex
```

```js
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'
import { mplex } from '@libp2p/mplex'

const node = await createLibp2p({
  transports: [tcp()],
  connectionEncryption: [noise()],
  streamMuxers: [mplex()]
})

```

#### Running libp2p

Now that you have configured a **Transport**, **Crypto** and **Stream Multiplexer** module, you can start your libp2p node. We can start and stop libp2p using the [`libp2p.start()`](https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#start) and [`libp2p.stop()`](https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#stop) methods.

```js
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'
import { mplex } from '@libp2p/mplex'

const main = async () => {
  const node = await createLibp2p({
    addresses: {
      // add a listen address (localhost) to accept TCP connections on a random port
      listen: ['/ip4/192.0.2.0/tcp/0']
    },
    transports: [tcp()],
    connectionEncryption: [noise()],
    streamMuxers: [mplex()]
  })

  // start libp2p
  await node.start()
  console.log('libp2p has started')

  // print out listening addresses
  console.log('listening on addresses:')
  node.getMultiaddrs().forEach((addr) => {
    console.log(addr.toString())
  })

  // stop libp2p
  await node.stop()
  console.log('libp2p has stopped')
}

main().then().catch(console.error)

```

Try running the code with `node src/index.js`. You should see something like:

```shell
libp2p has started
listening on addresses:
/ip4/192.0.2.0/tcp/50626/p2p/QmYoqzFj5rhzFy7thCPPGbDkDkLMbQzanxCNwefZd3qTkz
libp2p has stopped
```

### Lets play ping pong!

Now that we have the basic building blocks of transport, multiplexing, and security in place, we can start communicating!

We can use [`libp2p.ping()`](https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#ping) to dial and send ping messages to another peer. That peer will send back a "pong" message, so that we know that it is still alive. This also enables us to measure the latency between peers.

We can have our application accepting a peer multiaddress via command line argument and try to ping it. To do so, we'll need to add a couple things. First, require the `process` module so that we can get the command line arguments. Then we'll need to parse the multiaddress from the command line and try to ping it:

```sh
npm install multiaddr
```

```javascript
import process from 'node:process'
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'
import { mplex } from '@libp2p/mplex'
import { multiaddr } from 'multiaddr'

const node = await createLibp2p({
  addresses: {
    // add a listen address (localhost) to accept TCP connections on a random port
    listen: ['/ip4/192.0.2.0/tcp/0']
  },
  transports: [tcp()],
  connectionEncryption: [noise()],
  streamMuxers: [mplex()]
})

// start libp2p
await node.start()
console.log('libp2p has started')

// print out listening addresses
console.log('listening on addresses:')
node.getMultiaddrs().forEach((addr) => {
  console.log(addr.toString())
})

// ping peer if received multiaddr
if (process.argv.length >= 3) {
  const ma = multiaddr(process.argv[2])
  console.log(`pinging remote peer at ${process.argv[2]}`)
  const latency = await node.ping(ma)
  console.log(`pinged ${process.argv[2]} in ${latency}ms`)
} else {
  console.log('no remote peer address given, skipping ping')
}

const stop = async () => {
  // stop libp2p
  await node.stop()
  console.log('libp2p has stopped')
  process.exit(0)
}

process.on('SIGTERM', stop)
process.on('SIGINT', stop)

```

Now we can start one instance with no arguments:

```shell
> node src/index.js
libp2p has started
listening on addresses:
/ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN
no remote peer address given, skipping ping
```

Grab the `/ip4/...` address printed above and use it as an argument to another instance.  In a new terminal:

```shell
> node src/index.js /ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN
libp2p has started
listening on addresses:
/ip4/192.0.2.0/tcp/50777/p2p/QmYZirEPREz9vSRFznxhQbWNya2LXPz5VCahRCT7caTLGm
pinging remote peer at /ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN
pinged /ip4/192.0.2.0/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN in 3ms
libp2p has stopped
```

Success! Our two peers are now communicating over a multiplexed, secure channel.  Sure, they can only say "ping", but it's a start!

### What's next?

After finishing this tutorial, you should have a look into the [js-libp2p getting started](https://github.com/libp2p/js-libp2p/blob/master/doc/GETTING_STARTED.md) document, which goes from a base configuration like this one, to more custom ones.

You also have a panoply of examples on [js-libp2p repo](https://github.com/libp2p/js-libp2p/tree/master/examples) that you can leverage to learn how to use `js-libp2p` for several different use cases and runtimes.

[definition_multiaddress]: /reference/glossary/#multiaddr
[definition_multiplexer]: /reference/glossary/#multiplexer
[definition_peerid]: /reference/glossary/#peerid
