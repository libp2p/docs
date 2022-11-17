---
title: "AutoNAT"
description: AutoNAT lets peers request dial-backs from peers providing the AutoNAT service.
weight: 200
aliases:
    - /concepts/autonat
    - /concepts/nat/autonat
---

## What is AutoNAT?

While the [identify protocol][spec_identify] described above lets peers inform each other about their observed network addresses, not all networks will allow incoming connections on the same port used for dialing out.

Once again, other peers can help us observe our situation, this time by attempting to dial us at our observed addresses.
If this succeeds, we can rely on other peers being able to dial us as well and we can start advertising our listen address.

A libp2p protocol called AutoNAT lets peers request dial-backs from peers providing the AutoNAT service.

> AutoNAT is currently implemented in go-libp2p via [go-libp2p-autonat](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/autonat).

[spec_identify]: https://github.com/libp2p/specs/tree/master/identify

## How does AutoNAT work?

Coming soon!
