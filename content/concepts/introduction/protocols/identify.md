---
title: "Identify"
description: "A way for nodes in libp2p to query and inform other nodes about their metadata."
weight: 23
---

The libp2p identify protocol is a way for nodes to query and inform other nodes
about their metadata, such as their public key and the protocols they support.

There are two variations of the protocol: `identify` and `identify/push`.

The identify protocol, identified by the protocol ID `/ipfs/id/1.0.0`, is used
to query a remote node for its metadata. To do so, a node opens a stream to the
remote node and the remote node responds with an `Identify` message containing
its metadata and closes the stream.

The identify/push protocol, identified by the protocol ID `/ipfs/id/push/1.0.0`,
is used to inform other nodes about changes in a node's metadata. When a
node's metadata changes, it can "push" the new information to other nodes by opening
a stream to each of the nodes to be updated, and sending an `Identify` message
containing the updated metadata. Upon receiving the pushed `Identify` message, the
remote node can update its local metadata repository with the information from the
message, taking into account that missing fields should be ignored as the message may
contain only partial updates.

The `Identify` message contains several fields:

- `protocolVersion`: (optional) identifies the family of protocols used by the node.
  It is recommended for debugging and statistic purposes, but previous specification versions
  required connections to be closed on version mismatch. This requirement has been revoked to
  allow interoperability between different protocol families and networks.
- `agentVersion`: a free-form string identifying the node's implementation, usually
  in the format agent-name/version.
- `publicKey`: the node's public key, marshaled in binary form.
- `listenAddrs`: the addresses on which the node is listening, as multi-addresses.
- `observedAddr`: (optional) the connection source address of the stream-initiating node
  as observed by the node being identified. It can be used to infer the existence of NAT
  and its public address.
- `protocols`: a list of protocols supported by the node. A node should only advertise a
  protocol if it is willing to receive inbound streams on that protocol.

{{< alert icon="💡" context="note" text="See the Identify <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/identify\">technical specification</a> for more details." />}}
