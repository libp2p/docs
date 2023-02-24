---
title: "Multistream Select"
description: "Multistream Select is used to negotiate the protocol to be spoken on a connection or stream."
weight: 26
---

## Overview

[Multistream Select](https://github.com/multiformats/multistream-select) is a
protocol negotiation protocol. It allows two peers to negotiate the next spoken
protocol on a connection or stream.

Peers use Multistream Select at various places to select the protocols to use on
a libp2p connection or stream. Most prominently Multistream Select is used to
select the [security](../../secure-comm/overview.md) followed by [stream
multiplexing](../../multiplex/overview.md) protocol spoken on a connection. In
addition it is used to select the application protocol (e.g. Kademlia) on each
new stream on a given connection. The [protocol
negotiation](../core-abstractions/connections#protocol-negotiation) and [upgrade
process](../core-abstractions/connections#upgrading-connections) are explained
further in the [connections document](../core-abstractions/connections.md).

{{< alert icon="💡" context="note" text="See the multistream-select <a class=\"text-muted\" href=\"https://github.com/multiformats/multistream-select\">technical specification</a> for more details." />}}
