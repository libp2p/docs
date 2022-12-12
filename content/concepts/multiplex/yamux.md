---
title: "Yamux"
description: "yamux is a multiplexing protocol designed by Hashicorp."
weight: 180
---

## What is Yamux?

[Yamux](https://github.com/hashicorp/yamux) (Yet another Multiplexer) is a multiplexing
protocol initially designed by [Hashicorp](https://www.hashicorp.com/) for Go, built over
TCP. Yamux provides a high-level interface inspired
by [SPDY](https://en.wikipedia.org/wiki/SPDY), but it is not interoperable with it.

Yamux supports flow control through backpressure, which is a mechanism that helps to
prevent data from being sent faster than it can be processed.

One way to achieve backpressure is for the receiver to specify an offset
to which the sender can send data. This offset increases as the receiver process
the data, allowing the sender to send more data. This helps prevent the
sender from sending more data than the receiver can handle, leading to buffering
and potentially causing the application to crash. This is especially important in
applications where the receiver might be slower at processing the data, such as when
the receiver is a low-powered device or when the data is complex and requires a lot of
processing.

{{< alert icon="" context="">}}
**Yamux should be used over mplex in libp2p**. It is well-suited for applications that require
fast, reliable data transfer as it is optimized for low-latency, high-bandwidth environments.
{{< /alert >}}

### Resources

- [Yamux overview and a list of features](https://github.com/hashicorp/yamux#yamux).
- [Technical specification](https://github.com/hashicorp/yamux/blob/master/spec.md).
