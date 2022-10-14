---
title: "yamux"
weight: 3
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
summary: Stream Multiplexing is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed so it can be output and used by separate applications.
---

# yamux

[yamux](https://github.com/hashicorp/yamux) is a multiplexing protocol designed by [Hashicorp](https://www.hashicorp.com/).

yamux offers more sophisticated flow control than mplex, and can scale to thousands of multiplexed streams over a single connection.
