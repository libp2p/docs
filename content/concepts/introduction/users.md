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
| **[IPFS](https://ipfs.tech/)** | IPFS created and still uses libp2p for decentralized peer-to-peer communication and content distribution. IPFS has achieved significant growth to hundreds of thousands of nodes worldwide. |
| **[Filecoin](https://filecoin.io/)** | Filecoin has become the largest decentralized storage network, surpassing competitors in storage capacity and adoption. Different implementations of Filecoin network use different libp2p implementations (Go, Rust, JavaScript) to ensure robust network performance and reliability. |
| **[Ethereum](https://ethereum.org/en/)** | The [integration of libp2p into the Ethereum Beacon Chain](https://blog.libp2p.io/libp2p-and-ethereum/) has been instrumental in achieving scalability and decentralization in the network's upgrade to proof-of-stake. Ethereum relies on go-libp2p, rust-libp2p, js-libp2p, dotnet-libp2p, jvm-libp2p, nim-libp2p and more!|
| **[Algorand](https://algorand.co/)** | Algorand is [integrating libp2p to transition away](https://algorand.co/technology/roadmap) from relying on centralized relay nodes, moving towards a more decentralized network. |
| **[Avail](https://www.availproject.org/)** | By utilizing libp2p, Avail has created a robust, scalable, and efficient light client network that enhances its data availability guarantees and improves client performance. |
| **[Base Network (Coinbase)](https://www.base.org/)** | Base is built on the [OP Stack](https://docs.optimism.io/stack/getting-started) and as a result, leverages libp2p. Base has created a robust peer-to-peer infrastructure that can handle efficient communication between nodes, crucial for decentralized applications. |
| **[Berty](https://berty.tech/)** | Berty is a secure, privacy-focused messaging app leveraging a custom version of OrbitDB on top of libp2p to organize and store messages in a decentralized manner. |
| **[Celestia](https://celestia.org/)** | Celestia uses libp2p for its data availability sampling (DAS) network, which enables light nodes to perform DAS by querying random data shares and verifying their availability. |
| **[Ceramic Network](https://ceramic.network/)** | Ceramic's use of libp2p has contributed to its ability to handle high-volume application data with web-scale volume and latency; libp2p has also enabled Ceramic to build a decentralized data persistence layer. |
| **[Drand / Randamu](https://drand.love/)** | Libp2p enables direct peer-to-peer communication between Drand nodes, allowing for decentralized randomness generation and distribution. |
| **[EdgeVPN](https://edgevpn.io/)** | EdgeVPN uses a lightweight blockchain built on top of libp2p to store and propagate network metadata, such as service UUIDs, IP addresses, and DNS records. This ensures resilient and decentralized network management. |
| **[Espresso Systems](https://www.espressosys.com/)** | The implementation of libp2p has facilitated Espresso's goal of enabling cross-chain interactions that operate as if on one chain. |
| **[Fluence Network](https://www.fluence.network/)** | Fluence Network and products (Nox, Aquavm) use of libp2p has contributed to its ability to provide verifiable computation, a crucial feature for ensuring trust in decentralized applications. |
| **[Flow](https://flow.com/)** | Flow has established itself as a leading blockchain for NFTs and decentralized applications, partly due to its efficient networking layer built on libp2p. |
| **[Huddle01](https://huddle01.com/)** | Huddle01 aims to reduce costs by 95% compared to traditional centralized communication platforms like Zoom, Skype, and Google Meet, partly due to its efficient use of libp2p. |
| **[Iotex Project](https://iotex.io/)** | IoTeX uses libp2p for its robust networking infrastructure and peer-to-peer connectivity. |
| **[Lighthouse](https://lighthouse.sigmaprime.io/)** | Developed by Sigma Prime, Lighthouse is consensus client of the Ethereum Beacon Chain and utilizes rust-libp2p. Lighthouse often powers [>= 1/3 of the Beacon Chain](https://monitoreth.io/nodes). |
| **[Magi](https://github.com/a16z/magi)** | Magi is an [OP Stack](https://docs.optimism.io/stack/getting-started) rollup client developed by Andreessen Horowitz (a16z) that implements libp2p as part of its networking stack. |
| **[Mantle](https://www.mantle.xyz/)** | Mantle's use of libp2p contributes to its efficient peer-to-peer communication and block propagation, which are crucial for its L2 solution. |
| **[Mina Protocol](https://minaprotocol.com/)** | By leveraging libp2p, Mina has achieved a lightweight blockchain of only 22KB, enabling efficient scalability and decentralized communication. This has helped Mina to maintain decentralization without compromising performance. |
| **[Moonbeam](https://moonbeam.network/)** | libp2p enables seamless communication between different blockchain networks, which aligns with Moonbeam's goal of providing an easy path to multi-chain implementation and interoperability. |
| **[MultiversX](https://multiversx.com/)** | MultiversX's adoption of libp2p has contributed to improved connectivity with support for multiple transport protocols. |
| **[Nethermind](https://www.nethermind.io/)** | By leveraging libp2p, Nethermind has positioned its projects (Juno and dotnet-libp2p) to contribute significantly to the decentralization and robustness of the Ethereum ecosystem. |
| **[Nillion](https://nillion.com/)** | Compute nodes in the Nillion network are configured as relay servers using libp2p's Circuit Relay protocol. |
| **[Nym](https://nym.com/)** | Nym's mixnet technology is integrated with libp2p to provide network-level privacy protection. The Nym libp2p module can be used by Ethereum validators to shield their network traffic from surveillance. |
| **[Oasis Protocol](https://oasisprotocol.org/)** | Oasis utilizes libp2p for peer-to-peer communication in its consensus layer, which is responsible for maintaining the network's state and validating transactions. |
| **[Optimism](https://optimism.io/)** | Optimism mainnet uses libp2p as a core component of its networking infrastructure, particularly in its op-node implementation. Furthermore, the Optimism Collective have developed the standardized, shared, and open-source development stack called [OP Stack](https://docs.optimism.io/stack/getting-started) which enables the creation of new L2 blockchains that rely on libp2p.|
| **[Peergos](https://peergos.org/)** | Peergos uses libp2p to build a peer-to-peer encrypted global filesystem with fine-grained access control, enhancing user privacy and data security. |
| **Polkadot** | Polkadot leverages libp2p as part of its Substrate-based architecture. Libp2p enables Polkadot's scalability by facilitating seamless communication across its heterogeneous blockchain network. |
| **[Prysm](https://prysmaticlabs.com/)** | Developed by Prysmatic Labs, Prysm is powered by libp2p powers the Ethereum consensus network alongside other clients, contributing to client diversity in the Ethereum ecosystem. Prysm of often powers [~1/3 of the Beacon Chain](https://monitoreth.io/nodes). |
| **[Spacedrive](https://www.spacedrive.com/)** | Spacedrive implements a lazy connection system using libp2p, which establishes connections only when needed and closes them after a period of inactivity, enhancing resource efficiency. |
| **[Spritely](https://spritely.institute/)** | Spritely uses libp2p as a networking layer for its Goblins distributed object programming environment. |
| **[Starknet](https://www.starknet.io/)** | Starknet's p2p network is divided into three networks (Sync, Mempool, Consensus), all of which use libp2p for different purposes. libp2p facilitates efficient communication and coordination among these networks and its products (Pathfinder / Madara). |
| **[Status-go / status.im](https://status.app/)** | Status has developed nim-libp2p, a Nim implementation of libp2p, which is used in projects like Codex, Waku, and Nimbus. |
| **[Taiko Labs](https://taiko.xyz/)** | Taiko Labs has leveraged libp2p to build a robust, scalable, and efficient ZK-Rollup infrastructure. |
| **[webAI](https://www.webai.com/)** | webAI uses libp2p to provide a distributed AI model training and inference platform for businesses. |

This list of notable users is incomplete and constantly growing. Additions are welcome and can be added via [PR on Github](https://github.com/libp2p/docs/pulls).
