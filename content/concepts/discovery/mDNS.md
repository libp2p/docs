---
title: "MDNS"
description: "MDNS uses a multicast system of DNS records over a local network to enable peer discovery."
weight: 224
---

## What is mDNS?

MDNS, or multicast Domain Name System, uses a multicast system of DNS records over a
local network. Nodes broadcast topics they're interested in into the network instead of
querying a central name server. The discovery is limited to the peers in the local network.

MDNS uses UDP to enable hostname resolution on local networks, allowing it to be used
on networks that support multicast, such as an office. In turn, it can also use DNS to
resolve hostnames to IP addresses on the Internet. MDNS does not require a central DNS
server to operate, as a node can resolve hostnames to IP addresses in a decentralized
manner.

## MDNS in libp2p

In libp2p, mDNS can be used as part of the [rendezvous protocol](rendezvous) to enable peers
to discover and connect. When a peer wants to connect to another peer in a libp2p network,
it can use mDNS to resolve the hostname of the other peer to its multiaddress.

MDNS follows a request-response model, where a peer broadcasts a query request to *find all peers*
on a local network to receive DNS response messages from peers which contain the peer information
of discovered peers. The response message is in the form of DNS record:

`<service-name> PTR <peer-name>.<service-name>`,

where `<service-name>` is the name of the service that is being advertised, and
`<peer-name>` is the name of the peer [that is providing the service].
The `<service-name>` part of the record indicates the domain in which the service
and peer are located.

As responses are received, the peer adds the other peers' information into its local database of peers.
A TXT record contains the multiaddresses that the peer is listening on. Each multiaddress is a TXT
attribute with the form `dnsaddr=/.../p2p/QmId`.
> `dnsaddr` is a protocol that instructs the resolver to look up multiaddr(s) in DNS TXT records for the
> domain name in its value section. To resolve a `dnsaddr` multiaddr, the domain name in the value section
> must first be prefixed with `_dnsaddr.`. Then the peer must make a DNS query to look up TXT records for the domain. Multiple dnsaddr attributes and/or TXT records are allowed.
> Learn more about `dnsaddr`  [here](https://github.com/multiformats/multiaddr/blob/master/protocols/DNSADDR.md).

A peer sends a query for all peers when it first spawns or detects a network change.

{{< alert icon="💡" context="info" text="A peer must respond to its own query. This allows other peers to passively discover it." />}}

An *additional records* record in the response message contains a peer's discovery details
in the following form: `<peer-name>.<service-name> TXT "dnsaddr=..."`.

{{< alert icon="💡" context="note" text="See the mDNS <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/discovery/mdns.md\">technical specification</a> for more details." />}}
