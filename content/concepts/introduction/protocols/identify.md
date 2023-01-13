---
title: "Identify"
description: "A way for nodes in libp2p to query and inform other nodes about their metadata."
weight: 23
---

The libp2p Identify protocol is a way for nodes in the libp2p network to share
and query information about each other. This information includes:

- the user agent: a free-form string identifying the node's implementation, usually
  in the format "agent-name/version".
- the public IP address: the address of the node on the network, as seen by other nodes.
- the list of multiaddresses that the node is listening on: the various network addresses
  and ports that the node can be reached at.
- the list of protocols that the node supports: the different communication methods that
  the node can understand and use to communicate with other nodes.

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

{{< alert icon="💡" context="note" text="See the Identify <a class=\"text-muted\" href=\"https://github.com/libp2p/specs/tree/master/identify\">technical specification</a> for more details." />}}
