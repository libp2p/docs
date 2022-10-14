---
title: "QUIC"
weight: 4
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
summary: Stream Multiplexing is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed so it can be output and used by separate applications.
---

# QUIC

QUIC is a [transport](/concepts/transport/) protocol that contains a "native" stream multiplexer. 
libp2p will automatically use the native multiplexer for streams using a QUIC transport. View the [QUIC
section](/concepts/transport/quic/) to learn about QUIC.
