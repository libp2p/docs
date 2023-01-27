---
title: "Noise"
description: Learn about Noise in libp2p.
weight: 140
aliases:
    - "/concepts/secure-comm/noise"
---

## What is Noise?

The [Noise Protocol Framework](https://noiseprotocol.org/) is a widely-used encryption
scheme that allows for secure communication by combining cryptographic primitives into
patterns with verifiable security properties.

Learn more at https://noiseprotocol.org.

## Noise in libp2p

libp2p uses the Noise Protocol Framework to encrypt data between nodes and provide forward
secrecy. noise-libp2p is an implementation of the Noise Protocol Framework used to establish
a secure channel between two peers by exchanging keys and encrypting traffic during
the libp2p handshake process. After a successful Noise handshake, the resulting keys send
ciphertext messages back and forth over the secure channel. The wire format for these messages
and the cryptographic primitives used for encryption is specified in the
[libp2p-noise specification](https://github.com/libp2p/specs/tree/master/noise).

The noise-libp2p protocol ID is `/noise`, and future versions may define new protocol IDs
using the "/noise" prefix (e.g., `/noise/2`).

<!-- ADD DIAGRAM -->

{{< alert icon="💡" context="note" text="See the Noise <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/noise\">technical specification</a> for more details." />}}
