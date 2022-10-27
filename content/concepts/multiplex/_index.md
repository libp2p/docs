---
title: "Stream Multiplexing"
weight: 4
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
aliases: /concepts/stream-multiplexing/
summary: Stream Multiplexing is a way of sending multiple streams of data over one communication link. It combines multiple signals into one unified signal so it can be transported 'over the wires', then it is demulitiplexed so it can be output and used by separate applications. 
---

# Stream bytes

Stream Multiplexing (_stream muxing_) is a way of sending multiple streams of data over one 
communication link. It combines multiple signals into one unified signal so it can be transported 
'over the wires', then it is demulitiplexed (_demuxed_) so it can be output and used by separate 
applications. This is done to share a single TCP connection using unique port numbers to distinguish 
streams, between the multiple proceeses (such as kademlia and gossipsub) used by applications (such as IPFS) 
to make connection and transmission more efficient. 

With muxing, libp2p applications may have many separate streams of communication between peers, as well as 
have multiple concurrent streams open at the same time with a peer. Stream multiplexing allows us to initialize 
and use the same [transport](/concepts/transport/) connection across the lifetime of our interaction with a peer. 
With muxing, we also only need to deal with [NAT traversal](nat) once to be able to open as many 
streams as we need, since they will all share the same underlying transport connection. Applications can enable 
support for multiple multiplexers, which will allow you to fall back to a widely-supported multiplexer if a preferred 
choice is not supported by a remote peer.

{{% notice "info" %}}
libp2p's multiplexing happens at the application layer, meaning it's not provided by the 
operating system's network stack. However, developers writing libp2p applications rarely need to i
nteract with stream multiplexers directly, except during initial configuration to control which 
modules are enabled.
{{% /notice %}}

{{% children description="true"%}}
