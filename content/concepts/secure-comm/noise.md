---
title: "Noise"
description: Learn about Noise in libp2p.
weight: 140
aliases:
    - "/concepts/secure-comm/noise"
---

## What is Noise?

The [Noise Protocol Framework](https://noiseprotocol.org/) is a set of tools for creating
secure communication protocols by combining cryptographic primitives into patterns with
verifiable security properties. It provides a high level of flexibility, allowing users to
choose from a range of cryptographic primitives and design patterns to suit their needs.
However, it is up to the user to carefully consider the tradeoffs and make informed decisions
to create a secure protocol.

## Noise in libp2p

noise-libp2p is an implementation of the Noise Protocol Framework used to establish a
secure channel between two peers in the libp2p network. The protocol ID is
`/noise`, and future versions of the specification may define new protocol IDs using the
"/noise" prefix (e.g., `/noise/2`).

When two peers connect, the transport upgrader negotiates
which security and [multiplexing](../multiplex/overview.md) protocols to use using
[multistream-select](https://github.com/multiformats/multistream-select).
> A successor to multistream-select, called multiselect 2, is in development, but noise-libp2p is
> compatible with the current upgrade process and multiselect 2.

### Handshake

Peers exchange public keys and perform a
[Diffie-Hellman exchange](https://en.wikipedia.org/wiki/Diffie%E2%80%93Hellman_key_exchange)
to generate a pair of symmetric keys that can be used to encrypt traffic during the handshake.
The static DH key used in the Noise protocol is authenticated using the libp2p identity keypair.

The Noise Protocol Framework provides several different handshake patterns to choose from, each
with its tradeoffs in terms of security and performance. noise-libp2p currently supports the
[`XX` pattern](https://noiseprotocol.org/noise.html#interactive-handshake-patterns-fundamental),
which provides strong security guarantees but is slower than other options. In the future,
additional handshake patterns may be added to noise-libp2p to support different use cases.

<!-- ADD DIAGRAM -->

#### The Noise Extension

In addition to the standard Noise handshake, noise-libp2p also includes an extension registry, which
allows for the exchange of additional data during the handshake process. This extension is used to
exchange libp2p-specific data such as [peer IDs](../fundamentals/peers.md##peer-id) and supported
protocol versions that enable [early stream muxer negotiation](../multiplex/early-negotiation).

<!-- ADD DIAGRAM -->

### Wire Format and Encryption

After the Noise handshake is completed, the resulting encryption keys send ciphertext messages
back and forth over the secure channel. The wire format for these messages and the cryptographic primitives
used for encryption is specified in the Noise specification. noise-libp2p currently uses the
[ChaCha20Poly1305](https://en.wikipedia.org/wiki/ChaCha20-Poly1305) AEAD cipher for encryption, which provides
both confidentiality and integrity protection. The wire format consists of a header and a payload, with the
payload being encrypted using the encryption keys derived from the Noise handshake.

{{< alert icon="💡" context="note" text="See the Noise <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/noise\">technical specification</a> for more details." />}}
