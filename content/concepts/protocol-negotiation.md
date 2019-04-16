---
title: Protocols
weight: 3
---


"Protocol" is a word with plenty of meanings. When working with libp2p, we're mostly concerned
with a few kinds of protocols. 

[Transport protocols](/concepts/transport/) are provided by operating systems, language runtimes, library code, etc and are well-defined outside of libp2p. libp2p wraps transport protocols like TCP/IP in a common interface, to provide flexibility and future upgradability.

The kind of protocols this article is concerned with sit above the transport layer, and are sometimes
called "wire protocols" or "application protocols". Throughout this article, we'll call them **libp2p protocols**

These protocols are specific to some capability or functionality for a peer-to-peer system. This includes 
core "plumbing" protocols, like the ones [built into libp2p](#core-libp2p-protocols).

Most importantly, it includes the protocols that applications built with libp2p define for their
own use. When you build an application with libp2p, your application protocols will determine 
how your peers interact with each other.

## What is a libp2p protocol?

A libp2p protocol has these key features:

#### Protocol Ids

libp2p protocols have unique string identifiers, which are used in the [protocol negotiation](#protocol-negotiation) process when connections are first opened.

By convention, protocol ids have a path-like structure, with a version number as the final component:

```
/my-app/amazing-protocol/1.0.1
```

Breaking changes to your protocol's wire format or semantics should result in a new version
number. See the [protocol negotiation section](#protocol-neotiation) for more information about
how version selection works during the dialing and listening process.

{{% notice "info" %}}

While it's best to use the path-like structure described for protocol ids,
there is no technical requirement to do so. libp2p will treat any arbitrary
string as a valid protocol id.

{{% /notice %}}

#### Handler functions

To accept connections, a libp2p application will register handler functions for protocols using their protocol id with the
[switch][definition_switch] (aka "swarm"), or a higher level interface such as [go's Host interface](https://github.com/libp2p/go-libp2p-host/blob/master/host.go).

The handler function will be invoked when an incoming stream is tagged with the registered protocol id.
If you register your handler with a [match function](#using-a-match-function), you can choose whether
to accept non-exact string matches for protocol ids, for example, to match on [semantic major versions](#match-using-semver).


#### Binary streams

The "medium" over which a libp2p protocol transpires is a bi-directional binary stream with the following
properties:

- Bidirectional, reliable delivery of binary data
  - Each side can read and write from the stream at any time
  - Data is read in the same order as it was written
  - Can be "half-closed**, that is, closed for writing and open for reading, or closed for reading and open for writing 
- Backpressure
  - Readers can't be flooded by eager writers <!-- TODO(yusef) elaborate: how is backpressure implemented? is it transport-depdendent? -->
  
Behind the scenes, libp2p will also ensure that the stream is [secure](/concepts/secure-comms/) and efficiently
[multiplexed](/concepts/stream-multiplexing/). This is transparent to the protocol handler, which reads and writes
unencrypted binary data over the stream.

The format of the binary data and the mechanics of what to send when and by whom are all up to the protocol to
determine. For insipiration, some [common patterns](#common-pattern) that are used in libp2p's internal protocols
are outlined below.


## Protocol Negotiation

When dialing out to initiate a new stream, libp2p will send the protocol id of the protocol you want to use.
The listening peer on the other end will check the incoming protocol id against the registered protcol handlers.

If the listening peer does not support the requested protocol, it will end the stream, and the dialing peer can
try again with a different protocol, or possibly a fallback version of the initially requested protocol.

If the protocol is supported, the listening peer will echo back the protocol id as a signal that future data 
sent over the stream will
use the agreed protocol semantics.

This process of reaching agreement about what protocol to use for a given stream or connection is called
**protocol negotiation**. 


### Matching protocol ids and versions

When you register a protocol handler, there are two methods you can use.

The first takes two arguments: a protocol id, and a handler function. If an incoming stream request sends an exact
match for the protocol id, the handler function will be invoked with the new stream as an argument.

#### Using a match function

The second kind of protocol registration takes three arguments: the protocol id, a protocol match function, and the handler function.

When a stream request comes in whose protocol id doesn't have any exact matches, the protocol id will be passed through
all of the registered match functions. If any returns `true`, the associated handler function will be invoked.

This gives you a lot of flexibility to do your own "fuzzy matching" and define whatever rules for protocol matching
make sense for your application.

#### Match using semver

If you'd like to concurrently support a range of numbered versions, you may want to use semantic versioning (aka [semver](https://semver.org)).

In go-libp2p, a helper function called [`MultistreamSemverMatcher`](https://github.com/libp2p/go-libp2p-host/blob/master/match.go) can be used
as a protocol match function to see if an incoming request can be satisfied by the registered protocol version.

js-libp2p provides a [similar match function](https://github.com/multiformats/js-multistream-select/blob/master/src/listener/match-semver.js)
as part of [js-multistream-select](https://github.com/multiformats/js-multistream-select/)

### Dialing a specific protocol

## Core libp2p protocols

In addition to the protocols that you write when developing a libp2p application, libp2p itself defines several foundational protocols that are used for core features.

### Common patterns

The protocols described below all use [protocol buffers](https://developers.google.com/protocol-buffers/) (aka protobuf) to define message schemas.

Messages are exchanged over the wire using a very simple convention called [msgio](https://github.com/jbenet/go-msgio), which prefixes binary
message payloads with an integer that represents the length of the payload in bytes. The length is encoded as a [protobuf varint](https://developers.google.com/protocol-buffers/docs/encoding#varints)  (variable-length integer).


<!-- TODO(yusef): do we expose any kind of msgio + protobuf convenience functions for protocol construction? If so, link here. also, is there a spec for msgio in the abstract? -->

### Ping

**Protocol id**: `/ipfs/ping/1.0.0`

The ping protocol is a simple liveness check that peers can use to quickly see if another peer is online.

After the initial protocol negotiation, the dialing peer sends 32 bytes of random binary data. The listening
peer echoes the data back and closes the stream, and the dialing peer will verify the response and measure 
the latency between request and response.

### Identify

**Protocol id**: `/ipfs/id/1.0.0.0`



#### identify-push

### secio 

TODO: link to secure comms doc, secio spec

### kad-dht


### Circuit Relay


<!-- links -->

[definition_switch]: /reference/glossary/#switch
[repo_multistream-select]: https://github.com/multiformats/multistream-select

<!-- FIXME: the link below does not resolve. stub before merging -->
[concepts_connection_handshake]: /concepts/connections/#connection-handshake 
