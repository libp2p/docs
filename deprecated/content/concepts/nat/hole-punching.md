---
title: "Hole Punching"
weight: 1
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
summary: The internet is composed of countless networks, bound together into shared address spaces by foundational transport protocols. As traffic moves between network boundaries, it's very common for a process called Network Address Translation to occur. Network Address Translation (NAT) maps an address from one address space to another.
---

# Hole Punching

<!-- to replace with new hole punching doc -->

When an internal machine "dials out" and makes a connection to a public address, the router will map a public port to the internal IP address to use for the connection. In some cases, the router will also accept *incoming* connections on that port and route them to the same internal IP.

libp2p will try to take advantage of this behavior when using IP-backed transports by using the same port for both dialing and listening, using a socket option called [`SO_REUSEPORT`](https://lwn.net/Articles/542629/).

If our peer is in a favorable network environment, they will be able to make an outgoing connection and get a publicly-reachable listening port "for free," but they might never know it. Unfortunately, there's no way for the dialing program to discover what port was assigned to the connection on its own.
However, an external peer can tell us what address they observed us on. We can then take that address and advertise it to other peers in our [peer routing network](/concepts/peer-routing/) to let them know where to find us.

This basic premise of peers informing each other of their observed addresses is the foundation of [STUN][wiki_stun] (Session Traversal Utilities for NAT), which [describes][rfc_stun] a client / server protocol for discovering publicly reachable IP address and port combinations.

One of libp2p's core protocols is the [identify protocol][spec_identify], which allows one peer to ask another for some identifying information. When sending over their [public key](/concepts/peers/) and some other useful information, the peer being identified includes the set of addresses that it has observed for the peer asking the question.

This external discovery mechanism serves the same role as STUN, but without the need for a set of "STUN servers".
The identify protocol allows some peers to communicate across NATs that would otherwise be impenetrable.
