---
title : "Overview"
description: "We want libp2p applications to run everywhere, not just in data centers or on machines with stable public IP addresses. Learn about the main approaches to NAT traversal available in libp2p."
weight: 1
aliases: /concepts/nat/
---

## What are NATs?

The internet is composed of countless networks, bound together into shared address spaces by foundational [transport protocols](../../transport/overview).

As traffic moves between network boundaries, it's very common for a process called Network Address Translation to occur. Network Address Translation (NAT) maps an address from one address space to another.

NAT allows many machines to share a single public address, and it is essential for the continued functioning of the IPv4 protocol, which would otherwise be unable to serve the needs of the modern networked population with its 32-bit address space.

For example, when I connect to my home wifi, my computer gets an IPv4 address of `10.0.1.15`. This is part of a range of IP addresses reserved for internal use by private networks. When I make an outgoing connection to a public IP address, the router replaces my internal IP with its own public IP address. When data comes back from the other side, the router will translate back to the internal address.

While NAT is usually transparent for outgoing connections, listening for incoming connections requires some configuration. The router listens on a single public IP address, but any number of machines on the internal network could handle the request. To serve requests, your router must be configured to send certain traffic to a specific machine, usually by mapping one or more TCP or UDP ports from the public IP to an internal one.

While it's usually possible to manually configure routers, not everyone that wants to run a peer-to-peer application or other network service will have the ability to do so.

We want libp2p applications to run everywhere, not just in data centers or on machines with stable public IP addresses. To enable this, here are the main approaches to NAT traversal available in libp2p today.

## Automatic router configuration

Many routers support automatic configuration protocols for port forwarding, most commonly [UPnP][wiki_upnp] or [nat-pmp.][wiki_nat-pmp]

If your router supports one of those protocols, libp2p will attempt to automatically configure a port mapping that will
allow it to listen for incoming traffic. This is usually the simplest option if supported by the network and libp2p implementation.

<!-- ADD NOTICE -->
Support for automatic NAT configuration varies by libp2p implementation.
Check the [current implementation status](https://libp2p.io/implementations/#nat-traversal) for details.

[wiki_upnp]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[wiki_nat-pmp]: https://en.wikipedia.org/wiki/NAT_Port_Mapping_Protocol
[wiki_stun]: https://en.wikipedia.org/wiki/STUN
[rfc_stun]: https://tools.ietf.org/html/rfc3489
[lwn_reuseport]: https://lwn.net/Articles/542629/
