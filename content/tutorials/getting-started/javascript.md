---
title: "Getting Started with js-libp2p"
menuTitle: "Javascript"
weight: 2
---

This is the first in a series of tutorials on working with libp2p's javascript implementation, [js-libp2p](https://github.com/libp2p/js-libp2p).

We'll cover setting up an empty project, creating a libp2p "bundle" with some basic functionality, and finally we'll send ping messages back and forth between two peers.

<!--more-->

<!--
TODO(yusef): put full example code on github and link to it here
 -->

## Install node.js

Working with js-libp2p requires [node.js](https://nodejs.org) for development. If you haven't already, install node using whatever package manager you prefer or [using the official installer](https://nodejs.org/en/download/).

We recommend using the latest stable version of node, but anything fairly recent should work fine. If you want to see how low you can go, the current version requirements can always be found at the [js-libp2p project page](https://github.com/libp2p/js-libp2p).

## Create an empty project

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
> npm init
```

Side note: throughout this tutorial, we use the `> ` character to indicate your terminal's shell prompt. When following along, don't type the `>` character, or you'll get some weird errors.


## Build a libp2p bundle

libp2p is a very modular framework, which allows javascript devs to target different runtime environments and opt-in to various features by including a custom selection of modules.

Because every application is different, we recommend building a "bundle" with just the modules you need. You can even make more than one, if you want to target multiple javascript runtimes with different features. For example, the IPFS project uses two libp2p bundles, [one for node.js](https://github.com/ipfs/js-ipfs/tree/master/src/core/runtime/libp2p-nodejs.js) and [one for the browser](https://github.com/ipfs/js-ipfs/tree/master/src/core/runtime/libp2p-browser.js).

Since, we're here to learn how libp2p works, we're going to start from scratch and define our own bundle. We'll start with a very simple bundle and add features as we need them.

First, install the `libp2p` dependency. We'll also need at least one transport module, so we'll pull in `libp2p-tcp` as well, and the `@nodeutils/defaults-deep` helper which we'll use when building the bundle.

```shell
npm install --save libp2p libp2p-tcp @nodeutils/defaults-deep
```

{{% notice note %}}
In a production application, it may make sense to create a separate npm module for your bundle, which will give you one place to manage the libp2p dependencies for all your javascript projects. In that case, you should not depend on `libp2p` directly in your application. Instead you'd depend on your bundle, which would in turn depend on `libp2p` and whatever modules (transports, etc) you might need.
{{% /notice %}}

For this tutorial, our bundle will just be a javascript file in our application source.

Make a directory called `src/p2p` and a file called `src/p2p/index.js` with the following content:

```javascript
const Libp2p = require('libp2p')
const TCP = require('libp2p-tcp')

const defaultsDeep = require('@nodeutils/defaults-deep')

const DEFAULT_OPTS = {
  modules: {
    transport: [
      TCP
    ]
  }
}

class P2PNode extends Libp2p {
  constructor (opts) {
    super(defaultsDeep(opts, DEFAULT_OPTS))
  }
}

module.exports = {P2PNode}
```

The `libp2p` module exports a [libp2p.Node class](https://github.com/libp2p/js-libp2p#create-a-node---new-libp2pnodeoptions) which we extend into our own `P2PNode` class.

Right now our class just adds the `libp2p-tcp` transport module to the default constructor options of the base class. As we go, we'll extend our bundle to include more transports and configure other aspects of the libp2p stack.

## Create an instance of a libp2p node

Using the bundle we defined above, we can create a new `P2PNode` instance.

To do so, create a file called `src/index.js` and make it look like this:

```javascript
const multiaddr = require('multiaddr')
const PeerInfo = require('peer-info')
const {P2PNode} = require('./p2p')

function createPeer(callback) {
  // create a new PeerInfo object with a newly-generated PeerId
  PeerInfo.create((err, peerInfo) => {
    if (err) {
      return callback(err)
    }

    // add a listen address to accept TCP connections on a random port
    const listenAddress = multiaddr(`/ip4/127.0.0.1/tcp/0`)
    peerInfo.multiaddrs.add(listenAddress)

    const peer = new P2PNode({peerInfo})
    // register an event handler for errors.
    // here we're just going to print and re-throw the error
    // to kill the program
    peer.on('error', err => {
      console.error('libp2p error: ', err)
      throw err
    })

    callback(null, peer)
  })
}
```

We start out by importing a few modules. Apart from the `P2PNode` bundle we defined earlier, we have `multiaddr`, the javascript [multiaddress][definition_muiltiaddress] library, and `peer-info`, which contains a [PeerId][definition_peerid] and a set of multiaddresses that are associated with a peer.

The constructor for our bundle requires a `peerInfo` argument. This can either be generated on-the-fly or loaded from a byte buffer or JSON object. In our `createPeer` function, we're generating a new `PeerInfo` object for our peer using [`PeerInfo.create`](https://github.com/libp2p/js-peer-info#peerinfocreateid--callback). This will generate a new `PeerId` containing a newly-generated cryptographic key pair.

{{% notice note %}}
Because generating the key pair requires some computation, `PeerInfo.create` is an asynchronous operation. libp2p uses node-style callbacks for most asynchronous operations, and real-world code and more complex examples will often use helpers like [async/waterfall](https://caolan.github.io/async/docs.html#waterfall) to compose chains of async operations. Since this is a fairly simple example, we're just going to use the callbacks as-is and chain them together the "old fashioned way".
{{% /notice %}}

Once we have our `PeerInfo`, we next create a [multiaddress][definition_muiltiaddress] for `/ip4/127.0.0.1/tcp/0`, which is the [localhost IPv4 address](https://en.wikipedia.org/wiki/Localhost) on the special TCP port `0`. Using port `0` tells the operating system to randomly assign us an open port.

Adding the new multiaddr to our `PeerInfo` object will cause our node to try to listen on that address when the node starts.

Next we create our peer, passing in the `peerInfo` constructor option, and we register a simple error handler to catch errors that might occur during the lifetime of our peer.

## Start the node and listen for connections

Now we can call the `createPeer` function above and start listening for connections.

Just below the `createPeer` function definition, add some code to start the peer and print our listening address:

```javascript
function handleStart(peer) {
      // get the list of addresses for our peer now that it's started.
      // there should be one address of the form
      // `/ip4/127.0.0.1/tcp/${assignedPort}/ipfs/${generatedPeerId}`,
      // where `assignedPort` is randomly chosen by the operating system
      // and `generatedPeerId` is generated in the `createPeer` function above.
      const addresses = peer.peerInfo.multiaddrs.toArray()
      console.log('peer started. listening on addresses:')
      addresses.forEach(addr => console.log(addr.toString()))
}


// main entry point
createPeer((err, peer) => {
  if (err) {
    throw err
  }

  peer.start(err => {
    if (err) {
      throw err
    }

    handleStart(peer)
  })
})
```

Try running the code with `node src/index.js`. You should see something like:

```
peer started. listening on addresses:
/ip4/127.0.0.1/tcp/54093/ipfs/QmPfH3qx5fyfUgxacrZ1WNC1GwXmY5kWzns3Fc9KAwZRgJ
```

Each time you run the program, you should see a different tcp port number and PeerId hash (the `QmPfH3qx5fyfUgxacrZ1WNC1GwXmY5kWzns3Fc9KAwZRgJ` string above).

## Add multiplexing and encryption

We can now start a node and listen for connections, but we can't really do anything yet. This is because we're missing a key libp2p component called a [stream multiplexer][definition_multiplexer], which lets us interleave multiple independent streams of communication across one network connection.

While we're at it, we'll also add support for encrypted communication, which is something most real-world applications will need to support.

Lets add two new dependencies:

```shell
npm install --save libp2p-mplex libp2p-secio
```

And we'll need to edit our bundle. Open `src/p2p/index.js` and import the new modules:

```javascript
const Multiplex = require('libp2p-mplex')
const SECIO = require('libp2p-secio')
```

Then change the `DEFAULT_OPTS` constant to look like this:

```javascript
const DEFAULT_OPTS = {
  modules: {
    transport: [
      TCP
    ],
    connEncryption: [
      SECIO
    ],
    streamMuxer: [
      Multiplex
    ]
  }
}
```

Thats it! Now we can open multiple independent streams over our single TCP connection, and our connection will be upgraded to a securely encrypted channel using the [secio module](https://github.com/libp2p/js-libp2p-secio).

## Lets play ping pong!

Now that we have the basic building blocks of transport, multiplexing, and security in place, we can start communicating!

The base `libp2p.Node` class that we based our bundle on registers one built-in protocol handler for us, the [ping protocol](https://github.com/libp2p/js-libp2p-ping). That means that other peers can dial us and send us ping messages, and we'll send back a "pong" so they know we're alive and can measure the latency between us.

While we respond to pings automatically, we need to do a bit of wiring to send them.

Let's add a `ping` method to our `P2PNode` class so we can send pings to other peers.

Change the definition of `P2PNode` in `src/p2p/index.js` to this:

```javascript
const Ping = require('libp2p/src/ping')

class P2PNode extends Libp2p {
  constructor (opts) {
    super(defaultsDeep(opts, DEFAULT_OPTS))
  }

  ping (remotePeerInfo, callback) {
    const p = new Ping(this._switch, remotePeerInfo)
    p.on('ping', time => {
      p.stop() // stop sending pings
      callback(null, time)
    })
    p.on('error', callback)
    p.start()
  }
}
```

Now we can accept have our program accept the multiaddress of another peer as a command line argument and try to ping it.

To do so, we'll need to add a couple things to `src/index.js`. First, require the `process` module so we can get the command line arguments:

```javascript
const process = require('process')
```

Then we'll add a function to parse a multiaddress from the command line and try to ping the remote peer:

```javascript
const PeerId = require('peer-id')

function pingRemotePeer(localPeer) {
  if (process.argv.length < 3) {
    return console.log('no remote peer address given, skipping ping')
  }
  const remoteAddr = multiaddr(process.argv[2])

  // Convert the multiaddress into a PeerInfo object
  const peerId = PeerId.createFromB58String(remoteAddr.getPeerId())
  const remotePeerInfo = new PeerInfo(peerId)
  remotePeerInfo.multiaddrs.add(remoteAddr)

  console.log('pinging remote peer at ', remoteAddr.toString())
  localPeer.ping(remotePeerInfo, (err, time) => {
    if (err) {
      return console.error('error pinging: ', err)
    }
    console.log(`pinged ${remoteAddr.toString()} in ${time}ms`)
  })
}
```

And finally, in our `handleStart` function, just after we log our listen address, add this line:

```javascript
pingRemotePeer(peer)
```

Now we can start one instance with no arguments:

```shell
> node src/index.js
peer started. listening on addresses:
/p2p-circuit/ipfs/QmcJWZQ3Q1q9jUwzYw1e1NN2oQG2kGocru62oGAnh4HMGL
/p2p-circuit/ip4/127.0.0.1/tcp/0/ipfs/QmcJWZQ3Q1q9jUwzYw1e1NN2oQG2kGocru62oGAnh4HMGL
/ip4/127.0.0.1/tcp/55780/ipfs/QmcJWZQ3Q1q9jUwzYw1e1NN2oQG2kGocru62oGAnh4HMGL
no remote peer address given, skipping ping
```

Grab the `/ip4/...` address printed above and use it as an argument to another instance.  In a new terminal:

```shell
> node src/index.js /ip4/127.0.0.1/tcp/55780/ipfs/QmcJWZQ3Q1q9jUwzYw1e1NN2oQG2kGocru62oGAnh4HMGL
peer started. listening on addresses:
/p2p-circuit/ipfs/QmWXirJ9QoSnXpEAqVeEFtEAwcP8oufg1bBV2dSH41B2yt
/p2p-circuit/ip4/127.0.0.1/tcp/0/ipfs/QmWXirJ9QoSnXpEAqVeEFtEAwcP8oufg1bBV2dSH41B2yt
/ip4/127.0.0.1/tcp/55800/ipfs/QmWXirJ9QoSnXpEAqVeEFtEAwcP8oufg1bBV2dSH41B2yt
pinging remote peer at  /ip4/127.0.0.1/tcp/55780/ipfs/QmcJWZQ3Q1q9jUwzYw1e1NN2oQG2kGocru62oGAnh4HMGL
pinged /ip4/127.0.0.1/tcp/55780/ipfs/QmcJWZQ3Q1q9jUwzYw1e1NN2oQG2kGocru62oGAnh4HMGL in 6ms
```

Success! Our two peers are now communicating over a multiplexed, secure channel.  Sure, they can only say "ping", but it's a start!



[definition_muiltiaddress]: /reference/glossary/#multiaddr
[definition_multiplexer]: /reference/glossary/#multiplexer
[definition_peerid]: /reference/glossary/#peerid
