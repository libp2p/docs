---
title: "AutoNAT"
description: "AutoNAT lets peers request dial-backs from peers providing the AutoNAT service."
weight: 200
aliases:
    - "/concepts/autonat"
    - "/concepts/nat/autonat"
---

## Background

While the [identify protocol][spec_identify] lets peers inform each other about their observed network
addresses, not all networks will allow incoming connections on the same port used for dialing out.

To solve this problem, libp2p has implemented a protocol called AutoNAT, which allows nodes to determine
whether or not they are behind a NAT and, if necessary, find a way to improve their connectivity.

## What is AutoNAT?

AutoNAT allows a node to request other peers to dial its presumed public addresses. If a few of these
dial attempts are successful, the node can be reasonably certain that it is not behind a NAT. On the other
hand, if a few of these dial attempts fail, it strongly indicates that a NAT is blocking incoming connections.

The AutoNAT protocol uses the protocol ID `/libp2p/autonat/1.0.0` and involves the exchange of `Dial` and
`DialResponse` messages.

To initiate the protocol, a node sends a `Dial` message to another peer containing
a list of multiaddresses. The peer then attempts to dial these addresses using a different IP and peer ID
than it uses for its regular libp2p connection. If at least one of the dials is successful, the peer sends a
`DialResponse` message with the `ResponseStatus`: `SUCCESS` to the requesting node.

If all dials fail, the peer sends a `DialResponse` message with the `ResponseStatus`: `E_DIAL_ERROR`.
The requesting node can use the response from the peer to determine whether or not it is behind a NAT.
> If the response indicates success, the node is likely not behind a NAT and does not need to use a relay
> server to improve its connectivity. If the response indicates an error, the node is likely behind a NAT
> and may need to use a relay server to communicate with other nodes in the network.

{{< alert icon="" context="caution">}}
To prevent certain types of attacks, implementations of AutoNAT must not dial any multiaddress that
is not based on the IP address of the requesting node AND must not accept dial requests via relayed
connections.

This is to prevent amplification attacks, in which an attacker provides many clients with the same
faked MAPPED-ADDRESS that points to the intended target, causing all traffic to be focused on the
target.
{{< /alert >}}

<!-- ADD DIAGRAM -->

{{< alert icon="💡" context="note" text="See the AutoNAT <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/autonat/README.md\">technical specification</a> for more details." />}}

[spec_identify]: https://github.com/libp2p/specs/tree/master/identify
