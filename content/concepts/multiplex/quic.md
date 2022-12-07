---
title: "QUIC"
description: QUIC is a transport protocol that contains a native stream multiplexer.
weight: 181
---

## QUIC native multiplexing

QUIC is a [transport](../../transport/overview) protocol that contains a "native"
stream multiplexer. libp2p will automatically use the native multiplexer for streams
using a QUIC transport. View the [QUIC document](../../transports/quic/) to learn
about QUIC.

QUIC interleaves frames from multiple streams into one or more QUIC packets at the
transport layer. A single QUIC packet can include multiple frames from one or more
streams. Transport-layer multiplexing removes the HOL (head-of-line) blocking issue
in HTTP/2 as QUIC identifies each byte stream with a stream ID, unlike with TCP.

Because QUIC runs on UDP, which uses out-of-order delivery, each byte stream is transported
independently (through the most optimal route available.) However, QUIC still ensures the
in-order delivery of packets within the same byte stream. Using the stream ID, QUIC can
identify a lost packet, and unaffected byte streams can continue to transmit data.
