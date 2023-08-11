---
title: "Early Multiplexer Negotiation"
description: "Early stream multiplexer negotiation is an optimization in libp2p where peers can negotiate which multiplexer to use during the security protocol handshake, saving one round trip."
weight: 162
---

## Vanilla stream multiplexer selection process

One of libp2p's main guarantees is that no data sent over the wire is unencrypted.
This means that transport protocols, like TCP or WebSocket, that don't support encryption
by default must complete a cryptographic handshake. This process of adding the secure channel
on top of the raw transport is called upgrading the connections and happens via the
[multistream-select protocol](https://github.com/multiformats/multistream-select).

In the unoptimized libp2p connection upgrade process, the security or encryption is negotiated
first. After that is agreed upon, the stream multiplexer is negotiated. Again this only happens
for transports that don't have native stream multiplexing.

A standard connection upgrade process that negotiates the secure channel first and the multiplexer
second
[is shown in a diagram here](https://github.com/libp2p/specs/tree/master/connections#upgrading-connections).

First, the security protocol is negotiated, then this protocol is used to perform a cryptographic
handshake. libp2p currently supports [Noise]({{< relref "/concepts/secure-comm/noise.md" >}}) and [TLS 1.3]({{< relref "/concepts/secure-comm/tls.md" >}}).
Once the cryptographic handshake completes, multistream-select runs again on top of
the secured connection to negotiate a steam multiplexer, like [yamux]({{< relref "/concepts/multiplex/yamux.md" >}}) or [mplex]({{< relref "/concepts/multiplex/mplex.md" >}}).

<!-- ADD DIAGRAM -->

## Early muxer negotiation

The libp2p project eliminates an unnecessary round trip in the standard negotiation protocol
for selecting a stream multiplexer. This is achieved by combining the steps of agreeing on a
secure channel and multiplexer. This is called "early" or "inlined" muxer negotiation.

Early muxer negotiation is a feature in libp2p that allows for the simultaneous selection of a
stream multiplexer during the cryptographic handshake of the TLS and Noise security protocols.
This is achieved by sharing a list of supported muxer protocols as a part of the handshake payload.

For example, if a libp2p node supports mplex and yamux, it will advertise both in the list.
This **eliminates an extra round trip**, improving TTFB (time to first byte) in the libp2p handshake.
Currently, this feature is only supported in go-libp2p and for TCP and WebSocket transports that do
not have native encryption or multiplexing.

<!-- ADD DIAGRAM -->

### ALPN extension in TLS

The [Application-Layer Protocol Negotiation (ALPN) extension](https://datatracker.ietf.org/doc/html/rfc7301)
is a feature of TLS that allows for the negotiation of application-layer protocols during the TLS handshake.
This allows the client and server to agree on the application-layer protocol for the rest of the TLS session.
ALPN is typically used to negotiate the application-layer protocol for applications that use TLS, such as HTTP/2
or QUIC. libp2p uses ALPN to negotiate the stream muxer and saves a roundtrip when upgrading a raw connection.

### Extension registry in Noise

Since there's no commonly used extension mechanism in Noise, libp2p defines an extension registry.
We then defined an extension to negotiate the stream multiplexer, that is conceptually the equivalent
of the ALPN extension in TLS.

> The extension registry is modeled after
> [RFC 6066](https://www.rfc-editor.org/rfc/rfc6066) (for TLS) and
> [RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000#section-19.21)
> (for QUIC).

More information is available in the
[Noise specification](https://github.com/libp2p/specs/blob/master/noise/README.md#libp2p-data-in-handshake-messages).

{{< alert icon="💡" context="note" text="See the inclined muxer negotiation <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/connections/inlined-muxer-negotiation.md\">specification</a> for more details." />}}
