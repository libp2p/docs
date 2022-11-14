---
title: "Switch"
weight: 2
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
summary: libp2p maintains some state about known peers and existing connections in a component known as the switch 
---

libp2p maintains some state about known peers and existing connections in a component known as the switch (or "swarm", depending on the implementation). The switch provides a dialing and listening interface that abstracts the details of which stream multiplexer is used for a given connection.

When configuring libp2p, applications enable stream muxing modules, which the switch will use when dialing peers and listening for connections. If the remote peers support any of the same stream muxing implementations, the switch will select and use it when establishing the connection. If you dial a peer that the switch already has an open connection to, the new stream will automatically be multiplexed over the existing connection.

Reaching agreement on which stream multiplexer to use happens early in the connection establishment process. Peers use [protocol negotiation](../../fundamentals/protocols/#protocol-negotiation) to agree on a commonly supported multiplexer, which upgrades a "raw" transport connection into a muxed connection capable of opening new streams.
