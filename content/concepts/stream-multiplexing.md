---
title: Stream Multiplexing
---

Stream Multiplexing (_stream muxing_) is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed (_demuxed_) so it can be output and used by separate applications.

## Multiplexing 

Multiplexing is by no means unique to libp2p. Most communication networks involve some kind of multiplexing, as the transport medium is generally scarce and needs to be shared by many participants.

This is done to share a single TCP connection using unique port numbers to distinguish streams, between the multiple proceeses (such as kademlia and gossipsub) used by applications (such as ipfs) to make connection and transmission more efficient. With muxing, libp2p applications may have many separate streams of communication between peers, as well as have multiple concurrent streams open at the same time with a peer.

Stream multiplexing allows us to initialize and use the same [transport](/concepts/transport/) connection across the lifetime of our interaction with a peer. With muxing, we also only need to deal with [NAT traversal](/concepts/nat/) once to be able to open as many streams as we need, since they will all share the same underlying transport connection.

libp2p provides a common [interface](#interface) for stream multiplexers with several [implementations](#implementations) available. Applications can enable support for multiple multiplexers, which will allow you to fall back to a widely-supported multiplexer if a preferred choice is not supported by a remote peer.

## Where it fits in the libp2p stack

libp2p's multiplexing happens at the "application layer", meaning it's not provided by the operating system's network stack. However, developers writing libp2p applications rarely need to interact with stream multiplexers directly, except during initial configuration to control which modules are enabled.

### Switch / swarm

libp2p maintains some state about known peers and existing connections in a component known as the switch (or "swarm", depending on the implementation). The switch provides a dialing and listening interface that abstracts the details of which stream multiplexer is used for a given connection.

When configuring libp2p, applications enable stream muxing modules, which the switch will use when dialing peers and listening for connections. If the remote peers support any of the same stream muxing implementations, the switch will select and use it when establishing the connection. If you dial a peer that the switch already has an open connection to, the new stream will automatically be multiplexed over the existing connection.

Reaching agreement on which stream multiplexer to use happens early in the connection establishment process. Peers use [protocol negotiation](/concepts/protocols/#protocol-negotiation) to agree on a commonly supported multiplexer, which upgrades a "raw" transport connection into a muxed connection capable of opening new streams.

## Interface and Implementations

### Interface
The [stream multiplexing interface][interface-stream-muxing] defines how a stream muxing module can be applied to a connection and what operations are supported by a multiplexed connection.

### Implementations

There are several stream multiplexing modules available in libp2p. Please note that not all stream muxers are supported by every libp2p language implementation.

#### mplex

mplex is a protocol developed for libp2p. The [spec](https://github.com/libp2p/specs/tree/master/mplex) defines a simple protocol for multiplexing that is widely supported across libp2p language implementations:

- Go: [go-mplex](https://github.com/libp2p/go-mplex)
- Javascript: [js-mplex](https://github.com/libp2p/js-libp2p-mplex)
- Rust: [rust-libp2p mplex module](https://github.com/libp2p/rust-libp2p/tree/master/muxers/mplex)

#### yamux

[yamux](https://github.com/hashicorp/yamux) is a multiplexing protocol designed by [Hashicorp](https://www.hashicorp.com/).

yamux offers more sophisticated flow control than mplex, and can scale to thousands of multiplexed streams over a single connection.

yamux is currently supported in go and rust:

- Go: [go-smux-yamux](https://github.com/whyrusleeping/go-smux-yamux)
- Rust: [rust-libp2p yamux module](https://github.com/libp2p/rust-libp2p/tree/master/muxers/yamux).

#### quic

[QUIC][wiki-quic] is a [transport](/concepts/transport/) protocol that contains a "native" stream multiplexer. libp2p will automatically use the native multiplexer for streams using a quic transport.

quic is currently supported in go via [go-libp2p-quic-transport](https://github.com/libp2p/go-libp2p-quic-transport).

#### spdy

[SPDY][wiki-spdy] is a Google-developed protocol that was the precursor to HTTP/2. SPDY implements a stream multiplexer, which is supported by some libp2p implementations:

- Go: [go-smux-spdystream](https://github.com/whyrusleeping/go-smux-spdystream)
- Javascript: [js-libp2p-spdy](https://github.com/libp2p/js-libp2p-spdy)

#### muxado

[muxado](https://github.com/inconshreveable/muxado) is a go stream muxing library, supported by go-libp2p via [go-smux-muxado](https://github.com/whyrusleeping/go-smux-muxado).

<!-- links -->
[interface-stream-muxing]: https://github.com/libp2p/interface-stream-muxer

[repo-multistream-select]: https://github.com/multiformats/multistream-select

[wiki-quic]: https://en.wikipedia.org/wiki/QUIC
[wiki-spdy]: https://en.wikipedia.org/wiki/SPDY
