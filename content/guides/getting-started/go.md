---
title: "Run a go-libp2p node"
weight: 2
description: "Learn how to run a go-libp2p node and use the ping protocol"
aliases:
    - "/tutorials/go"
    - "/guides"
    - "/guides/go"
---

The getting started tutorial covers setting up a development environment, getting familiar
with libp2p basics, and implementing a simple node that can send and receive "ping" messages
in go-libp2p.

The [Protocol Labs Launchpad curriculum](https://curriculum.pl-launchpad.io/) also includes
a tutorial on spinning up a libp2p node using a go-libp2p bolierplate. Check it out
[here](https://curriculum.pl-launchpad.io/tutorials/libp2p/creating-simple-node/).

This is the first in a series of tutorials on working with libp2p’s Go implementation,
[go-libp2p](https://github.com/libp2p/go-libp2p). We’ll cover installing Go, setting up
a new Go module, starting libp2p nodes, and sending ping messages between them.

### Install Go

- Ensure your Go version is at least 1.19.
- You can install a recent version of Go by following the [official installation instructions](https://golang.org/doc/install).
- Once installed, you should be able to run `go version` and see a version >= 1.19, for example:

```bash
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

```bash
mkdir -p /tmp/go-libp2p-tutorial
cd /tmp/go-libp2p-tutorial
go mod init github.com/user/go-libp2p-tutorial
```

You should now have a `go.mod` file in the current directory containing the name of the module you
initialized and the version of Go you're using, for example:

```bash
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

```bash
go get github.com/libp2p/go-libp2p
```

We can now compile this into an executable using `go build` and run it from the command line:

```bash
$ go build -o libp2p-node

$ ./libp2p-node
Listen addresses: [/ip6/::1/tcp/57666 /ip4/192.0.2.0/tcp/57665 /ip4/198.51.100.0/tcp/57665]
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
                libp2p.ListenAddrStrings("/ip4/192.0.2.0/tcp/2000"),
        )
    if err != nil {
        panic(err)
    }

        ...
}
```

Re-building and running the executable again now prints the explicit listen address we've configured:

```bash
$ go build -o libp2p-node

$ ./libp2p-node
Listening addresses: [/ip4/192.0.2.0/tcp/2000]
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

```bash
$ ./libp2p-node
Listening addresses: [/ip4/192.0.2.0/tcp/2000]
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
        libp2p.ListenAddrStrings("/ip4/192.0.2.0/tcp/0"),
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

```bash
$ ./libp2p-node
libp2p node address: /ip4/192.0.2.0/tcp/62268/ipfs/QmfQzWnLu4UX1cW7upgyuFLyuBXqze7nrPB4qWYqQiTHwt
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
        libp2p.ListenAddrStrings("/ip4/192.0.2.0/tcp/0"),
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

```bash
$ ./libp2p-node
libp2p node address: /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL
```

In another terminal window, let's run a second node but pass the address of the first node, and we
should see some ping responses logged:

```bash
$ ./libp2p-node /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL
libp2p node address: /ip4/192.0.2.0/tcp/61846/ipfs/QmVyKLTLswap3VYbpBATsgNpi6JdwSwsZALPxEnEbEndup
sending 5 ping messages to /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL
pinged /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 431.231µs
pinged /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 164.94µs
pinged /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 220.544µs
pinged /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 208.761µs
pinged /ip4/192.0.2.0/tcp/61790/ipfs/QmZKjsGJ6ukXVRXVEcExx9GhiyWoJC97onYpzBwCHPWqpL in 201.37µs
```

Success! Our two peers are now communicating using go-libp2p! Sure, they can only say “ping”, but it’s a start!
