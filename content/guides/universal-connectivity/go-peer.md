---
title: "Run a go-libp2p node"
weight: 21
description: "Learn how to build and run a go-libp2p peer"
---

# Building a Go libp2p Peer

In this guide you'll learn the process to create your very own distributed peer-to-peer application. This guide was built specifically with the [Go peer](https://github.com/libp2p/universal-connectivity/tree/main/go-peer) from [libp2p/universal-connectivity](https://github.com/libp2p/universal-connectivity) in mind. You can see the finished project at [TheDiscordian/go-libp2p-peer](https://github.com/TheDiscordian/go-libp2p-peer) which can be easily forked and built upon.

For this guide we'll be assuming you're running a Linux or MacOS system. If you're on Windows, please consider following the [WSL Install Guide](https://learn.microsoft.com/en-us/windows/wsl/install) on Microsoft's website to follow along more easily.

Having some terminal skills will greatly assist in following this guide. If you're on MacOS, installing [Homebrew](https://brew.sh/) is highly recommended. All commands assume you're in the project directory.

#### Table of Contents (What you'll learn!)

[TOC]


## Resources

We'll be using packages from the following repositories:

- [go-libp2p](https://github.com/libp2p/go-libp2p)
- [go-libp2p-pubsub](https://github.com/libp2p/go-libp2p-pubsub)
- [go-multiaddr](https://github.com/multiformats/go-multiaddr)

It might be helpful to peek into those repositories to see what they are, but we'll go over what's happening as we go.

## Getting started

We begin with an empty Go project `main.go`:

```go
package main

import (
	"fmt"
)

func main() {
}
```

And run `go mod init go-peer/tutorial` to initialse your Go project. I've included `fmt` in here as we'll be using it in the near future.

## Identity

Every libp2p peer has an identity known as a [PeerID](https://docs.libp2p.io/concepts/fundamentals/peers/#peer-id). This PeerID is derived from a keypair. For this guide we'll be using Ed25519.

Let's go ahead and create a new file in our project directory titled `identity.go` and populate it with the following:

```go
package main

import (
	"fmt"
	"os"

	"github.com/libp2p/go-libp2p/core/crypto"
)
```

We've grabbed an external package here, specifically the go-libp2p crypto package, which will give us tools that will aid in generating and utilizing our cryptographic keys. Let's add it to our `go.mod` file with the following:

```bash
go get github.com/libp2p/go-libp2p/core/crypto
```

Next, we're going to add in three functions. Don't worry, we'll break down what they do in a moment:

```go
// GenerateIdentity writes a new random private key to the given path.
func GenerateIdentity(path string) (crypto.PrivKey, error) {
	privk, _, err := crypto.GenerateKeyPair(crypto.Ed25519, 0)
	if err != nil {
		return nil, err
	}

	bytes, err := crypto.MarshalPrivateKey(privk)
	if err != nil {
		return nil, err
	}

	err = os.WriteFile(path, bytes, 0400)

	return privk, err
}

// ReadIdentity reads a private key from the given path.
func ReadIdentity(path string) (crypto.PrivKey, error) {
	bytes, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	return crypto.UnmarshalPrivateKey(bytes)
}

// LoadIdentity reads a private key from the given path and, if it does not
// exist, generates a new one.
func LoadIdentity(path string) (crypto.PrivKey, error) {
	if _, err := os.Stat(path); err == nil {
		return ReadIdentity(path)
	} else if os.IsNotExist(err) {
		fmt.Printf("Generating peer identity in %s\n", path)
		return GenerateIdentity(path)
	} else {
		return nil, err
	}
}
```

Here we have three functions, each taking one string parameter and returning the values `crypto.PrivKey` and `error`:

- `GenerateIdentity(path string) (crypto.PrivKey, error)`
    - Generates a keypair and stores the private key in `path`.
- `ReadIdentity(path string) (crypto.PrivKey, error)`
    - Reads a private key from `path`.
- `LoadIdentity(path string) (crypto.PrivKey, error)`
    - Reads a private key from `path` using `ReadIdentity` and, if it doesn't exist, generates one using `GenerateIdentity`.

The easiest way to see what these functions mean to us is to use them, so let's open up `main.go` again and add a few lines to the bottom of the `main` function:

```go
// Load our private key from "identity.key", if it doesn't exist,
// generate one, and store it in "identity.key".
privk, err := LoadIdentity("identity.key")
if err != nil {
	panic(err)
}
```

Now we have a variable called `privk` which contains our private key which we'll use to represent our identity and sign messages. We'll use this value in the next step.

:::	warning
**Warning**
Never share your private key with anyone. Only share your public key which is derived from the private key. Typically when someone says "PeerID", they're talking about an encoded version of the public key. We'll get this value in the next step.
:::

## Creating the Peer

Now that we have an identity, we have the bare minimum to create and run the peer, so let's do that! In `main.go`...

Add this to your import list:

```go
"github.com/libp2p/go-libp2p"
```

Don't forget to call `go get github.com/libp2p/go-libp2p` afterwards to add it to your `go.mod` file.

Next, add the following to the bottom of `main()`:

```go
var opts []libp2p.Option

opts = append(opts,
	libp2p.Identity(privk),
)
```

What we're doing here is building a list of [libp2p options](https://pkg.go.dev/github.com/libp2p/go-libp2p#Option) which are used for configuring our peer. The only option we have right now is `libp2p.Identity(privk)` which lets the libp2p library know which private key we're using for our identity.

Now, let's create the actual libp2p peer by adding some more lines to the bottom of our `main` function:

```go
// Create a new libp2p Host with our options.
h, err := libp2p.New(opts...)
if err != nil {
	panic(err)
}

fmt.Println("PeerID:", h.ID().String())
for _, addr := range h.Addrs() {
	fmt.Printf("Listening on: %s/p2p/%s", addr.String(), h.ID())
	fmt.Println()
}
```

Run your code with `go run .` and you should see something similar to the following:

```bash
PeerID: 12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/127.0.0.1/tcp/53215/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/127.0.0.1/udp/49259/quic/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/127.0.0.1/udp/49259/quic-v1/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/127.0.0.1/udp/55676/quic-v1/webtransport/certhash/uEiDcHLhuZwUZ7zHnvO-O38Xj_5IohFefXo0JOA4AIxEn3A/certhash/uEiCqnFKTggBe3-KbC5IBQYnxovaJWdmvm2IxCYGzyGqItQ/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/192.168.0.168/tcp/53215/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/192.168.0.168/udp/49259/quic/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/192.168.0.168/udp/49259/quic-v1/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip4/192.168.0.168/udp/55676/quic-v1/webtransport/certhash/uEiDcHLhuZwUZ7zHnvO-O38Xj_5IohFefXo0JOA4AIxEn3A/certhash/uEiCqnFKTggBe3-KbC5IBQYnxovaJWdmvm2IxCYGzyGqItQ/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip6/::1/tcp/53218/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip6/::1/udp/55621/quic/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip6/::1/udp/55621/quic-v1/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
Listening on: /ip6/::1/udp/56270/quic-v1/webtransport/certhash/uEiDcHLhuZwUZ7zHnvO-O38Xj_5IohFefXo0JOA4AIxEn3A/certhash/uEiCqnFKTggBe3-KbC5IBQYnxovaJWdmvm2IxCYGzyGqItQ/p2p/12D3KooWDCm6EF7TLGGV3h34G7zbBLgiPagbXaFK6VxPM3vaod6s
```

::: info
**Tip**
If you get errors related to missing packages, run `go mod tidy`, then try `go run .` again.
:::

The first line of output is showing us our PeerID which can be safely shared with anyone. The next lines are multiaddress lines which define ways to connect to us via IPv4, IPv6, a couple addresses, and a variety of transports. If this sounds like a lot, don't worry, we're going over transports in the next step!

## Defining transports

With libp2p [transports](https://docs.libp2p.io/concepts/transports/overview/) allow us to connect to other peers in a variety of ways and [multiaddresses](https://docs.libp2p.io/concepts/fundamentals/addressing/) contain information on how to connect to a peer like their PeerID, IP address, and transport.

Currently with go-libp2p our supported transports looks a bit like like this:

| WebTransport | WebRTC | QUIC | TCP | WebSocket |
| ------------ | ------ | ---- | --- | --------- |
| ✅           | ❌     | ✅   | ✅  | ✅        |

Currently our node is already listening locally on a variety of transports, but with more explicit configuration you can get some control over which transports are used, what addresses/ports to listen on, and how they're configured.

WebRTC is not yet supported, so we'll go over TCP, QUIC, and WebTransport. WebSockets are supported however, not covered in this guide.

### TCP

To support libp2p connections over TCP you need to add the following include to your header:

```go
tcpTransport "github.com/libp2p/go-libp2p/p2p/transport/tcp"
```

Locate the lines where we defined our libp2p option `libp2p.Identity(privk)`, and add the following options to the list:

```go
libp2p.Transport(tcpTransport.NewTCPTransport),
libp2p.ListenAddrStrings("/ip4/0.0.0.0/tcp/9090"),
```

What we've done here is explicitly told the libp2p library that we're going to be using a TCP transport on port 9090, and we'd like to listen on all interfaces. Port 9090 was chosen arbitrarily, you can use any port you'd like.

Done correctly you should end up with an options list which looks like the following:

```go
opts = append(opts,
	libp2p.Identity(privk),
	libp2p.Transport(tcpTransport.NewTCPTransport),
	libp2p.ListenAddrStrings("/ip4/0.0.0.0/tcp/9090"),
)
```

### QUIC

To support libp2p connections over [QUIC](https://docs.libp2p.io/concepts/transports/quic/) you need to add the following include to your header:

```go
quicTransport "github.com/libp2p/go-libp2p/p2p/transport/quic"
```

Go to the libp2p options list outlined in the [TCP section](#TCP) of this guide and add the following option:

```go
libp2p.Transport(quicTransport.NewTransport),
```

Next, you'll need to add a listen address string as well (similar to the [TCP section](#TCP)), if you've also added the TCP transport, your `ListenAddrStrings` line may look like this:

```go
libp2p.ListenAddrStrings("/ip4/0.0.0.0/tcp/9090", "/ip4/0.0.0.0/udp/9091/quic-v1"),
```

This string is saying to listen on all interfaces, on UDP port 9091.

### WebTransport

To support libp2p connections over [WebTransport](https://docs.libp2p.io/concepts/transports/webtransport/) you need to add the following include to your header:

```go
webTransport "github.com/libp2p/go-libp2p/p2p/transport/webtransport"
```

Go to the libp2p options list outlined in the [TCP section](#TCP) of this guide and add the following option:

```go
libp2p.Transport(webTransport.New),
```

Next, you'll need to add a listen address string as well (similar to the [TCP section](#TCP)), if you've also added the TCP and QUIC transports, your `ListenAddrStrings` line may look like this:

```go
libp2p.ListenAddrStrings("/ip4/0.0.0.0/tcp/9090", "/ip4/0.0.0.0/udp/9091/quic-v1", "/ip4/0.0.0.0/udp/9092/quic-v1/webtransport"),
```

Hopefully you see the pattern here, but this new entry is effectively saying "listen on UDP port 9092 for WebTransport connections".

::: info
**Tip**
If you wanted to support [IPv6](https://en.wikipedia.org/wiki/IPv6), copy all the entries above, and change "ip4" to "ip6". You'll end up with 3 ip4 entries and 3 ip6 entries, now you support both IPv4 and IPv6.
:::

## Discovery

So now that we have our libp2p node listening on our specified ports over the specified transports, how do we get other libp2p nodes to discover us? In this guide we'll go over a way to be discovered: a [Kademlia distributed hash table](https://github.com/libp2p/specs/blob/master/kad-dht/README.md) (DHT).

### Global Discovery with Kademlia DHT

Often you'll want to connect to peers who aren't on the local network, this is where the [Kademlia DHT](https://curriculum.pl-launchpad.io/curriculum/libp2p/dht/) comes in. Using a discovery service tag, we'll identify ourselves as a type of peer, and also look for peers also identifying by the same tag. First let's add the following to our includes list:

```go
"context"
"sync"
"time"

"github.com/libp2p/go-libp2p/core/host"
dht "github.com/libp2p/go-libp2p-kad-dht"
discovery "github.com/libp2p/go-libp2p/p2p/discovery/util"
"github.com/multiformats/go-multiaddr"
"github.com/libp2p/go-libp2p/core/network"
"github.com/libp2p/go-libp2p/core/peer"
"github.com/libp2p/go-libp2p/p2p/discovery/routing"
```

Next, we'll need a couple constants:

```go
// DiscoveryInterval is how often we search for other peers via the DHT.
const DiscoveryInterval = time.Second * 10

// DiscoveryServiceTag is used in our DHT advertisements to discover
// other peers.
const DiscoveryServiceTag = "universal-connectivity"
```

`DiscoveryInterval` can be set to whatever length you wish. It determines how often we'll search the DHT. We'll use this value in the second of these two functions:

```go
// Borrowed from https://medium.com/rahasak/libp2p-pubsub-peer-discovery-with-kademlia-dht-c8b131550ac7
// NewDHT attempts to connect to a bunch of bootstrap peers and returns a new DHT.
// If you don't have any bootstrapPeers, you can use dht.DefaultBootstrapPeers
// or an empty list.
func NewDHT(ctx context.Context, host host.Host, bootstrapPeers []multiaddr.Multiaddr) (*dht.IpfsDHT, error) {
	var options []dht.Option

	// if no bootstrap peers, make this peer act as a bootstraping node
	// other peers can use this peers ipfs address for peer discovery via dht
	if len(bootstrapPeers) == 0 {
		options = append(options, dht.Mode(dht.ModeServer))
	}

	// set our DiscoveryServiceTag as the protocol prefix so we can discover
	// peers we're interested in.
	options = append(options, dht.ProtocolPrefix("/"+DiscoveryServiceTag))

	kdht, err := dht.New(ctx, host, options...)
	if err != nil {
		return nil, err
	}

	if err = kdht.Bootstrap(ctx); err != nil {
		return nil, err
	}

	var wg sync.WaitGroup
	// loop through bootstrapPeers (if any), and attempt to connect to them
	for _, peerAddr := range bootstrapPeers {
		peerinfo, _ := peer.AddrInfoFromP2pAddr(peerAddr)

		wg.Add(1)
		go func() {
			defer wg.Done()
			if err := host.Connect(ctx, *peerinfo); err != nil {
				fmt.Printf("Error while connecting to node %q: %-v", peerinfo, err)
				fmt.Println()
			} else {
				fmt.Printf("Connection established with bootstrap node: %q", *peerinfo)
				fmt.Println()
			}
		}()
	}
	wg.Wait()

	return kdht, nil
}

// Borrowed from https://medium.com/rahasak/libp2p-pubsub-peer-discovery-with-kademlia-dht-c8b131550ac7
// Search the DHT for peers, then connect to them.
func Discover(ctx context.Context, h host.Host, dht *dht.IpfsDHT, rendezvous string) {
	var routingDiscovery = routing.NewRoutingDiscovery(dht)

	// Advertise our addresses on rendezvous
	discovery.Advertise(ctx, routingDiscovery, rendezvous)

	// Search for peers every DiscoveryInterval
	ticker := time.NewTicker(DiscoveryInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:

			// Search for other peers advertising on rendezvous and
			// connect to them.
			peers, err := discovery.FindPeers(ctx, routingDiscovery, rendezvous)
			if err != nil {
				panic(err)
			}

			for _, p := range peers {
				if p.ID == h.ID() {
					continue
				}
				if h.Network().Connectedness(p.ID) != network.Connected {
					_, err = h.Network().DialPeer(ctx, p.ID)
					if err != nil {
						fmt.Printf("Failed to connect to peer (%s): %s", p.ID, err.Error())
						fmt.Println()
						continue
					}
					fmt.Println("Connected to peer", p.ID.Pretty())
				}
			}
		}
	}
}
```

Here we have two functions, `NewDHT` and `Discover`. `NewDHT` creates an [IpfsDHT](https://pkg.go.dev/github.com/libp2p/go-libp2p-kad-dht#IpfsDHT) object which we can pass to `Discover`. What `Discover` does is every `DiscoveryInterval` it will search the DHT for new peers to connect to, and attempt a connection.

In our `main()` function, we put the following two blocks  below the block where we create the peer:

```go
// Setup DHT with empty discovery peers so this will be a discovery peer for other
// peers. This peer should run with a public ip address, otherwise change "nil" to
// a list of peers to bootstrap with.
dht, err := NewDHT(context.TODO(), h, nil)
if err != nil {
	panic(err)
}

// Setup global peer discovery over DiscoveryServiceTag.
go Discover(context.TODO(), h, dht, DiscoveryServiceTag)
```

And that's it! Your node will now utilize the DHT to make itself discoverable and discover other peers, provided they're using the same `DiscoveryServiceTag` as you.

### Announcing External Addresses

You might have noticed in the addresses listed after running `go run .` that you don't see your public IP address listed. Instead you might see a local address or two. This means your node isn't advertising it's public IP address (however if you do see your public facing IP address, you may not need this step). We can resolve this by creating a list of addressess we want to announce.

The following code lives in our `main()` function beneath `var opts []libp2p.Option`:
```go
var opts []libp2p.Option // here for reference, don't copy this line

announceAddrs := []string{"/ip4/1.2.3.5/tcp/9090", "/ip4/1.2.3.5/udp/9091/quic-v1"} // Set to your external IP address for each transport you wish to use.
var announce []multiaddr.Multiaddr
	if len(announceAddrs) > 0 {
	for _, addr := range announceAddrs {
		announce = append(announce, multiaddr.StringCast(addr))
	}
	opts = append(opts, libp2p.AddrsFactory(func([]multiaddr.Multiaddr) []multiaddr.Multiaddr {
		return announce
	}))
}
```

With this code we can guarantee we announce exactly how we want other nodes to connect to us by modifying `announceAddrs`.

:::warning
**Note**
You must modify `announceAddrs` to use your own IP address in each entry, and add an entry for each transport. This code is populated with dummy IPs and only two transports.
:::

:::info
**Tip**
You can use an address such as `/dns4/mydomain.com/tcp/9090` to announce "you can find me using DNS over IPv4 at mydomain.com to connect to me over TCP port 9090".
:::


## Communicating

Now that we can create a peer that's connectable and connect to other peers, let's communicate. We're going to communicate over [PubSub](https://docs.libp2p.io/concepts/pubsub/overview/) which is short for "publish subscribe". PubSub, specifically [GossipSub](https://docs.libp2p.io/concepts/pubsub/overview/#gossip), will allow us to subscribe and publish to topics of our choosing. First, add this to your include list in `main.go`:

```go
pubsub "github.com/libp2p/go-libp2p-pubsub"
```

Next, let's create our [PubSub object](https://pkg.go.dev/github.com/libp2p/go-libp2p-pubsub#PubSub) and create a [Topic object](https://pkg.go.dev/github.com/libp2p/go-libp2p-pubsub#Topic) which we'll use for both publishing and subscribing. Put the follow code in your main function beneath the code to initialize the peer:

```go
// Create a new PubSub service using the GossipSub router.
ps, err := pubsub.NewGossipSub(context.TODO(), h)
if err != nil {
	panic(err)
}

// Join a PubSub topic.
topicString := "UniversalPeer" // Change "UniversalPeer" to whatever you want!
topic, err := ps.Join(DiscoveryServiceTag+"/"+topicString)
if err != nil {
	panic(err)
}
```

In the above code you can change the topic you're joining by simply changing `topicString` to whatever you'd like.

### Publishing

Publishing to our topic is quite simple with `topic.Publish`:

```go
err := topic.Publish(context.TODO(), []byte("Hello world!"))
```

For this guide, we're going to spawn a [goroutine](https://go.dev/tour/concurrency/1) which simply publishes the current time every 5 seconds. Add the following below our other PubSub blocks:

```go
// Publish the current date and time every 5 seconds.
go func() {
	for {
		err := topic.Publish(context.TODO(), []byte(fmt.Sprintf("The time is: %s", time.Now().Format(time.RFC3339))))
		if err != nil {
			panic(err)
		}
		time.Sleep(time.Second * 5)
	}
}()
```

### Subscribing

The final step is to subscribe to the topic so we can actually recieve messages on the topic. Add the following code to the end of the `main` function:

```go
// Subscribe to the topic.
sub, err := topic.Subscribe()
if err != nil {
	panic(err)
}

for {
	// Block until we recieve a new message.
	msg, err := sub.Next(context.TODO())
	if err != nil {
		panic(err)
	}
	fmt.Printf("[%s] %s", msg.ReceivedFrom, string(msg.Data))
	fmt.Println()
}
```

This code will output whatever it recieves on our PubSub topic we set earlier. If you run two copies of the software at once, you should see output like this:

```
[12D3KooWLZVboYR7Ba8BYycTa5zkTbLc9tnL3aed2YTotB66L2MD] The time is: 2023-05-28T13:21:57-04:00
[12D3KooWAiy4cC9HVv3C8NWYL3dFH1StZ1xGYK4UKrxrtmZVAVfo] The time is: 2023-05-28T13:22:00-04:00
[12D3KooWLZVboYR7Ba8BYycTa5zkTbLc9tnL3aed2YTotB66L2MD] The time is: 2023-05-28T13:22:02-04:00
[12D3KooWAiy4cC9HVv3C8NWYL3dFH1StZ1xGYK4UKrxrtmZVAVfo] The time is: 2023-05-28T13:22:05-04:00
[12D3KooWLZVboYR7Ba8BYycTa5zkTbLc9tnL3aed2YTotB66L2MD] The time is: 2023-05-28T13:22:07-04:00
```

:::info
**Tip**
You can run two copies of the software by building it with `go build .`, and also ensure you're using a unique `identity.key` file for each copy running. If you run multiple copies on the same PC you may have port conflicts unless you change them in some way.
:::

## Conclusion

After following this guide you now have a libp2p node which can communicate with other libp2p nodes over PubSub. Using this stack you can greate fully peer-to-peer applications be it a chat app (like [libp2p/universal-connecitvity](https://github.com/libp2p/universal-connectivity)), game, crypto wallet, video player, anything at all!

libp2p is used as a foundational building block in [IPFS](https://ipfs.tech) and [Filecoin](https://filecoin.io), so make sure to dream big 🚀. Together we can build a resilient scalable world.

### Links & Resources

- [TheDiscordian/go-libp2p-peer](https://github.com/TheDiscordian/go-libp2p-peer) (the code from this guide all bundled into one place)
- [libp2p/universal-connecitvity](https://github.com/libp2p/universal-connectivity) (bigger examples in Rust / JS / Go, taking this example to the next level as a series of chat clients)
- [libp2p Docs](https://docs.libp2p.io) (*the* destination for libp2p information)
- [libp2p Forums](https://discuss.libp2p.io/) (a community of developers building on and with libp2p)
