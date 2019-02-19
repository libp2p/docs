---
type: index
title: libp2p Documentation
---

Welcome to the libp2p documentation portal! Whether you’re just learning how to build peer-to-peer systems with libp2p, want to dive into peer-to-peer concepts and solutions, or are looking for detailed reference information, this is the place to start.

## Introduction

Head over to the [introduction](/introduction) section for an introduction to the basics of libp2p, an overview of the problems it addresses, and a guide to getting up and running.



## Guides

The guides section has an overview of major concepts in libp2p, guides, and example projects demonstrating various ways to use libp2p to build applications.

In particular, check the [concepts](/guides/concepts) section to learn more about the major architectural pieces of libp2p and about terms and ideas associated with peer-to-peer systems in general, as well as those specific to libp2p.


## Reference

### Implementations

At the core of libp2p is a set of [specifications](https://github.com/libp2p/specs), which together form the definition for what libp2p is in the abstract and what makes a "correct" libp2p implementation. Today, implementations of libp2p exist in several languages, with varying degrees of completeness. The two most complete implementations are in [Go](/reference/go/overview) and [JavaScript](/reference/js/overview).

In addition to the Go and JavaScript reference implementations, the libp2p community is actively working on implementations in [rust](https://github.com/libp2p/rust-libp2p), [python](https://github.com/libp2p/py-libp2p) and [the JVM via Kotlin](https://github.com/web3j/libp2p). Please check the project pages for each implementation to see its status and current state of completeness.

### Specifications & Planning

While libp2p has two reference implementations (in Go and JavaScript), it is fundamentally a set of protocols for peer identity, discover, routing, transport and more. You can find specifications for those protocols, whitepapers, and information about our RFC (Request for Change) process in the “specifications & planning” section.


## Community

Get in touch with other members of the libp2p community who are building tools and applications with libp2p! You can ask questions, discuss new ideas, or get support for problems at https://discuss.ipfs.io, but you can also [hop on IRC](/community/irc) for a quick chat.

See the other links in the community section for more information about meetings, events, apps people are building, and more.

Information about contributing to libp2p and about other software projects in the community are also hosted here.


### Get Involved

libp2p is an open-source community project. While [Protocol Labs](https://protocol.ai) is able to sponsor some of the work around it, much of the design, code, and effort is contributed by volunteers and community members like you. If you’re interested in helping improve libp2p, check the [how to help](/community/contribute/how_to_help) guide to get started.

If you are diving in to contribute new code, make sure you check both the [contribution guidelines] and the style guide for your language ([Go](https://github.com/ipfs/community/blob/master/go-code-guidelines.md), [JavaScript](https://github.com/ipfs/community/blob/master/js-code-guidelines.md)).


### Related Projects

libp2p began as part of the [IPFS](https://ipfs.io) project, and is still an essential component of IPFS. As such, libp2p composes well with the abstractions and tools provided by other projects in the IPFS "family". Check their individual sites for specific information and references:

- [IPFS](https://libp2p.io) is the InterPlanetary File System, which uses libp2p as its networking layer.
- [Multiformats](https://multiformats.io) is a variety of *self-describing* data formats.
- [IPLD](https://ipld.io) is a set of tools for describing links between content-addressed data, like IPFS files, Git commits, or Ethereum blocks.
