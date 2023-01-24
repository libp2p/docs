---
title: "Yamux"
description: "yamux is a multiplexing protocol designed by Hashicorp."
weight: 180
---

## What is Yamux?

[Yamux](https://github.com/hashicorp/yamux) (Yet another Multiplexer)
is a powerful stream multiplexer used in libp2p. It was
developed by Hashicorp for Go and built on top of TCP. Yamux
enables multiple parallel streams on a single TCP connection
and provides a high-level interface similar to SPDY, however
it is not compatible with it.

One of the key features of Yamux is its support for flow control
through backpressure. This mechanism helps to prevent data from
being sent faster than it can be processed. It allows
the receiver to specify an offset to which the sender can send
data, which increases as the receiver processes the data.
This helps prevent the sender from overwhelming the receiver,
especially when the receiver has limited resources or needs to
process complex data.

{{< alert icon="" context="">}}
**Yamux should be used over mplex in libp2p**, as mplex doesn't provide a mechanism to apply backpressure on the stream level.
{{< /alert >}}

### Resources

- [Yamux overview and a list of features](https://github.com/hashicorp/yamux#yamux).
- [Technical specification](https://github.com/hashicorp/yamux/blob/master/spec.md).
