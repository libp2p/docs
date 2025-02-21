---
title: "Who uses libp2p"
description: libp2p is used by many blockchain networks, p2p applications, and edge computing projects.
weight: 19
aliases:
  - "/introduction/libp2p-users"
---

When learning about libp2p, it can be helpful to understand how various projects and applications have integrated and benefitted from libp2p over the years.
As a modular peer-to-peer networking framework, usage of libp2p can look very different when powering large-scale blockchain networks, vs enabling robust p2p applications, vs underpinning flexible edge computing and agent coordination.

A few notable users of libp2p include (3 most notable users listed first with the rest in alphabetical order):

| Project | Description |
|---------------|---------------------------------|
| **[IPFS](https://ipfs.tech/)** | IPFS initially created and still uses libp2p for decentralized peer-to-peer communication and content distribution. IPFS has achieved significant growth to hundreds of thousands of nodes worldwide. |
| **[Filecoin](https://filecoin.io/)** | Filecoin has become the largest decentralized storage network, surpassing competitors in storage capacity and adoption. It uses libp2p to ensure robust network performance and reliability. |
| **[Ethereum](https://ethereum.org/en/)** | The [integration of libp2p into Ethereum 2.0](https://blog.libp2p.io/libp2p-and-ethereum/) has been instrumental in achieving scalability and decentralization in the network's upgrade to proof-of-stake. |
| **[Algorand](https://algorand.co/)** | Algorand is [integrating libp2p to transition away](https://algorand.co/technology/roadmap) from relying on centralized relay nodes, moving towards a more decentralized network. |
| **Arbitrum** | Arbitrum, which uses libp2p as part of its networking stack, has established itself as the most dominant and adopted L2 chain in the Ethereum rollup ecosystem, commanding approximately 65% of the market share. |
| **[Avail](https://www.availproject.org/)** | By utilizing libp2p, Avail has created a robust, scalable, and efficient light client network that enhances its data availability guarantees and improves client performance. |
| **[Base Network (Coinbase)](https://www.base.org/)** | By leveraging libp2p, Base has created a robust peer-to-peer infrastructure that can handle efficient communication between nodes, crucial for decentralized applications. |
| **[Berty](https://berty.tech/)** | Berty is a secure, privacy-focused messaging app leveraging a custom version of OrbitDB on top of libp2p to organize and store messages in a decentralized manner. |
| **[Celestia](https://celestia.org/)** | Celestia uses libp2p for its data availability sampling (DAS) network, which enables light nodes to perform DAS by querying random data shares and verifying their availability. |
| **[Ceramic Network](https://ceramic.network/)** | Ceramic's use of libp2p has contributed to its ability to handle high-volume application data with web-scale volume and latency; libp2p has also enabled Ceramic to build a decentralized data persistence layer. |
| **[Drand / Randamu](https://drand.love/)** | Libp2p enables direct peer-to-peer communication between Drand nodes, allowing for decentralized randomness generation and distribution. |
| **[EdgeVPN](https://edgevpn.io/)** | EdgeVPN uses a lightweight blockchain built on top of libp2p to store and propagate network metadata, such as service UUIDs, IP addresses, and DNS records. This ensures resilient and decentralized network management. |
| **[Espresso Systems](https://www.espressosys.com/)** | The implementation of libp2p has facilitated Espresso's goal of enabling cross-chain interactions that operate as if on one chain. |
| **[Fluence Network](https://www.fluence.network/), nox, aquavm** | Fluence's use of libp2p has contributed to its ability to provide verifiable computation, a crucial feature for ensuring trust in decentralized applications. |
| **[Flow](https://flow.com/)** | Flow has established itself as a leading blockchain for NFTs and decentralized applications, partly due to its efficient networking layer built on libp2p. |
| **[Huddle01](https://huddle01.com/)** | Huddle01 aims to reduce costs by 95% compared to traditional centralized communication platforms like Zoom, Skype, and Google Meet, partly due to its efficient use of libp2p. |
| **[Iotex Project](https://iotex.io/)** | IoTeX uses libp2p for its robust networking infrastructure and peer-to-peer connectivity. |
| **[Lighthouse (Sigma Prime)](https://lighthouse.sigmaprime.io/)** | The adoption of libp2p aligns with Lighthouse's security-first mindset, allowing for extensive reviews and monitoring of the network's peer-to-peer communication. |
| **[Magi (by a16z)](https://github.com/a16z/magi)** | Magi is an OP Stack rollup client developed by Andreessen Horowitz (a16z) that implements libp2p as part of its networking stack. |
| **[Mantle](https://www.mantle.xyz/)** | Mantle's use of libp2p contributes to its efficient peer-to-peer communication and block propagation, which are crucial for its L2 solution. |
| **[Mina Protocol](https://minaprotocol.com/)** | By leveraging libp2p, Mina has achieved a lightweight blockchain of only 22KB, enabling efficient scalability and decentralized communication. This has helped Mina to maintain decentralization without compromising performance. |
| **[Moonbeam](https://moonbeam.network/)** | libp2p enables seamless communication between different blockchain networks, which aligns with Moonbeam's goal of providing an easy path to multi-chain implementation and interoperability. |
| **[MultiversX](https://multiversx.com/)** | MultiversX's adoption of libp2p has contributed to improved connectivity with support for multiple transport protocols. |
| **[Nethermind](https://www.nethermind.io/), juno, dotnet-libp2p** | By leveraging libp2p, Nethermind has positioned its projects (Juno and dotnet-libp2p) to contribute significantly to the decentralization and robustness of the Ethereum ecosystem. |
| **[Nym](https://nym.com/)** | Nym's mixnet technology is integrated with libp2p to provide network-level privacy protection. The Nym libp2p module can be used by Ethereum validators to shield their network traffic from surveillance. |
| **[Oasis Protocol](https://oasisprotocol.org/)** | Oasis utilizes libp2p for peer-to-peer communication in its consensus layer, which is responsible for maintaining the network's state and validating transactions. |
| **[Optimism](https://optimism.io/)** | Optimism mainnet uses libp2p as a core component of its networking infrastructure, particularly in its op-node implementation. |
| **[Peergos](https://peergos.org/)** | Peergos uses libp2p to build a peer-to-peer encrypted global filesystem with fine-grained access control, enhancing user privacy and data security. |
| **Polkadot** | Polkadot leverages libp2p as part of its Substrate-based architecture. Libp2p enables Polkadot's scalability by facilitating seamless communication across its heterogeneous blockchain network. |
| **[Prysm (Prysmatic Labs)](https://prysmaticlabs.com/)** | The adoption of libp2p has allowed Prysm to be interoperable with other Ethereum consensus clients, contributing to client diversity in the Ethereum ecosystem. |
| **[Spacedrive](https://www.spacedrive.com/)** | Spacedrive implements a lazy connection system using libp2p, which establishes connections only when needed and closes them after a period of inactivity, enhancing resource efficiency. |
| **[Spritely](https://spritely.institute/)** | Spritely uses libp2p as a networking layer for its Goblins distributed object programming environment. |
| **[Starknet](https://www.starknet.io/), Pathfinder / Madara** | Starknet's p2p network is divided into three networks (Sync, Mempool, Consensus), all of which use libp2p for different purposes. libp2p facilitates efficient communication and coordination among these networks. |
| **[Status-go / status.im](https://status.app/)** | Status has developed nim-libp2p, a Nim implementation of libp2p, which is used in projects like Codex, Waku, and Nimbus. |
| **[Taiko Labs](https://taiko.xyz/)** | Taiko Labs has leveraged libp2p to build a robust, scalable, and efficient ZK-Rollup infrastructure. |
| **[Uniswap](https://uniswap.org/)** | Ethereum's transition to proof-of-stake, facilitated in part by libp2p, has created a more sustainable and efficient environment for decentralized applications like Uniswap to operate. |
| **[webAI](https://www.webai.com/)** | webAI uses libp2p to provide a distributed AI model training and inference platform for businesses. |

This list of notable users is incomplete and constantly growing. Additions are welcome and can be added via [PR on Github](https://github.com/libp2p/docs/pulls).
