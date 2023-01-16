---
title: "Multistream Select"
description: "Multistream Select is used to negotiate and upgrade the protocol of a connection between two peers in libp2p."
weight: 26
---

## Overview

[Multistream Select](https://github.com/multiformats/multistream-select) is
a protocol for friendly protocol multiplexing that allows for the negotiation
of a [multicodec](https://github.com/multiformats/multicodec) between two entities.

> Multicodecs are codecs that can handle multiple different encoding formats.
> They are used to decode data and are self-describing, meaning they can identify
> the data format they are decoding. This capability allows nodes to support multiple
> protocols and efficiently switch between them depending on the task.

Multistream is a general concept and refers to the ability
to [multiplex multiple streams](../../multiplex/overview.md) of data over a single
connection. This allows for multiple independent channels of communication to be
established over a single connection rather than needing to open a separate
connection for each channel.

Multistream Select is a specific protocol built on top of the general
concept of Multistream. It is used to negotiate and upgrade the protocol of a
connection between two peers and to integrate new protocols as
they become available. The actual protocol is fairly simple - it is a Multistream
protocol with a Multistream header.

The header refers to the initial message sent by a peer to initiate the protocol
negotiation process. This message includes the protocol ID, `/multistream/1.0.0.`,
which indicates to the listening peer that a protocol negotiation process is about
to take place. Upon receiving this header, the listening peer responds with their
desired protocol header.

After both peers have sent their headers, both peers need to agree on the version
of the Multistream Select protocol to use for the connection. Both peers can exchange
protocol information and select the protocols to use for the connection, including
protocols for [security](../../secure-comm/overview.md) and
[stream multiplexing](../../multiplex/overview.md) if necessary. The
[protocol negotiation](../core-abstractions/connections#protocol-negotiation)
and [upgrade process](../core-abstractions/connections#upgrading-connections)
is explained further in the [connections document](../core-abstractions/connections.md).

## Protocol Select

[Protocol Select](https://github.com/libp2p/specs/pull/349) is a new
negotiation protocol that aims to improve and replace Multistream Select.
Multistream Select is prone to downgrade attacks and censorship, which is why
Protocol Select is being developed. Some other improvements include eliminating
the need for negotiating security protocols and reducing the number of round-trips
needed for stream multiplexer negotiation. Protocol Select also uses a binary
data format defined in a machine parseable schema language, making protocol
evolution and implementation more manageable and efficient.

{{< alert icon="" context="warning">}}
Protocol Select is in active development and has yet to be fully implemented in
libp2p. Follow the official specification development
[here](https://github.com/libp2p/specs/pull/349).
{{< /alert >}}

> Protocol Select will not be compatible with Multistream Select in its semantics
> as well as on the wire. Live libp2p-based networks, currently using Multistream Select,
> would need to follow a multiphased roll-out strategy detailed below to guarantee a
> smooth transition.

{{< alert icon="💡" context="note" text="See the multistream-select <a class=\"text-muted\" href=\"https://github.com/multiformats/multistream-select\">technical specification</a> for more details." />}}
