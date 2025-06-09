---
title: "AutoNAT v2"
description: "Detailed documentation for the AutoNAT v2 protocol in libp2p."
weight: 201
aliases:
    - "/concepts/autonat"
    - "/concepts/nat/autonat"
---

Overview
Nodes in a peer-to-peer network cannot easily determine their reachability status. A node may be reachable on some addresses but not others due to NATs or firewalls. Determining which addresses are publicly reachable helps nodes:

Avoid advertising unreachable addresses.

Reduce unnecessary dial attempts from other peers.

Proactively enable connectivity through relay servers if necessary.

AutoNAT v2 addresses these challenges by providing per-address reachability checks.

How AutoNAT v2 Works
AutoNAT v2 lets nodes verify the reachability of individual addresses:

The client node sends a prioritized list of addresses (DialRequest) along with a nonce.

The server selects exactly one address from the list to dial back.

If the dial-back address is different from the observed IP, the server initiates an Amplification Attack Prevention mechanism.

The server opens a /libp2p/autonat/2/dial-back stream, sends the nonce, and awaits a response (DialBackResponse) from the client.

The server sends a final DialResponse with the dial outcome.

AutoNAT v2 helps clients build pipelines for testing addresses from various sources like identify, UPnP mappings, and circuit addresses.

Visualization

Client                                          Server
|                                                 |
| DialRequest (nonce, addr list)                  |
|------------------------------------------------>|
|                                                 | Chooses an address
|                   Dial selected address         |
|<----------------------------------------------- |
| DialBack (nonce verification)                   |
|------------------------------------------------>|
| DialBackResponse (nonce confirmed)              |
|<----------------------------------------------- |
|                                                 | Final dial status
| DialResponse (address index, dial outcome)      |
|<------------------------------------------------|



Differences from AutoNAT v1
Address-specific reachability checks rather than overall node reachability.

Nonce-based verification ensures the correct address was dialed.

Amplification Attack Prevention allows dialing addresses different from the observed IP without risking amplification attacks.

Amplification Attack Prevention
When dialing an address different from the client's observed IP, the server requests a significant data transfer (30–100 KB) from the client before proceeding, making attacks impractical.

