---
title: "TLS"
description: Learn about TLS 1.3 in libp2p.
weight: 130
aliases:
    - "/concepts/secure-comm/tls"
---

TLS (Transport Layer Security) is one of the security handshakes used to secure transports
that don't have built-in security (e.g. TCP, WebSocket). [Noise](/concepts/secure-comm/noise.md), an alternative to
TLS, is also another security handshake used to secure transports.

## What is TLS?

TLS (Transport Layer Security) is a cryptographic protocol that establishes a
secure data channel. TLS provides encryption, authentication, and data integrity.

During the TLS handshake, a secure connection is established between a client
and a server. After the handshake completes, both sides have derived a key
(the TLS master secret) that's only known to the two parties and is then used to
encrypt application data sent over the channel.

### What is TLS 1.3?

TLS 1.3 is a new version of the TLS protocol, published in 2018 in
[RFC 8446](https://www.rfc-editor.org/rfc/rfc8446). It brings several
improvements over TLS 1.2: the latency of a handshake was brought
down from 2 to 1 network round trips (in the typical case), the privacy
properties were improved by encrypting the certificates, and the protocol
was made simplified to reduce implementation complexity.

## TLS 1.3 in libp2p

**libp2p doesn't use TLS versions older than 1.3.**

### Handshake

libp2p uses the TLS 1.3 handshake to establish a secure connection between two peers.
Peers authenticate each other's libp2p peer ID during the handshake.

TLS 1.3 is identified during protocol negotiation with the following protocol
ID: `/tls/1.0.0`.

Peer authentication works by encoding the public key into the TLS certificate.
We designed the system to authenticate key types usually not
supported by TLS stacks, such as sepc256k1 (a key type that can be used for
libp2p keys).

When processing the TLS certificate, nodes derive the peer ID from the public key that
they received. The node initiating the connection checks that it matches the peer ID of the node
it intended to connect to.

{{< alert icon="💡" context="note" text="See the TLS <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/tls/tls.md\">technical specification</a> for more details." />}}
