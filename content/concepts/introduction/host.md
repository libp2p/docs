---
title: "libp2p Host"
description: "A libp2p host is a program or process that runs on a peer and allows it to participate in a libp2p network."
weight: 4
---

A libp2p host is a program or process that allows a peer to participate
in the libp2p network.

{{< alert icon="" context="note">}}
There are [several implementations](https://libp2p.io/implementations/) of the
libp2p host, and not all of the implementations support the features mentioned below.
{{< /alert >}}

A libp2p host has a
[unique identity](/concepts/introduction/core-abstractions/peers#peer-id)
and can listen on different [transport protocols](/concepts/transports/overview),
[dial connections to other hosts](/concepts/transports/listen-and-dial), and detect
if it's a publicly reachable node or if it's behind a NAT/firewall with
[AutoNAT](../nat/overview.md##automatic-router-configuration).
The host can apply [hole punching techniques](/concepts/nat/hole-punching) to overcome
NATs, find peers through a routing protocol like
[DHT](/concepts/introduction/protocols/dht), and send messages across the network
using [Gossipsub](/concepts/pubsub/gossipsub).
