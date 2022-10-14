---
title: "AutoNAT"
weight: 2
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
summary: The internet is composed of countless networks, bound together into shared address spaces by foundational transport protocols. As traffic moves between network boundaries, it's very common for a process called Network Address Translation to occur. Network Address Translation (NAT) maps an address from one address space to another.
---

# AutoNAT

While the [identify protocol][spec_identify] described above lets peers inform each other about their observed network addresses, not all networks will allow incoming connections on the same port used for dialing out.

Once again, other peers can help us observe our situation, this time by attempting to dial us at our observed addresses. If this succeeds, we can rely on other peers being able to dial us as well and we can start advertising our listen address.

A libp2p protocol called AutoNAT lets peers request dial-backs from peers providing the AutoNAT service.

{{% notice "info" %}}
AutoNAT is currently implemented in go-libp2p via [go-libp2p-autonat](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/autonat).
{{% /notice %}}

[spec_identify]: https://github.com/libp2p/specs/tree/master/identify
