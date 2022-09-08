---
title: Overview
weight: 1
pre: '<i class="fas fa-fw fa-book"></i> <b>2.4.1. </b>'
---

The internet is composed of countless networks, bound together into shared address spaces by foundational [transport protocols](/concepts/transport/).

As traffic moves between network boundaries, it's very common for a process called Network Address Translation to occur. Network Address Translation (NAT) maps an address from one address space to another.

NAT allows many machines to share a single public address, and it is essential for the continued functioning of the IPv4 protocol, which would otherwise be unable to serve the needs of the modern networked population with its 32-bit address space.

For example, when I connect to my home wifi, my computer gets an IPv4 address of `10.0.1.15`. This is part of a range of IP addresses reserved for internal use by private networks. When I make an outgoing connection to a public IP address, the router replaces my internal IP with its own public IP address. When data comes back from the other side, the router will translate back to the internal address.

While NAT is usually transparent for outgoing connections, listening for incoming connections requires some configuration. The router listens on a single public IP address, but any number of machines on the internal network could handle the request. To serve requests, your router must be configured to send certain traffic to a specific machine, usually by mapping one or more TCP or UDP ports from the public IP to an internal one.

While it's usually possible to manually configure routers, not everyone that wants to run a peer-to-peer application or other network service will have the ability to do so.

We want libp2p applications to run everywhere, not just in data centers or on machines with stable public IP addresses. To enable this, here are the main approaches to NAT traversal available in libp2p today.

### Automatic router configuration

Many routers support automatic configuration protocols for port forwarding, most commonly [UPnP][wiki_upnp] or [nat-pmp.][wiki_nat-pmp]

If your router supports one of those protocols, libp2p will attempt to automatically configure a port mapping that will allow it to listen for incoming traffic. This is usually the simplest option if supported by the network and libp2p implementation.

{{% notice "info" %}}
Support for automatic NAT configuration varies by libp2p implementation.
Check the [current implementation status](https://libp2p.io/implementations/#nat-traversal) for details.
{{% /notice %}}

### Hole-punching (STUN)

When an internal machine "dials out" and makes a connection to a public address, the router will map a public port to the internal IP address to use for the connection. In some cases, the router will also accept *incoming* connections on that port and route them to the same internal IP.

libp2p will try to take advantage of this behavior when using IP-backed transports by using the same port for both dialing and listening, using a socket option called [`SO_REUSEPORT`](https://lwn.net/Articles/542629/).

If our peer is in a favorable network environment, they will be able to make an outgoing connection and get a publicly-reachable listening port "for free," but they might never know it. Unfortunately, there's no way for the dialing program to discover what port was assigned to the connection on its own.

However, an external peer can tell us what address they observed us on. We can then take that address and advertise it to other peers in our [peer routing network](/concepts/peer-routing/) to let them know where to find us.

This basic premise of peers informing each other of their observed addresses is the foundation of [STUN][wiki_stun] (Session Traversal Utilities for NAT), which [describes][rfc_stun] a client / server protocol for discovering publicly reachable IP address and port combinations.

One of libp2p's core protocols is the [identify protocol][spec_identify], which allows one peer to ask another for some identifying information. When sending over their [public key](/concepts/peer-id/) and some other useful information, the peer being identified includes the set of addresses that it has observed for the peer asking the question.

This external discovery mechanism serves the same role as STUN, but without the need for a set of "STUN servers".

The identify protocol allows some peers to communicate across NATs that would otherwise be impenetrable.

### AutoNAT

While the [identify protocol][spec_identify] described above lets peers inform each other about their observed network addresses, not all networks will allow incoming connections on the same port used for dialing out.

Once again, other peers can help us observe our situation, this time by attempting to dial us at our observed addresses. If this succeeds, we can rely on other peers being able to dial us as well and we can start advertising our listen address.

A libp2p protocol called AutoNAT lets peers request dial-backs from peers providing the AutoNAT service.

{{% notice "info" %}}
AutoNAT is currently implemented in go-libp2p via [go-libp2p-autonat](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/autonat).
{{% /notice %}}


### Circuit Relay (TURN)

In some cases, peers will be unable to traverse their NAT in a way that makes them publicly accessible.

libp2p provides a [Circuit Relay protocol](/concepts/circuit-relay/) that allows peers to communicate indirectly via a helpful intermediary peer.

This serves a similar function to the [TURN protocol](https://tools.ietf.org/html/rfc5766) in other systems.

[wiki_upnp]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[wiki_nat-pmp]: https://en.wikipedia.org/wiki/NAT_Port_Mapping_Protocol
[wiki_stun]: https://en.wikipedia.org/wiki/STUN
[rfc_stun]: https://tools.ietf.org/html/rfc3489
[lwn_reuseport]: https://lwn.net/Articles/542629/
[spec_identify]: https://github.com/libp2p/specs/tree/master/identify
