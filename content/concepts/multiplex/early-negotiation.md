---
title: "Early Multiplexer Negotiation"
description: "Peers can use security protocol extenstions for early muxer negotiation."
weight: 162
---

## Typical connection upgrade process

Once peers establish a raw connection, they can upgrade their connection by running the multistream-selection
protocol. To do so, the dialing and listening peers use the same multistream-select protocol to negotiate the security
protocol that creates a secure channel over the raw connection, and the security protocol handshake is performed,
either [Noise](../secure-comm/noise) or [TLS 1.3](../secure-comm/tls). Multistream-select will run again on top of the
secure channel to negotiate a steam muxer, like [yamux](yamux).

<!-- ADD DIAGRAM -->

## Early muxer negotiation

Early muxer negotiation is possible through the handshake of security protocols being able to negotiate higher-level
protocols. The early negotiation takes place as a list of supported stream muxers is shared during the security protocol
handshake, and a security protocol extension handles the stream muxer negotiation while it negotiates the secure channel
establishment. This saves 1 RTT during the libp2p handshake.

<!-- ADD DIAGRAM -->

### ALPN extension in TLS

The [Application-Layer Protocol Negotiation (ALPN) extension](https://datatracker.ietf.org/doc/html/rfc7301) is a feature of
TLS allows for the negotiation of application-layer protocols during the TLS handshake. This allows the client and server
to agree on the application-layer protocol for the rest of the TLS session, enabling them to communicate using a standard
protocol and ensuring that the client and server are compatible. ALPN is typically used to negotiate the application-layer protocol
for applications that use TLS, such as HTTP/2 or QUIC. Libp2p uses ALPN to negotiate the stream muxer and saves a roundtrip when
upgrading a raw connection.

### Extension registry in Noise

Similar to ALPN, Noise in libp2p includes an extension registry which includes a collection of defined extensions that can be used
to extend the functionality of Noise. This has additional features and capabilities during the Noise handshake, including
negotiating a stream muxer.

> The extension registry is modeled after
> [RFC 6066](https://www.rfc-editor.org/rfc/rfc6066) (for TLS) and
> [RFC 9000](https://datatracker.ietf.org/doc/html/rfc9000#section-19.21)
> (for QUIC).

More information is available in the
[Noise specification](https://github.com/libp2p/specs/blob/master/noise/README.md#libp2p-data-in-handshake-messages).
