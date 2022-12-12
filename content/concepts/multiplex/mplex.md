---
title: "mplex"
description: "mplex is a stream multiplexer developed for libp2p."
weight: 170
---

## What is mplex?

mplex is a stream multiplexer designed for libp2p.
It is a simple protocol that does not provide many features offered by other
stream multiplexers. Notably, mplex does not provide backpressure at the protocol
level.

mplex runs over a reliable, ordered pipe between two peers, such as a TCP connection
or a Unix pipe. Peers can open, write to, close, and reset a stream by sending messages
with the appropriate [flag value](https://github.com/libp2p/specs/tree/master/mplex#flag-values).

Every message in mplex consists of a header and a length of prefixed data
segment.

### Drawbacks

mplex does not support backpressure because it is designed to be more flexible and
extensible than other multiplexing protocols. Instead of using a flow control mechanism
like [yamux](yamux), mplex uses a message-based framing layer that enables it to multiplex
different types of data streams, including stream-oriented data, datagrams, and other types
of messages. This flexibility comes at the cost of some performance and reliability, as
mplex is less efficient at transferring large amounts of data than other multiplexing
protocols that support backpressure.

Additionally, mplex has no limits on how many streams a peer can open. This allows mplex
to support a wide range of applications and use cases, but it also means that mplex may
not be as efficient as other multiplexing protocols that limit the number of streams that
can be opened.

{{< alert icon="" context="">}}
**Yamux should be used over mplex in libp2p**. It is well-suited for applications that
require fast, reliable data transfer, such as real-time communication or streaming media,
as it is optimized for low-latency, high-bandwidth environments.

Until recently, the reason mplex was still supported was compatibility with js-libp2p,
which didn't have yamux support.
Now that
[js-libp2p has gained yamux support](https://github.com/ChainSafe/js-libp2p-yamux/releases/tag/v1.0.0),
mplex should only be used to provide backwards-compatibility with legacy nodes.
{{< /alert >}}

{{< alert icon="💡" context="note" text="See the mplex <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/mplex\">technical specification</a> for more details." />}}
