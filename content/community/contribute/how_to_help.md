---
title: "How to Help"
menu:
    community:
        parent: contribute
        weight: 1
---

So you want to contribute to libp2p and the peer-to-peer ecosystem? Here is a quick listing
of things we need help with and how you can get started. Even if what you want
to do is not listed here, we probably accept contributions for it! If you're
unsure, please open a issue.


## Areas of contribution

- [Code](#code)
- [Documentation](#documentation)
- [Support](#support)
- [Testing](#testing)
- [Design](#design)
- [Issues / Triaging](#issues-triaging)
- [Community](#community)
- [Applications](#applications)
- [Protocol Design](#protocol-design)
- [Research](#research)


### Code

libp2p and its sister-projects are *big,* with lots of code written in
multiple languages. We always need help writing and maintaining code, but it
can be daunting to just jump in. We use the label **“Help Wanted”** on features
or bugfixes that people can help out with. They are an excellent place for you
to start contributing code.

The biggest and most active repositories we have today are:

- https://github.com/libp2p/go-libp2p
- https://github.com/libp2p/js-libp2p
- https://github.com/libp2p/rust-libp2p

The repos above are the main "entry points" for the three most mature libp2p
implementations, but there are also many "module repos" which define interfaces
and implement various aspects of libp2p for each language. The "entry point"
repos will have more information on the modules and repo structure for each
language implementation.

### Documentation

With lots of code comes the need for lots of good documentation! However, we
need a lot more help to write the awesome docs the project needs. If writing
technical documentation is your area, we’d absolutely love your help!

The best place to get started is by looking through the Github Issues at:
https://github.com/libp2p/docs

Writing new docs is not the only way to help! By
[filing new documentation issues](https://github.com/libp2p/docs/issues/new),
you help us get a clearer picture of where the gaps are and what we need to
prioritize going forward. If you want your pain-points on our radar, please
let us know!

### Support

libp2p already has lots of users and curious people experimenting and using
libp2p in their applications. These users sometimes get stuck or have questions
that need answering. If you’ve contributed something with code or documentation,
chances are that you can probably help a lot of people with their questions.

We do most support via the forum we have at: https://discuss.ipfs.io/, with
libp2p-specific topic tagged with the [libp2p tag](https://discuss.ipfs.io/tags/libp2p).

### Testing

We’re continuously improving libp2p every day, but mistakes can happen and we
could release something that doesn’t work as well as it should — or simply doesn't
work at all! If you like to dig into edge-cases or write testing scenarios,
wrangling our testing infrastructure could be the job for you.

We use both [Circle CI](https://circleci.com/) and [Travis](https://travis-ci.org/)
for continuous integration, and we're currently building out a
["test lab"](https://github.com/libp2p/testlab) for testing large-scale system
interactions.

We'd be thrilled if you'd like to contribute, whether by improving our CI
infrastructure, adding or fixing test cases, or simply raising issues to
highlight things that would make our testing strategy more comprehensive and
reliable.

### Design

Network stacks need designers too! There are many small places throughout all
our projects that could use your design love.

**We currently don't have a single place for this. If you'd like to start it, please let us know**


### Issues / Triaging

With lots of code come lots of Github Issues. We need YOU to help with
organizing all of this in some manner. We don’t yet have any proper resources
for getting started with this. Get in touch if you can contribute a sense of
extreme organization!

**We currently don't have a single place for this. If you'd like to start it, please let us know**


### Community

If interacting with people is your favorite thing to do in this world, libp2p and
co. are always happy to help you organize events and/or workshops to teach and
explore libp2p.

We have a repository (https://github.com/libp2p/community) for organizing
community events and would love your help to have meetups in more locations or
make the existing ones more regular.


### Applications

libp2p is designed for others to build applications with! Building
applications and services using libp2p is an excellent way to find use cases
where libp2p doesn’t yet do a perfect job or uncover bugs and inefficiencies.


### Protocol Design

libp2p is ultimately about building better protocols, and we always welcome ideas
and feedback on how to improve those protocols. Feedback, issues, and
proposals are all welcome in the [specs repo](https://github.com/libp2p/specs).

### Research

Finally, we see Protocol Labs as a research lab, where YOUR ideas can become
technologies that have a real impact on the world. If you're interested in
contributing to our research, please reach out to research@protocol.ai for
more information. Include what your interests are so we can make sure you get to
work on something fun and valuable.
