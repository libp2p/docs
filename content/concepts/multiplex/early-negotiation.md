---
title: "Early Multiplexer Negotiation"
description: "Peers can use security protocol extenstions for early muxer negotiation."
weight: 162
---

## Typical connection upgrade process

Peers upgrade raw transport connections by using the same
[multistream-selection](https://github.com/multiformats/multistream-select)
protocol to negotiate security and stream multiplexing.

First, security is established, and a security handshake is performed
either for [Noise](../secure-comm/noise) or [TLS 1.3](../secure-comm/tls).
Multistream-select will run again on top of
the secure channel to negotiate a steam muxer, like [yamux](yamux).

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

Similar to ALPN, Noise in libp2p introduces an extension registry that includes a collection of defined extensions used
to extend the functionality of Noise. This has additional features and capabilities during the Noise handshake, including
negotiating a stream muxer.

> The extension registry is modeled after
> [RFC 6066](https://www.rfc-editor.org/rfc/rfc6066) (for TLS) and
> [RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000#section-19.21)
> (for QUIC).

More information is available in the
[Noise specification](https://github.com/libp2p/specs/blob/master/noise/README.md#libp2p-data-in-handshake-messages).
