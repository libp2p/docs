---
title: "Run a js-libp2p node"
weight: 3
description: "Learn how to run a js-libp2p node and use the ping protocol"
aliases:
    - "/tutorials/javascript"
    - "/guides"
    - "/guides/javascript"
---

This is the first in a series of tutorials on working with libp2p's javascript implementation,
[js-libp2p](https://github.com/libp2p/js-libp2p).
We will walk you through setting up a fully functional libp2p node with some basic functionality,
and finally we'll send ping messages back and forth between two peers.

### Install node.js

Working with js-libp2p requires [node.js](https://nodejs.org) >= v16 for development. If you haven't already, install
node using whatever package manager you prefer or [using the official installer](https://nodejs.org/en/download/).
We recommend using the latest stable version of node, but anything fairly recent should work fine. If you want to see how low you can go, the current version requirements can always be found at the [js-libp2p project page](https://github.com/libp2p/js-libp2p).

### Create an empty project

We need a place to put our work, so open a terminal to make a new directory for your project somewhere and set it up as an npm project:

```shell
# create a directory for the project and `cd` into it
> mkdir hello-libp2p
> mkdir hello-libp2p/src
> cd hello-libp2p

# make it a git repository
> git init .

# make it an npm project. fill in the prompts with info for your project
# when asked for your project's entry point, enter "src/index.js"
> npm init es6
```

Side note: throughout this tutorial, we use the `>` character to indicate your terminal's shell prompt. When following along, don't type the `>` character, or you'll get some weird errors.

### Configure libp2p

libp2p is a very modular framework, which allows javascript devs to target different runtime environments and opt-in to various features by including a custom selection of modules.

Because every application is different, we recommend configuring your libp2p node with just the modules you need. You can even make more than one configuration, if you want to target multiple javascript runtimes with different features.

> In a production application, it may make sense to create a separate npm module for your libp2p node, which will give you one place to manage the libp2p dependencies for all your javascript projects. In that case, you should not depend on `libp2p` directly in your application. Instead you'd depend on your libp2p configuration module, which would in turn depend on `libp2p` and whatever modules (transports, etc) you might need.

If you're new to libp2p, we recommend configuring your node in stages, as this can make troubleshooting configuration issues much easier. In this tutorial, we'll do just that. If you're more experienced with libp2p, you may wish to jump to the [Configuration readme](https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md).

As an initial step, you should install libp2p module.

```shell
npm install libp2p
```

#### Basic setup

Now that we have libp2p installed, let's configure the minimum needed to get your node running. The only modules libp2p requires are a **Transport** and **Crypto** module. However, we recommend that a basic setup should also have a **Stream Multiplexer** configured, which we will explain shortly. Let's start by setting up a Transport.

#### Transports

Libp2p uses Transports to establish connections between peers over the network. You can configure any number of Transports, but you only need 1 to start with.

You should select Transports according to the runtime of your application; Node.js or the browser. You can see a list of some of the available Transports in the [configuration readme](https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md#transport). For this guide let's install `@libp2p/tcp`.

```sh
npm install @libp2p/tcp
```

Now that we have the module installed, let's configure libp2p to use the Transport. We'll use the `createLibp2p` method, which takes a single configuration object as its only parameter. We can add the Transport by passing it into the `transports` array. Create a `src/index.js` file and have the following code in it:

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
  connectionEncrypters: [noise()]
})

```

#### Multiplexing

While multiplexers are not strictly required, they are highly recommended as they improve the effectiveness and efficiency of connections for the various protocols libp2p runs.

Looking at the [available stream multiplexing](https://github.com/libp2p/js-libp2p/blob/master/doc/CONFIGURATION.md#stream-multiplexing) modules, js-libp2p supports `@chainsafe/libp2p-yamux` and `@libp2p/mplex`, but [mplex](https://docs.libp2p.io/concepts/multiplex/mplex/) is [deprecated](https://github.com/libp2p/specs/issues/553) so we will use [Yamux]([https://github.com/hashicorp/yamux/blob/master/spec.md](https://docs.libp2p.io/concepts/multiplex/yamux/)) here. You can install `@chainsafe/libp2p-yamux` and add it to your libp2p node as follows in the next example.

```sh
npm install @chainsafe/libp2p-yamux
```

```js
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'
import { yamux } from '@chainsafe/libp2p-yamux'

const node = await createLibp2p({
  transports: [tcp()],
  connectionEncrypters: [noise()],
  streamMuxers: [yamux()]
})

```

#### Running libp2p

Now that you have configured a **Transport**, **Crypto** and **Stream Multiplexer** module, you can start your libp2p node. We can start and stop libp2p using the [`libp2p.start()`](https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#start) and [`libp2p.stop()`](https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#stop) methods.

```js
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'
import { yamux } from '@chainsafe/libp2p-yamux'

const main = async () => {
  const node = await createLibp2p({
    addresses: {
      // add a listen address (localhost) to accept TCP connections on a random port
      listen: ['/ip4/127.0.0.1/tcp/0']
    },
    transports: [tcp()],
    connectionEncrypters: [noise()],
    streamMuxers: [yamux()]
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

We can configure and use [`pingService`](https://libp2p.github.io/js-libp2p/modules/ping.html) to dial and send ping messages to another peer. That peer will send back a "pong" message, so that we know that it is still alive. This also enables us to measure the latency between peers.

We can have our application accepting a peer multiaddress via command line argument and try to ping it. To do so, we'll need to add a couple things. First, require the `process` module so that we can get the command line arguments. Then we'll need to parse the multiaddress from the command line and try to ping it:

```sh
npm install multiaddr @libp2p/ping
```

```javascript
import process from 'node:process'
import { createLibp2p } from 'libp2p'
import { tcp } from '@libp2p/tcp'
import { noise } from '@chainsafe/libp2p-noise'
import { yamux } from '@chainsafe/libp2p-yamux'
import { multiaddr } from 'multiaddr'
import { ping } from '@libp2p/ping'

const node = await createLibp2p({
  addresses: {
    // add a listen address (localhost) to accept TCP connections on a random port
    listen: ['/ip4/127.0.0.1/tcp/0']
  },
  transports: [tcp()],
  connectionEncrypters: [noise()],
  streamMuxers: [yamux()],
  services: {
    ping: ping({
      protocolPrefix: 'ipfs', // default
    }),
  },
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
  const latency = await node.services.ping.ping(ma)
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
```

Success! Our two peers are now communicating over a multiplexed, secure channel.  Sure, they can only say "ping", but it's a start!

### What's next?

After finishing this tutorial, you should have a look into the [js-libp2p getting started](https://github.com/libp2p/js-libp2p/blob/master/doc/GETTING_STARTED.md) document, which goes from a base configuration like this one, to more custom ones.

A range of examples are available in the [js-libp2p-examples repo](https://github.com/libp2p/js-libp2p-examples) for you to learn how to use `js-libp2p` for several different use cases and runtimes.

[definition_multiaddress]: /reference/glossary/#multiaddr
[definition_multiplexer]: /reference/glossary/#multiplexer
[definition_peerid]: /reference/glossary/#peerid
