---
title: "Yamux"
description: "yamux is a multiplexing protocol designed by Hashicorp."
weight: 180
---

## What is Yamux?

[Yamux](https://github.com/hashicorp/yamux) is a multiplexing protocol designed
by [Hashicorp](https://www.hashicorp.com/) for Go. It is built over
[SCTP (Stream Control Transmission Protocol)](https://en.wikipedia.org/wiki/Stream_Control_Transmission_Protocol), which is a transport layer protocol
that provides reliable, message-oriented communication with congestion control.
Yamux provides a high-level interface for working with SCTP streams. It is inspired
by [SPDY](https://en.wikipedia.org/wiki/SPDY), but is not interoperable with it.

Yamux offers more sophisticated flow control than [mplex](mplex), and can scale
to thousands of multiplexed streams over a single connection.

### Resources

- [Yamux overview and a list of features](https://github.com/hashicorp/yamux#yamux).
- [Technical specification](https://github.com/hashicorp/yamux/blob/master/spec.md).
