---
title: "Multistream Select"
description: "Multistream Select is used to negotiate the protocol to be spoken on a connection or stream."
weight: 26
---

## Overview

[Multistream Select](https://github.com/multiformats/multistream-select) is a protocol for
protocol multiplexing that allows for the negotiation of different protocols between two
peers.

Peers use Multistream Select at various places to select the protocols to use for a
libp2p connection, including 
[security](../../secure-comm/overview.md), and [stream multiplexing](../../multiplex/overview.md)
as necessary. The [protocol negotiation](../core-abstractions/connections#protocol-negotiation)
and [upgrade process](../core-abstractions/connections#upgrading-connections) are explained
further in the [connections document](../core-abstractions/connections.md).

{{< alert icon="💡" context="note" text="See the multistream-select <a class=\"text-muted\" href=\"https://github.com/multiformats/multistream-select\">technical specification</a> for more details." />}}
