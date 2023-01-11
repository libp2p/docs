---
title: "Early Multiplexer Negotiation"
description: "Early stream multiplexer negotiation is an optimization in libp2p where peers can negotiate which multiplexer to use during the security protocol handshake, saving one round trip."
weight: 162
---

## Vanilla stream multiplexer selection process

Peers upgrade raw transport connections by using the same
[multistream-selection](https://github.com/multiformats/multistream-select)
protocol to negotiate security and stream multiplexing.

First, the security protocol is negotiated, then this protocol is used to perform a cryptographic handshake. libp2p currently supports [Noise](../secure-comm/noise) and [TLS 1.3](../secure-comm/tls).
Once the cryptographic handshake completes, multistream-select runs again on top of
the secured connection to negotiate a steam multiplexer, like [yamux](yamux) or [mplex](mplex).

<!-- ADD DIAGRAM -->

## Early muxer negotiation

Early muxer negotiation is possible through the handshake of security protocols being able to negotiate higher-level
protocols. The early negotiation takes place as a list of supported stream muxers is shared during the security protocol
handshake, and a security protocol extension handles the stream muxer negotiation while it negotiates the secure channel
establishment. This saves 1 RTT during the libp2p handshake and, as a result, reduces the TTFB (time to first byte).

<!-- ADD DIAGRAM -->

### ALPN extension in TLS

The [Application-Layer Protocol Negotiation (ALPN) extension](https://datatracker.ietf.org/doc/html/rfc7301) is a feature of
TLS that allows for the negotiation of application-layer protocols during the TLS handshake. This allows the client and server
to agree on the application-layer protocol for the rest of the TLS session. ALPN is typically used to negotiate the application-layer protocol
for applications that use TLS, such as HTTP/2 or QUIC. libp2p uses ALPN to negotiate the stream muxer and saves a roundtrip when
upgrading a raw connection.

### Extension registry in Noise

Since there's no commonly used extension mechanism in Noise, libp2p defines an extension registry. We then defined an extension to negotiate the stream multiplexer, that is conceptually the equivalent of the ALPN extension in TLS.

> The extension registry is modeled after
> [RFC 6066](https://www.rfc-editor.org/rfc/rfc6066) (for TLS) and
> [RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000#section-19.21)
> (for QUIC).

More information is available in the
[Noise specification](https://github.com/libp2p/specs/blob/master/noise/README.md#libp2p-data-in-handshake-messages).
