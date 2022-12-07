---
title: "mDNS"
description: "MDNS uses a multicast system of DNS records over a local network to enable peer discovery."
weight: 224
---

## What is mDNS?

mDNS, or multicast Domain Name System, is a way for nodes to use a multicast system
of DNS records over a local network to discover and communicate with nodes. Nodes
broadcast topics they're interested in instead of querying a central name server.
The discovery, however, is limited to the peers in the local network. mDNS is commonly
used on home networks to allow devices such as computers, printers, and smart TVs to
find each other and connect. It uses a protocol called multicast to broadcast messages
on the network, allowing devices to discover each other and exchange information.

## mDNS in libp2p

In libp2p, mDNS is used for service discovery.
When a peer wants to connect to another peer in a libp2p network,
it can use mDNS to resolve the hostname of the other peer to its multiaddr.
A peer can broadcast a query request to *find all peers* on a local network to
receive DNS response messages from peers, which contain the peer information
of discovered peers. The response message is in the form of a DNS record:

`<service-name> PTR <peer-name>.<service-name>`,

where `<service-name>` is `_p2p._udp.local`, the name of the service that is being
advertised.
> `peer-name` is not used for anything and can be filled with a string with random characters.

A TXT record contains the multiaddresses that the peer is listening on. A peer
encodes the multiaddr of the other peer into the DNS record. Each multiaddress is a TXT
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
