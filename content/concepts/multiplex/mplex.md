---
title: "Mplex"
description: "mplex is a stream multiplexer developed for libp2p."
weight: 170
---

## What is Mplex?

Mplex is a stream multiplexer designed for libp2p.
It is a simple protocol that does not provide many features offered by other
stream multiplexers. Notably, mplex does not provide backpressure at the protocol
level.

Mplex runs over a reliable, ordered pipe between two peers, such as a TCP socket
or a Unix pipe. Peers can open, write to, close, and reset a stream by sending messages
with the appropriate [flag value](https://github.com/libp2p/specs/tree/master/mplex#flag-values).

Every message (one byte) in mplex consists of a header and a length of prefixed data
segment.

{{< alert icon="💡" context="note" text="See the mplex <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/mplex\">technical specification</a> for more details." />}}
