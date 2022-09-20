---
title: Secure Communication
weight: 2
---

Libp2p promotes modularity by design, meaning that different types 
of transports can be used as part of the networking stack to power 
communication across system or application. Some transports can 
include native channel encryption, like QUIC, while other transports 
that establish a raw connection, like TCP, lack native security.

Transports that are insecure in libp2p can use a channel upgrade 
to secure an underlying connection. Libp2p supports several security 
protocols, with the primary specifications for Noise and TLS 1.3.

## The Noise Protocol Framework

Libp2p implements a channel security handshake that follows the 
[Noise Protocol Framework](https://noiseprotocol.org/), a framework 
for constructing secure communication channels. The framework composes 
a small set of cryptographic primitives into patterns with verifiable 
security properties. Noise is not a protocol, but a format with different 
tradeoffs, similar to how RESTful services use REST as an architectural 
style interface. However, every Noise protocol will result in an authenticated, 
encrypted connection, which starts with a handshake between two peers, 
known as a dialer and listener in libp2p, over the underlying connection 
and follows a particular pattern.

The transport upgrader in libp2p is a component that layers security and 
stream multiplexing over raw connections, like TCP sockets. The transport 
upgrades uses a uses a protocol called `multistream-select` to negotiate 
which security and multiplexing protocols to use.

### Handshake

The dialer and listener exchange public keys during the handshake and perform 
Diffie-Hellman exchanges to arrive at a pair of symmetric keys that can be 
used to encrypt traffic over the channel. 

The libp2p identity keypair authenticates the DH key during the Noise handshake.

Following a successful handshake, the dialer and listener can use the resulting 
encryption keys to send bidirectional ciphertexts.

<!-- to add diagram -->

## TLS 1.3

As a successor to TLS 1.2, TLS 1.3 is a new encryption protocol, 
as defined in [RFC 8446](https://www.rfc-editor.org/rfc/rfc8446).

In libp2p, endpoints authenticate to their peers by encoding their public 
key into a X.509 certificate extension, but the protocol allows peers to 
use arbitrary key types and are not constrained to those for which signing 
of a X.509 certificates is specified.

During the handshake, TLS 1.3 takes only takes 1 round-trip as opposed to 3 
round-trips in TLS 1.2. The dialer and listener authenticate each other’s 
identity. As a criteria, endpoints **must** verify peer's identity. By extension, 
servers **must** require client authentication during the TLS handshake, and 
will abort a connection attempt if the client fails to authenticate.

Peers don’t use their host key to sign the X.509 certificate they send during the 
handshake. Instead, the host key is encoded into the libp2p Public Key Extension, 
which is carried in a self-signed certificate.

<!-- to add diagram -->
