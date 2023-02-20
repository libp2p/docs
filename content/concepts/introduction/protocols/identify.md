---
title: "Identify"
description: "A way for nodes in libp2p to query and inform remote nodes about their metadata."
weight: 23
---

The libp2p Identify protocol allows nodes in the libp2p network to share
and query information about each other. It is usually run right after a new libp2p
connection has been established and, at certain times, during the lifetime of the
connection.

The information exchanged includes:

- the protocol version: a network identifier, e.g. `/my-network/0.1.0`.
- the user agent: a free-form string identifying the local node's implementation, usually
  in the format "agent-name/version".
- the observed address: the remote node's public IP address as observed by the local node.
- the listen addresses: the multiaddresses at which the local node can be reached.
- the list of [protocols](/concepts/introduction/protocols/overview) that the
  local node supports.

There are two variations of the protocol: `identify` and `identify/push`.

The Identify protocol, for historical reasons identified by the protocol ID `/ipfs/id/1.0.0`,
is used to actively query a remote node for its metadata. The identify/push protocol, identified
by the protocol ID `/ipfs/id/push/1.0.0`, allows a node to push Identify data to the remote node
without querying. This is used whenever changes to the data sent in Identify happen,
e.g., when the node starts listening on a new address and adds or removes support
for a protocol.

{{< alert icon="" context="note">}}
It's worth noting that go-libp2p used to include a feature called 'Identify Delta'
(<insert protocol ID>) for some time. This protocol was used to reduce the size of
Identify Pushes, but proved to be less useful (and a lot more complex) than expected.
It has since been deprecated, but many nodes on the IPFS network still support
this protocol.
{{< /alert >}}

{{< alert icon="💡" context="note" text="See the Identify <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/identify\">technical specification</a> for more details." />}}
