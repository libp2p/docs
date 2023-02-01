---
title: "Identify"
description: "A way for nodes in libp2p to query and inform other nodes about their metadata."
weight: 23
---

The libp2p Identify protocol is a way for nodes in the libp2p network to share
and query information about each other. It is usually run right after a new libp2p connection has been established, and at certain times during the lifetime of the connection.

The information exchanged includes:

- the user agent: a free-form string identifying the node's implementation, usually
  in the format "agent-name/version".
- the node's public IP address: the address of the node on the network, as seen by other nodes.
- the list of multiaddresses that the node is listening on: the various network addresses
  and ports that the node can be reached at.
- the list of protocols that the node supports

There are two variations of the protocol: `identify` and `identify/push`.

The Identify protocol, for historical reasons identified by the protocol ID `/ipfs/id/1.0.0`, is used
to actively query a remote node for its metadata.

<!-- ADD Diagram -->

The identify/push protocol, identified by the protocol ID `/ipfs/id/push/1.0.0`,
allows a node to push Identify data to the other node without having been queried.
This is used whenever changes to the data sent in Identify happen, e.g. when the node
starts listening on a new address, and when the node adds or removes support for
a protocol.

{{< alert icon="" context="note">}}
It's worth noting that go-libp2p used to include a feature called 'Identify Delta' (<insert protocol ID>) for some time.
This protocol was used to reduce the size of Identify Pushes, but proved to be less useful (and a lot more complex) than expected.
It has since been deprecated, but a lot of nodes on the IPFS network still support this protocol.
{{< /alert >}}

<!-- ADD Diagram -->

{{< alert icon="💡" context="note" text="See the Identify <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/identify\">technical specification</a> for more details." />}}
