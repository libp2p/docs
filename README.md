# libp2p Docs

Home of https://docs.libp2p.io

---------------

This repo is used to:

1. Organize documentation work across the libp2p project.
2. Host the documentation website for libp2p. It gets published to IPFS and made available at https://docs.libp2p.io/.

Check the [issues](https://github.com/libp2p/docs/issues) for updates.


## Overview

libp2p documentation currently has several acute problems:

- There is **no clear introduction to the overall idea of exactly how libp2p works and what it’s doing.**
- libp2p has **lots of new concepts** that are just very different from the web technologies people know today.
- **Docs are inconsistently located** and spread across a number of repos people have to hunt through.
- Clear, **standard API docs** are not always available.
- **Hunting through GitHub is hard.** (Which repos have docs? Where in the repo are they? Which projects are important and how do they relate to the others? Which repos and docs are up-to-date?)

We aim to solve some of these problems through a documentation site (the source of which is in this repo) and others through organizing work, conventions, and practices across project repos (managed in the issues here).

## Contributing content

The documentation site contains several different kinds of content. We’d love ❤️ **your** help with any of it:

1. **Introductory overviews.** This lives in `content/introduction`. If you spot a problem or have improvements, please post an issue or PR.

2. **Guides, examples, and tutorials.** Most examples currently live in other repos, like [js-libp2p examples](https://github.com/libp2p/js-libp2p/tree/master/examples). If you have thoughts on how to better integrate them, please file an issue here. If you have feedback on individual examples or want to add a new one, please file an issue or PR on the relevant repo. If you have ideas for guides or tutorials, they belong here! Please propose them in an issue here before creating a PR.

3. **Concept guides.** Concept guides are intended to present a brief overview to libp2p-related concepts that might be new to people. They live in the `content/concepts` folder and should strive to answer:

    1. **What** is this?
    2. How does it **relate** to the rest of libp2p?
    3. How can (or should?) you **use** it? (This can often vary by implementation)
    4. **Where** do you go to learn more?
    5. What is the **current state** of affairs?

    See a list of concepts we need help with by [checking the issues](https://github.com/libp2p/docs/issues?utf8=✓&q=is%3Aissue+is%3Aopen+label%3Acontent+concept).

4. **Reference Documentation.** Please see the issues in this repo for current activity around reference/API documentation.

5. **Community.** If there are important missing community links, file an issue or PR here!

This repo is also a website, which means we could also use your help with design and technical features (interactive examples, better syntax highlighting, scripts to pull in content from other repos, etc.) in addition to writing. To get a sense of what we could use help on, check the [issues](https://github.com/libp2p/docs/issues). If you decide to work on one, please post to the issue to let us know!

Before posting a PR with your changes, please check [our styleguide](https://github.com/ipfs/community/blob/master/DOCS_STYLEGUIDE.md) and [contributing guide](https://github.com/libp2p/community/blob/master/CONTRIBUTE.md).

Finally, let’s work together to keep this a respectful and friendly space. Please make sure to follow [our code of conduct](https://github.com/ipfs/community/blob/master/code-of-conduct.md).


## Building the Docs Site

### Build and Run the Site

* In the root directory, run `make dev`
* Load http://localhost:1313 in your web browser
* Edit and add things!

To create a production build, run `make build` instead. You’ll find the final static site in the `public` directory.

### CI and publication
  
This site deploys through [Fleek](https://app.fleek.co) to https://docs.libp2p.io

## FAQ

### Why is this is a static site?

We believe in hosting libp2p's documentation on IPFS, and that’s much easier when the content is static.


## License

All software code is copyright (c) Protocol Labs, Inc. under the **MIT license**.

Other written documentation and content is copyright (c) Protocol Labs, Inc. under the [**Creative Commons Attribution-Share-Alike License**](https://creativecommons.org/licenses/by/4.0/).

See [LICENSE file](./LICENSE) for details.
