---
title: "Yamux"
description: "yamux is a multiplexing protocol designed by Hashicorp."
weight: 180
---

## What is Yamux?

[Yamux](https://github.com/hashicorp/yamux) is a multiplexing protocol designed
by [Hashicorp](https://www.hashicorp.com/) for Go, built over TCP.
Yamux provides a high-level interface for working with SCTP streams. It is inspired
by [SPDY](https://en.wikipedia.org/wiki/SPDY), but it is not interoperable with it.

Yamux offers more sophisticated flow control than [mplex](mplex) while also supporting
backpressure, which is a mechanism that helps to prevent data from being sent faster
then it can be processed.

Backpressure allows the receiver of a data stream to specify an offset
to which the sender can send data. This offset increases as the receiver process the data,
allowing the sender to send more data. This helps prevent the
sender from sending more data than the receiver can handle, leading to buffering
and potentially causing the application to crash. This is especially important in
applications where the receiver might be slower at processing the data, such as when the
receiver is a low-powered device or when the data is complex and requires a lot of processing.

### Resources

- [Yamux overview and a list of features](https://github.com/hashicorp/yamux#yamux).
- [Technical specification](https://github.com/hashicorp/yamux/blob/master/spec.md).
