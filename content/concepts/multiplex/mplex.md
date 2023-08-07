---
title: "mplex"
description: "mplex is a simple stream multiplexer that was developed for libp2p."
weight: 170
---

## What is mplex?

mplex is a simple stream multiplexer that was designed in the early days of libp2p.
It is a simple protocol that does not provide many features offered by other
stream multiplexers. Notably, mplex does not provide flow control, a feature which
is now considered critical for a stream multiplexer.

mplex runs over a reliable, ordered pipe between two peers, such as a TCP connection.
Peers can open, write to, close, and reset a stream. mplex uses a message-based framing
layer like [yamux]({{< ref "/concepts/multiplex/yamux.md" >}}), enabling it to multiplex different
data streams, including stream-oriented data and other types of messages.

### Drawbacks

mplex does not have any flow control.
> Backpressure is a mechanism to prevent one peer from overwhelming a slow time consuming the data.

mplex also doesn't limit how many streams a peer can open.

{{< alert icon="" context="">}}
**Yamux should be used over mplex in libp2p**. As it natively supports flow control, it is better suited for applications that require the transfer of large amounts of data.

Until recently, the reason mplex was still supported was compatibility with js-libp2p,
which didn't have yamux support.
Now that
[js-libp2p has gained yamux support](https://github.com/ChainSafe/js-libp2p-yamux/releases/tag/v1.0.0),
mplex should only be used to provide backward-compatibility with legacy nodes.
{{< /alert >}}

{{< alert icon="💡" context="note" text="See the mplex <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/mplex\">technical specification</a> for more details." />}}
