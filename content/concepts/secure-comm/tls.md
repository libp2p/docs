---
title: "TLS"
description: Learn about TLS 1.3 in libp2p.
weight: 130
aliases:
    - "/concepts/secure-comm/tls"
---

## What is TLS?

TLS (Transport Layer Security) is a cryptographic protocol that allows the establishment
of a secure data channel.  TLS provides encryption, authentication,
and data integrity.

During the TLS handshake, a secure context is established between a client
and a server. After the handshake completes, both sides have derived a key
(the TLS master secret) that's only known to the two parties, and is from then
on used to encrypt application data sent over the channel.

### What is TLS 1.3?

TLS 1.3 is a new version of the TLS protocol, published 2018 in
[RFC 8446](https://www.rfc-editor.org/rfc/rfc8446). It brings several
improvements over TLS 1.2: the latency of a handshake was brought
down from 2 to 1 network round trips (in the common case), the privacy
properties were improved by encrypting the certificates, and the protocol
was made simplified to reduce implementation complexity.

TLS 1.3 is also used as part of the Noise protocol framework to provide secure
and private communication between nodes. Learn more about Noise [here](noise).

{{< alert icon="💡" context="note" text="For context, TLS 1.0 was defined as <a class=\"text-muted\" href=\"https://www.rfc-editor.org/info/rfc2246\">RFC 2246</a> in 1996, TLS 1.1 was  defined as <a class=\"text-muted\" href=\"https://www.rfc-editor.org/info/rfc4346\">RFC 4346</a> in 2006, and TLS 1.2 was defined as <a class=\"text-muted\" href=\"https://www.rfc-editor.org/info/rfc4346\">RFC 5246</a> in 2008." />}}

### Comparing TLS 1.3 to TLS 1.2

The primary distinction between TLS 1.3 from TLS 1.2 is that a TLS 1.3 connection takes
one less round trip.

{{< alert icon="💡" context="info" text="The number of round trips required for a TLS 1.2 handshake can vary; when combined with TCP (SYN and SYN-ACK), the TLS 1.2 handshake takes three round trips." />}}

**A typical TLS 1.2 handshake is as follows:**

1. The client sends a `ClientHello` message with a list of supported cipher suites to
   indicate to the server that it wants to connect using TLS 1.2.

2. The server responds with a `ServerHello` message which is a result of the following:
   - checking if the client's TLS version is valid;
   - choosing the preferred cipher suite from the list that the client provided and the
     associated key share using a `ServerKeyExchange`;
     > The key is based on the cipher suite selected. TLS recommends ECDHE as the key exchange
     > algorithm, but supports other key exchange algorithms like RSA.
     > If ECDHE is chosen:
     >
     > - the associated algorithm parameters for ECDHE would be used to generate a server signature;
     > - key shares are mixed with the Elliptic Curve Diffie Hellman algorithm.

   - providing a TLS certificate signed by a trusted CA (certificate authority).
     > A browser typically requires a server to present a valid TLS certificate signed by a trusted CA.

3. The client verifies the server's certificate and generates a premaster secret key, which
   is used to encrypt the data being transferred. The client encrypts the secret key with the
   server's public key (using the cipher suite) and sends a `ClientKeyExchange` message to the
   server.

4. The server decrypts the premaster secret key using its private key and uses it with its
   private keys to generate sessions keys to establish an encrypted connection with the client.
   The server also sends a `Finished` message to indicate that the key exchange was successful
   and the session keys have been generated.

5. The client sends a `Finished` message to confirm that the handshake is complete.

#### Benefits of TLS 1.3

TLS 1.3 uses more robust encryption algorithms, such as AES-GCM. They provide
better security and faster performance than the algorithms used in TLS 1.2. TLS 1.3
also eliminates the use of less secure cryptographic techniques still used in TLS 1.2,
such as SHA-1.

  > Over the years, there have been vulnerabilities identified in a variety of encryption
  > algorithms. To guarantee safe communication, TLS 1.3 only supports
  > 5 cipher suites, as opposed to the 37 supported in TLS 1.2. They are:
  >
  > - TLS_CHACHA20_POLY1305_SHA256
  > - TLS_AES_128_GCM_SHA256
  > - TLS_AES_256_GCM_SHA384
  > - TLS_AES_128_CCM_8_SHA256
  > - TLS_AES_128_CCM_SHA256

In TLS 1.3, a client can include all the necessary information, including the key share,
in the first `ClientHello` message by assuming which key agreement algorithm the
server will choose due to the limited cipher suites. This saves one round trip as the server
can generate its key from the first message.

As a result, TLS 1.3 uses a new handshake protocol that allows for faster and more efficient
establishment of encrypted connections. TLS 1.3 also introduces new features, such as
certificate compression and support for cryptographic keys larger than 4096 bits.

## TLS 1.3 in libp2p

To use TLS 1.3 in libp2p, a peer must first establish a TLS 1.3 connection with another peer
using the handshake protocol. Once the handshake is complete, the peers can use the encrypted
connection to exchange data securely and privately.

### Handshake

libp2p uses TLS 1.3 handshake to establish a secure connection between two peers. 
Peers authenticate each other’s libp2p peer ID during the handshake.

TLS 1.3 is identified during protocol negotiation with the following protocol
ID: `/tls/1.0.0`.

In libp2p, peer authentication works by encoding the public key into the TLS certificate.
We designed the system such that we can authenticate key types that are usually not
supported by TLS stacks, such as sepc256k1 (which is a key type that can be used for
libp2p keys).

{{< alert icon="💡" context="note" text="X.509 is an <a class=\"text-muted\" href=\"https://www.itu.int/en/Pages/default.aspx\"> ITU</a> standard defining the format of public key certificates that use asymmetric cryptography for authentication. Certificate extensions were introduced in version 3 of the X.509 standard, which is a field that offers a set of additional attributes that can be included in the certificate to provide more information about the certificate's subject, such as the certificate's intended purpose, the cryptographic algorithms that the certificate uses, and other relevant details."/>}}

For arbitrary key types, an endpoint needs to encode its host key using the
[libp2p public key extension](https://github.com/libp2p/specs/blob/master/tls/tls.md#libp2p-public-key-extension)
which is carried in a self-signed certificate to prove ownership of its host key.
The libp2p public key extension is an X.509 extension with the Object Identier
`1.3.6.1.4.1.53594.1.1`. A certificate must include the libp2p public key extension
to be marked valid.

The endpoint generates a signature using its private host key and shares it along with
its public host key for verification. The signature proves that the peer owned
the private host key when signing the certificate.

The public host allows the other peer to calculate the peer ID of the endpoint it
connects to. Failed authentication would immediately terminate the secure connection
establishment.

{{< alert icon="💡" context="note" text="See the TLS <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/tls/tls.md\">technical specification</a> for more details." />}}
