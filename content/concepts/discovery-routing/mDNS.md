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

<!-- ADD DIAGRAM -->

### Example

The following Wireshark output shows sample mDNS traffic that is being generated from an IPFS node.
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
