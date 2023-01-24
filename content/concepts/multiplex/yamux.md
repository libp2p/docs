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
to which the sender can send data. This offset increases as the receiver consumes
the data, allowing the sender to send more data. This helps prevent the
sender from sending data faster than the receiver process it. This is especially important in
applications where the receiver might be slower at processing the data, such as when
the receiver is a low-powered device or when the data is complex and requires a lot of
processing.

{{< alert icon="" context="">}}
**Yamux should be used over mplex in libp2p**, as mplex doesn't provide a mechanism to apply backpressure on the stream level.
{{< /alert >}}

### Resources

- [Yamux overview and a list of features](https://github.com/hashicorp/yamux#yamux).
- [Technical specification](https://github.com/hashicorp/yamux/blob/master/spec.md).
