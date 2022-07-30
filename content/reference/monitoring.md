---
title: "Monitoring and Observability"
weight: 3
---

Monitoring your libp2p process lets make sure that in practice things are going
as you expect. Each libp2p implementation does monitoring in a slightly
different way, so consult the links below to see how your implementation does
it.

Rust libp2p:

Look at the [libp2p-metrics crate](https://github.com/libp2p/rust-libp2p/tree/master/misc/metrics).

Go libp2p:

For resource usage take a look at the OpenCensus metrics exposed by the resource
manager
[here](https://pkg.go.dev/github.com/libp2p/go-libp2p-resource-manager@v0.5.2/obs).
In general Go libp2p wants to add more metrics across the stack in the future,
this work is being tracked in issue
[go-libp2p#1356](https://github.com/libp2p/go-libp2p/issues/1356).