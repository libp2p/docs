---
title: "Guides"
weight: 3
pre: "<b>3. </b>"
chapter: true
---

### Chapter 3

# Get Started with libp2p

## Examples using libp2p

If you are looking for specific examples - here's where to find working examples illustrating some 
of libp2p's key features for each of its main implementations.

{{< tabs >}}
{{% tab name="Go" %}}

See the [/examples directory of the go-libp2p-examples repository](https://github.com/libp2p/go-libp2p/tree/master/).

{{% /tab %}}
{{% tab name="Rust" %}}

See [/examples directory of the rust-libp2p repository](https://github.com/libp2p/rust-libp2p/tree/master/examples).

{{% /tab %}}
{{% tab name="JavaScript" %}}

See the [/examples directory of the js-libp2p repository](https://github.com/libp2p/js-libp2p/tree/master/).

{{% /tab %}}
{{< /tabs >}}

## Run a libp2p node

The getting started tutorials cover setting up a development environment, getting familiar with libp2p basics, 
and implementing a simple node that can send and receive "ping" messages.

{{% notice "tip" %}}
The [Protocol Labs Launchpad curriculum](https://curriculum.pl-launchpad.io/) also includes a tutorial on spinning up 
a libp2p node using a go-libp2p bolierplate. Check it out [here](https://curriculum.pl-launchpad.io/curriculum/libp2p/creating-simple-node/).
{{% /notice %}}

{{< tabs >}}
{{% tab name="Go" %}}

This is the first in a series of tutorials on working with libp2p’s Go implementation,
[go-libp2p](https://github.com/libp2p/go-libp2p). We’ll cover installing Go, setting up a new Go module, 
starting libp2p nodes, and sending ping messages between them.

### Install Go

- Ensure your Go version is at least 1.19.
- You can install a recent version of Go by following the [official installation instructions](https://golang.org/doc/install).
- Once installed, you should be able to run `go version` and see a version >= 1.19, for example:

```sh
$ go version
go version go1.19 darwin/arm64
```

### Create a Go module

We're going to create a Go module that can be run from the command line.

Let's create a new directory and use `go mod` to initialize it as a module. We'll create it in
`/tmp`, but you can equally create it anywhere on your filesystem. We'll also initialize it with the
module name `github.com/user/go-libp2p-tutorial`, but you may want to replace this with a name that
corresponds to a repository name you have the rights to push to if you want to publish your version
of the code.

```sh
$ mkdir -p /tmp/go-libp2p-tutorial

$ cd /tmp/go-libp2p-tutorial

$ go mod init github.com/user/go-libp2p-tutorial
```

You should now have a `go.mod` file in the current directory containing the name of the module you
initialized and the version of Go you're using, for example:

```sh
$ cat go.mod
module github.com/user/go-libp2p-tutorial

go 1.19
```

### Start a libp2p node

We'll now add some code to our module to start a libp2p node.
Let's start by creating a `main.go` file that simply starts a libp2p node with default settings,
prints the node's listening addresses, then shuts the node down:

```go
package main

import (
	"fmt"
	"github.com/libp2p/go-libp2p"
)

func main() {
	// start a libp2p node with default settings
	node, err := libp2p.New()
	if err != nil {
		panic(err)
	}

	// print the node's listening addresses
	fmt.Println("Listen addresses:", node.Addrs())

	// shut the node down
	if err := node.Close(); err != nil {
		panic(err)
	}
}
```

Import the `libp2p/go-libp2p` module:

```shell
$ go get github.com/libp2p/go-libp2p
```

We can now compile this into an executable using `go build` and run it from the command line:

```sh
$ go build -o libp2p-node

$ ./libp2p-node
Listen addresses: [/ip6/::1/tcp/57666 /ip4/127.0.0.1/tcp/57665 /ip4/192.168.1.56/tcp/57665]
```

The listening addresses are formatted using the [multiaddr](https://github.com/multiformats/multiaddr)
format, and there is typically more than one printed because go-libp2p will listen on all available
IPv4 and IPv6 network interfaces by default.

#### Configure the node

A node's default settings can be overridden by passing extra arguments to `libp2p.New`. Let's use
`libp2p.ListenAddrStrings` to configure the node to listen on TCP port 2000 on the IPv4 loopback
interface:

```go
func main() {
        ...

        // start a libp2p node that listens on TCP port 2000 on the IPv4
        // loopback interface
        node, err := libp2p.New(
                libp2p.ListenAddrStrings("/ip4/127.0.0.1/tcp/2000"),
        )
	if err != nil {
		panic(err)
	}

        ...
}
```

Re-building and running the executable again now prints the explicit listen address we've configured:

```sh
$ go build -o libp2p-node

$ ./libp2p-node
Listening addresses: [/ip4/127.0.0.1/tcp/2000]
```

`libp2p.New` accepts a variety of arguments to configure most aspects of the node. See
[options.go](https://github.com/libp2p/go-libp2p/blob/master/options.go) for a full list of those
options.

#### Wait for a signal

A node that immediately exits is not all that useful. Let's add the following towards the end of the
`main` function that blocks waiting for an OS signal before shutting down the node:

```go
func main() {
        ...

        // wait for a SIGINT or SIGTERM signal
        ch := make(chan os.Signal, 1)
        signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
        <-ch
        fmt.Println("Received signal, shutting down...")

        // shut the node down
        if err := node.Close(); err != nil {
                panic(err)
        }
}
```

We also need to update the list of imports at the top of the file to include the `os`, `os/signal`
and `syscall` packages we're now using:

```go
import (
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/libp2p/go-libp2p"
)
```

Running the node now waits until it receives a SIGINT (i.e. a `ctrl-c` key press) or a SIGTERM signal
before shutting down:

```sh
$ ./libp2p-node
Listening addresses: [/ip4/127.0.0.1/tcp/2000]
^CReceived signal, shutting down...
```

### Run the ping protocol

Now that we have the ability to configure and start libp2p nodes, we can start communicating!

#### Set a stream handler

A node started with go-libp2p will run its own ping protocol by default, but let's disable it and
set it up manually to demonstrate the process of running protocols by registering stream handlers.

The object returned from `libp2p.New` implements the [Host interface](https://pkg.go.dev/github.com/libp2p/go-libp2p-core/host#Host),
and we'll use the `SetStreamHandler` method to set a handler for our ping protocol.

First, let's add the `github.com/libp2p/go-libp2p/p2p/protocol/ping` package to our list of
imported packages:

```go
import (
	...

	"github.com/libp2p/go-libp2p"
	"github.com/libp2p/go-libp2p/p2p/protocol/ping"
)
```

Now we'll pass an argument to `libp2p.New` to disable the built-in ping protocol, and then use the
`PingService` type from the ping package to set a stream handler manually (note that we're also
configuring the node to listen on a random local TCP port rather than a hard coded one, which means
we'll be able to run multiple nodes on the same machine without them trying to listen on the same
port):

```go
func main() {
	...

	// start a libp2p node that listens on a random local TCP port,
	// but without running the built-in ping protocol
	node, err := libp2p.New(
		libp2p.ListenAddrStrings("/ip4/127.0.0.1/tcp/0"),
		libp2p.Ping(false),
	)
	if err != nil {
		panic(err)
	}

	// configure our own ping protocol
	pingService := &ping.PingService{Host: node}
	node.SetStreamHandler(ping.ID, pingService.PingHandler)

	...
}
```

#### Connect to a peer

With the ping protocol configured, we need a way to instruct the node to connect to another node and
send it ping messages.

We'll first expand the log message that we've been printing after starting the node to include
its `PeerId` value, as we'll need that to instruct other nodes to connect to it. Let's import the
`github.com/libp2p/go-libp2p-core/peer` package and use it to replace the "Listen addresses" log
message with something that prints both the listen address and the `PeerId` as a multiaddr string:

```go
import (
	...

	"github.com/libp2p/go-libp2p"
    peerstore "github.com/libp2p/go-libp2p-core/peer"
	"github.com/libp2p/go-libp2p/p2p/protocol/ping"
)

func main() {
	...

	// print the node's PeerInfo in multiaddr format
	peerInfo := peerstore.AddrInfo{
		ID:    node.ID(),
		Addrs: node.Addrs(),
	}
	addrs, err := peerstore.AddrInfoToP2pAddrs(&peerInfo)
	fmt.Println("libp2p node address:", addrs[0])

	...
}
```

Running the node now prints the node's address that can be used to connect to it:

```sh
$ ./libp2p-node
libp2p node address: /ip4/127.0.0.1/tcp/62268/ipfs/QmfQzWnLu4UX1cW7upgyuFLyuBXqze7nrPB4qWYqQiTHwt
```

Let's also accept a command line argument that is the address of a peer to send ping messages to,
allowing us to either just run a listening node that waits for a signal, or run a node that connects
to another node and pings it a few times before shutting down (we'll use the `github.com/multiformats/go-multiaddr`
package to parse the peer's address from the command line argument):

```go
import (
	...

	"github.com/libp2p/go-libp2p"
	peerstore "github.com/libp2p/go-libp2p-core/peer"
	"github.com/libp2p/go-libp2p/p2p/protocol/ping"
	multiaddr "github.com/multiformats/go-multiaddr"
)

func main() {
	...
	fmt.Println("libp2p node address:", addrs[0])

	// if a remote peer has been passed on the command line, connect to it
	// and send it 5 ping messages, otherwise wait for a signal to stop
	if len(os.Args) > 1 {
		addr, err := multiaddr.NewMultiaddr(os.Args[1])
		if err != nil {
			panic(err)
		}
		peer, err := peerstore.AddrInfoFromP2pAddr(addr)
		if err != nil {
			panic(err)
		}
		if err := node.Connect(context.Background(), *peer); err != nil {
			panic(err)
		}
		fmt.Println("sending 5 ping messages to", addr)
		ch := pingService.Ping(context.Background(), peer.ID)
		for i := 0; i < 5; i++ {
			res := <-ch
			fmt.Println("got ping response!", "RTT:", res.RTT)
		}
	} else {
		// wait for a SIGINT or SIGTERM signal
		ch := make(chan os.Signal, 1)
		signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
		<-ch
		fmt.Println("Received signal, shutting down...")
	}

	// shut the node down
	if err := node.Close(); err != nil {
		panic(err)
	}
}
```

### Let's play ping pong!

We are finally in a position to run two libp2p nodes, have one connect to the other and for
them to run a protocol!

To recap, here is the full program we have written:

```go
package main

import (
    "context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/libp2p/go-libp2p"
	peerstore "github.com/libp2p/go-libp2p-core/peer"
	"github.com/libp2p/go-libp2p/p2p/protocol/ping"
	multiaddr "github.com/multiformats/go-multiaddr"
)

func main() {
	// start a libp2p node that listens on a random local TCP port,
	// but without running the built-in ping protocol
	node, err := libp2p.New(
		libp2p.ListenAddrStrings("/ip4/127.0.0.1/tcp/0"),
		libp2p.Ping(false),
	)
	if err != nil {
		panic(err)
	}

	// configure our own ping protocol
	pingService := &ping.PingService{Host: node}
	node.SetStreamHandler(ping.ID, pingService.PingHandler)

	// print the node's PeerInfo in multiaddr format
	peerInfo := peerstore.AddrInfo{
		ID:    node.ID(),
		Addrs: node.Addrs(),
	}
	addrs, err := peerstore.AddrInfoToP2pAddrs(&peerInfo)
	if err != nil {
		panic(err)
	}
	fmt.Println("libp2p node address:", addrs[0])

	// if a remote peer has been passed on the command line, connect to it
	// and send it 5 ping messages, otherwise wait for a signal to stop
	if len(os.Args) > 1 {
		addr, err := multiaddr.NewMultiaddr(os.Args[1])
		if err != nil {
			panic(err)
		}
		peer, err := peerstore.AddrInfoFromP2pAddr(addr)
		if err != nil {
			panic(err)
		}
		if err := node.Connect(context.Background(), *peer); err != nil {
			panic(err)
		}
		fmt.Println("sending 5 ping messages to", addr)
		ch := pingService.Ping(context.Background(), peer.ID)
		for i := 0; i < 5; i++ {
			res := <-ch
			fmt.Println("pinged", addr, "in", res.RTT)
		}
	} else {
		// wait for a SIGINT or SIGTERM signal
		ch := make(chan os.Signal, 1)
		signal.Notify(ch, syscall.SIGINT, syscall.SIGTERM)
		<-ch
		fmt.Println("Received signal, shutting down...")
	}

	// shut the node down
	if err := node.Close(); err != nil {
		panic(err)
	}
}
```

In one terminal window, let's start a listening node (i.e. don't pass any command line arguments):

```sh
$ ./libp2p-node
libp2p node address: /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL
```

In another terminal window, let's run a second node but pass the address of the first node, and we
should see some ping responses logged:

```sh
$ ./libp2p-node /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL
libp2p node address: /ip4/127.0.0.1/tcp/61846/ipfs/QmVyKLTLswap3VYbpBATsgNpi6JdwSwsZALPxEnEbEndup
sending 5 ping messages to /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL
pinged /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 431.231µs
pinged /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 164.94µs
pinged /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 220.544µs
pinged /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 208.761µs
pinged /ip4/127.0.0.1/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 201.37µs
```

Success! Our two peers are now communicating using go-libp2p! Sure, they can only say “ping”, but it’s a start!

{{% /tab %}}
{{% tab name="Rust" %}}

Check out [tutorials of the Rust libp2p
implementation](https://docs.rs/libp2p/newest/libp2p/tutorials/index.html).

{{% /tab %}}
{{% tab name="JavaScript" %}}

This is the first in a series of tutorials on working with libp2p's javascript implementation, [js-libp2p](https://github.com/libp2p/js-libp2p).
We will walk you through setting up a fully functional libp2p node with some basic functionality, and finally we'll send ping messages back and forth between two peers.

<!--more-->

<!--
TODO(yusef): put full example code on github and link to it here
 -->

### Install node.js

Working with js-libp2p requires [node.js](https://nodejs.org) >= v16 for development. If you haven't already, install node using whatever package manager you prefer or [using the official installer](https://nodejs.org/en/download/).
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
> npm init
```

Side note: throughout this tutorial, we use the `> ` character to indicate your terminal's shell prompt. When following along, don't type the `>` character, or you'll get some weird errors.

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

Now that we have the module installed, let's configure libp2p to use the Transport. We'll use the `createLibp2pNode` method, which takes a single configuration object as its only parameter. We can add the Transport by passing it into the `transports` array. Create a `src/index.js` file and have the following code in it:

```js
import { createLibp2p } from 'libp2p'
import { TCP } from '@libp2p/tcp'

const node = await createLibp2p({
  transports: [new TCP()]
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
import { TCP } from '@libp2p/tcp'
import { Noise } from '@chainsafe/libp2p-noise'

const node = await createLibp2p({
  transports: [new TCP()],
  connectionEncryption: [new Noise()]
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
import { TCP } from '@libp2p/tcp'
import { Noise } from '@chainsafe/libp2p-noise'
import { Mplex } from '@libp2p/mplex'

const node = await createLibp2p({
  transports: [new TCP()],
  connectionEncryption: [new Noise()],
  streamMuxers: [new Mplex()]
})

```

#### Running libp2p

Now that you have configured a **Transport**, **Crypto** and **Stream Multiplexer** module, you can start your libp2p node. We can start and stop libp2p using the [`libp2p.start()`](https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#start) and [`libp2p.stop()`](https://github.com/libp2p/js-libp2p/blob/master/doc/API.md#stop) methods.


```js
import { createLibp2p } from 'libp2p'
import { TCP } from '@libp2p/tcp'
import { Noise } from '@chainsafe/libp2p-noise'
import { Mplex } from '@libp2p/mplex'

const main = async () => {
  const node = await createLibp2p({
    addresses: {
      // add a listen address (localhost) to accept TCP connections on a random port
      listen: ['/ip4/127.0.0.1/tcp/0']
    },
    transports: [new TCP()],
    connectionEncryption: [new Noise()],
    streamMuxers: [new Mplex()]
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

```
libp2p has started
listening on addresses:
/ip4/127.0.0.1/tcp/50626/p2p/QmYoqzFj5rhzFy7thCPPGbDkDkLMbQzanxCNwefZd3qTkz
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
import { TCP } from '@libp2p/tcp'
import { Noise } from '@chainsafe/libp2p-noise'
import { Mplex } from '@libp2p/mplex'
import { multiaddr } from 'multiaddr'

const node = await createLibp2p({
  addresses: {
    // add a listen address (localhost) to accept TCP connections on a random port
    listen: ['/ip4/127.0.0.1/tcp/0']
  },
  transports: [new TCP()],
  connectionEncryption: [new Noise()],
  streamMuxers: [new Mplex()]
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
/ip4/127.0.0.1/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN
no remote peer address given, skipping ping
```

Grab the `/ip4/...` address printed above and use it as an argument to another instance.  In a new terminal:

```shell
> node src/index.js /ip4/127.0.0.1/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN
libp2p has started
listening on addresses:
/ip4/127.0.0.1/tcp/50777/p2p/QmYZirEPREz9vSRFznxhQbWNya2LXPz5VCahRCT7caTLGm
pinging remote peer at /ip4/127.0.0.1/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN
pinged /ip4/127.0.0.1/tcp/50775/p2p/QmcafwJSsCsnjMo2fyf1doMjin8nrMawfwZiPftBDpahzN in 3ms
libp2p has stopped
```

Success! Our two peers are now communicating over a multiplexed, secure channel.  Sure, they can only say "ping", but it's a start!

### What's next?

After finishing this tutorial, you should have a look into the [js-libp2p getting started](https://github.com/libp2p/js-libp2p/blob/master/doc/GETTING_STARTED.md) document, which goes from a base configuration like this one, to more custom ones.

You also have a panoply of examples on [js-libp2p repo](https://github.com/libp2p/js-libp2p/tree/master/examples) that you can leverage to learn how to use `js-libp2p` for several different use cases and runtimes.

[definition_multiaddress]: /reference/glossary/#multiaddr
[definition_multiplexer]: /reference/glossary/#multiplexer
[definition_peerid]: /reference/glossary/#peerid

{{% /tab %}}
{{< /tabs >}}
