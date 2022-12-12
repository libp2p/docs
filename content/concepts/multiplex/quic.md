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
streams. This solves the problem of HOL (head-of-line) blocking: If a packet contain stream
data for one stream is lost, this only blocks progress on this one stream. All other streams
can still make progress.

