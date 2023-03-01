---
title: "mDNS"
description: "mDNS uses a multicast system of DNS records over a local network to enable peer discovery."
weight: 224
---

## What is mDNS?

mDNS, or multicast Domain Name System, is a way for nodes to use IP multicast to
publish and receive DNS records [RFC
6762](https://www.rfc-editor.org/rfc/rfc6762) within a local network. Nodes
broadcast topics they're interested in. mDNS is commonly used on home networks
to allow devices such as computers, printers, and smart TVs to discover each
other and connect.

## mDNS in libp2p

In libp2p, mDNS is used for peer discovery, allowing peers to find and
communicate with each other on the same local network without any configuration.
The basic mDNS node discovery flow begins when a peer starts or detects a
network change and then sends a query message to all peers. The node adds the
response it receives from other peers into a local database.

To learn more about
definitions, specific fields, and peer discovery, [visit the mDNS libp2p
specification](https://github.com/libp2p/specs/blob/master/discovery/mdns.md).
<!-- ADD DIAGRAM -->
