---
title: "mDNS"
description: "mDNS uses a multicast system of DNS records over a local network to enable peer discovery."
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

In libp2p, mDNS is used for peer discovery, allowing peers to find and
communicate with each other on the same local network without any prior configuration.
This is achieved through multicast DNS (mDNS) records, which are sent to all nodes on the
local network.

To initiate peer discovery, a peer sends a query to all other peers on the network using
a DNS message with the question `_p2p._udp.local PTR`. In response, each peer will send a
DNS message containing their discovery details. These details are stored in the additional
records of the response and include the multiaddresses that the peer is listening on, as
well as other information such as the peer's `<peer-name>` and `<host-name>`.

The response message (that is, the answer to the DNS message) is in the form of a
DNS record: `<service-name> PTR <peer-name>.<service-name>`. Additional record in the
response message contains a peer's discovery details in the following form:
`<peer-name>.<service-name> TXT "dnsaddr=..."`

- `<peer-name>` is a unique case-insensitive identifier for the peer, although it is not
  used for any meaningful purpose in libp2p. Instead, it is simply a string of random ASCII
  characters that are required to be sent in the wire format. On the other hand, the
- `<host-name>` is the fully qualified name of the peer derived from the peer's name and
  `p2p.local`.
- `<service-name>`, meanwhile, is the DNS-SD (DNS Service Discovery) service name for all
  peers and is defined as `_p2p._udp.local`.
  > If a private network is being used, the `<service-name>` will contain the base-16 encoding of
  > the network's fingerprint as in `_p2p-X._udp.local` to prevent public and private networks from
  > discovering each other's peers.

A peer sends a query for all *other* peers when it first spawns or detects a network change.
A peer must respond to its own query. This allows other peers to passively discover it.

### Example

The sample Wireshark output shows the mDNS traffic that is being generated from an IPFS node.
The table includes information about the query and response messages being exchanged via mDNS.

| No. | Time       | Source IP                | Destination IP         | Protocol | Length | Info                      |
|-----|------------|--------------------------|------------------------|----------|--------|---------------------------|
| 1   | 0.000000   | 10.0.0.25                | 224.0.0.251            | MDNS     | 75     | Standard query 0x7d14 PTR _p2p._udp.local, "QM" question |
| 2   | 0.000130   | fe80::8d9:f02f:717f:2c03 | ff02::fb               | MDNS     | 95     | Standard query 0x7d14 PTR _p2p._udp.local, "QM" question |
| 3   | 0.002497   | 10.0.0.25                | 224.0.0.251            | MDNS     | 918    | Standard query response 0x7d14 PTR vmvokx8c0b7rcjtx4e14iyaxw7otg05xyg954y5fnh1a9rderxtxycicgtj3nn._p2p._udp.local SRV 0 0 4001 vmvokx8c0b7rcjtx4e14iyaxw7otg05xyg954y5fnh1a9rderxtxycicgtj3nn.local TXT A 127.0.0.1 AAAA ::1 |
| 4   | 0.002507   | fe80::8d9:f02f:717f:2c03 | ff02::fb               | MDNS     | 938    | Standard query response 0x7d14 PTR vmvokx8c0b7rcjtx4e14iyaxw7otg05xyg954y5fnh1a9rderxtxycicgtj3nn._p2p._udp.local SRV 0 0 4001 vmvokx8c0b7rcjtx4e14iyaxw7otg05xyg954y5fnh1a9rderxtxycicgtj3nn.local TXT A 127.0.0.1 AAAA ::1 |

The "Info" column provides additional information about the packet, including the type of query
or response message (e.g. Standard query, Standard query response), the DNS record type
(e.g. PTR, SRV, TXT), and any additional details about the query or response.

The query messages are sent to the multicast IP address 224.0.0.251, and the response messages are
sent back to the source IP address. The DNS records being queried and returned include PTR (pointer)
records, SRV (service) records, and TXT (text) records. These records are used to map domain names
to IP addresses and other information about services and devices on the network

{{< alert icon="💡" context="note" text="See the mDNS <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/blob/master/discovery/mdns.md\">technical specification</a> for more details." />}}
