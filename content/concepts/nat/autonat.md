---
title: "AutoNAT"
description: "AutoNAT lets nodes discover if they are behind a NAT."
weight: 200
aliases:
    - "/concepts/autonat"
    - "/concepts/nat/autonat"
---

## Background

While the [identify protocol](/concepts/introduction/protocols/identify)
allows peers to inform each other about their observed network addresses,
sometimes these addresses are inaccessible as the peer may be located in a
private network (i.e., behind a NAT or a firewall).

{{< alert icon="" context="info">}}
Advertising addresses that are not reachable is detrimental for the health of a
P2P network, as other nodes will unsuccessfully try to dial those addresses wasting
compute and network resources.
{{< /alert >}}

To prevent this problem of advertising and dialing unreachable addresses,
libp2p has implemented a protocol called AutoNAT,
which allows nodes to determine whether or not they are behind a NAT.

## What is AutoNAT?

AutoNAT allows a node to request other peers to dial its presumed public addresses.

For private nodes located behind a NAT, it is strongly recommended:
to:

- Not advertise private addresses
- Get a reservation with a relay to improve connectivity to public networks
  and advertise relay addresses instead.

For public nodes, it is suggested to:

- Start a relay to assist other nodes
- Consider activating DHT server mode to improve connectivity to public
  networks.

If most of these dial attempts are successful, the node can be reasonably ascertained
that it is not behind a NAT. On the other hand, if most of these dial attempts fail,
it strongly indicates that a NAT is blocking incoming connections.

{{< alert icon="" context="">}}
Currently, AutoNAT cannot test individual addresses,
but a [proposal](https://github.com/libp2p/specs/issues/503) for AutoNAT v2 aims to
add this capability.
{{< /alert >}}

The AutoNAT protocol uses the protocol ID `/libp2p/autonat/1.0.0` and involves
the exchange of `Dial` and `DialResponse` messages.

To initiate the protocol, a node sends a `Dial` message to another peer containing
a list of multiaddresses. The peer then attempts to dial these addresses using a
different IP and peer ID than it uses for its regular libp2p connection.
If at least one of the dials is successful, the peer sends a `DialResponse` message
with the `ResponseStatus`: `SUCCESS` to the requesting node.

If all dials fail, the peer sends a `DialResponse` message with the `ResponseStatus`:
`E_DIAL_ERROR`. The requesting node can use the response from the peer to determine
whether or not it is behind a NAT.
> If the response indicates success, the node is likely not behind a NAT and does
> not need to use a relay server to improve its connectivity. If the response indicates
> an error, the node is likely behind a NAT and may need to use a
> [relay server](/concepts/autonat/dcutr) to communicate with other nodes in the network.

{{< alert icon="" context="caution">}}
To prevent
[certain types of attacks](https://www.rfc-editor.org/rfc/rfc3489#section-12.1.1),
libp2p implementations of AutoNAT must not dial any multiaddress that
is not based on the IP address of the requesting node AND must not accept dial
requests via relayed connections (because it is not possible to validate a node's
IP address that arrives via a relayed connection).

This is to prevent amplification attacks, in which an attacker provides many clients
with the same faked [MAPPED-ADDRESS](https://www.rfc-editor.org/rfc/rfc3489#section-11.2.1)
that points to the intended target, causing all traffic to be focused on the target.
{{< /alert >}}

<!-- ADD DIAGRAM -->

{{< alert icon="💡" context="note" text="See the AutoNAT <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/autonat/README.md\">technical specification</a> for more details." />}}
