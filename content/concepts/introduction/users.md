---
title: "Who uses libp2p"
description: libp2p is used by many blockchain networks, p2p applications, and edge computing projects.
weight: 19
aliases:
  - "/introduction/libp2p-users"
---

When learning about libp2p, it can be helpful to understand how various projects and applications have integrated and benefitted from libp2p over the years.
As a modular peer-to-peer networking framework, usage of libp2p can look very different when powering large-scale blockchain networks, vs enabling robust p2p applications, vs underpinning flexible edge computing and agent coordination.

A few notable users of libp2p include:

| Project | Description |
|---------------|---------------------------------|
| **IPFS** | IPFS initially created and still uses libp2p for decentralized peer-to-peer communication and content distribution. IPFS has achieved significant growth to hundreds of thousands of nodes and billions of weekly content requests, where libp2p enables efficient and secure peer-to-peer communication & interop. |
| **Filecoin** | Filecoin has become the largest decentralized storage network, surpassing competitors in storage capacity and adoption. It uses libp2p to ensure robust networking, peer discovery, routing, and message propagation - enabling efficient data storage and retrieval. |
| **Ethereum** | The integration of libp2p into Ethereum 2.0 has been instrumental in achieving scalability and decentralization. It also played a key role in the network's transition to proof-of-stake, which reduced energy consumption by 99.95%. |
| **Optimism** | Optimism uses libp2p as a core component of its networking infrastructure, particularly in its op-node implementation. |
| **Celestia** | Celestia uses libp2p for its data availability sampling (DAS) network, which enables light nodes to perform DAS by querying random data shares and verifying their availability. |
| **Polkadot** | Polkadot leverages libp2p as part of its Substrate-based architecture. Libp2p enables Polkadot's scalability by facilitating seamless communication across its heterogeneous blockchain ecosystem, including parachains and parathreads. |
| **Radicle** | Radicle is a p2p code collaboration platform for distributed version control without intermediaries. It uses libp2p for peer discovery and connections, its p2p gossip protocol, and transport encryption. |
| **MetaMask** | MetaMask leverages libp2p's capabilities for cryptographic key management directly in the browser, enhancing security and user control. In addition, MetaMask has created js-libp2p-multicast-conditional, a tool for conditional multicast using libp2p, further expanding the ecosystem's capabilities. |
| **Uniswap** | Ethereum's transition to proof-of-stake, facilitated in part by libp2p, has created a more sustainable and efficient environment for decentralized applications like Uniswap to operate. |
| **Base Network (Coinbase)** | By leveraging libp2p, Base has created a robust peer-to-peer infrastructure that can handle efficient communication between nodes, crucial for its role in scaling Ethereum transactions. |
| **Polygon** | The Polygon Edge framework and Polygon Supernets leverage libp2p for modular, extensible, and fast networking, enabling features like block syncing and consensus. By leveraging libp2p, Polygon has created a scalable infrastructure that can handle millions of transactions per day smoothly. |
| **Starknet, Pathfinder / Madara** | Starknet's p2p network is divided into three networks (Sync, Mempool, Consensus), all of which use libp2p for different purposes. libp2p enables Starknet to implement custom security policies, auth requirements, and capability filtering for each network separately. |
| **Huddle01** | Huddle01 aims to reduce costs by 95% compared to traditional centralized communication platforms like Zoom, Skype, and Google Meet, partly due to its efficient p2p infrastructure powered by libp2p. |
| **Espresso Systems** | The implementation of libp2p has facilitated Espresso's goal of enabling cross-chain interactions that operate as if on one chain. |
| **Magi (by a16z)** | Magi is an OP Stack rollup client developed by Andreessen Horowitz (a16z) that implements libp2p as part of its networking stack. |
| **Berty** | Berty is a secure, privacy-focused messaging app leveraging a custom version of OrbitDB on top of libp2p to organize and store messages in a decentralized manner. |
| **Flow** | Flow has established itself as a leading blockchain for NFTs and decentralized applications, partly due to its efficient networking layer built on libp2p. |
| **Oasis** | Oasis Network utilizes libp2p for peer-to-peer communication in its consensus layer, which is responsible for maintaining the network's state and validating transactions. |
| **Mina** | By leveraging libp2p, Mina has achieved a lightweight blockchain of only 22KB, enabling efficient scalability and decentralized communication. This has significantly enhanced the network's performance and accessibility. |
| **EdgeVPN** | EdgeVPN uses a lightweight blockchain built on top of libp2p to store and propagate network metadata, such as service UUIDs, IP addresses, and DNS records. This blockchain serves as a coordination mechanism between nodes.|
| **Status-go / status.im** | Status has developed nim-libp2p, a Nim implementation of libp2p, which is used in projects like Codex, Waku, and Nimbus. |
| **Fluence Network, nox, aquavm** | Fluence's use of libp2p has contributed to its ability to provide verifiable computation, a crucial feature for ensuring trust in decentralized systems. |
| **Ceramic** | Ceramic's use of libp2p has contributed to its ability to handle high-volume application data with web-scale volume and latency; libp2p has also enabled IDX, Ceramic's decentralized identity solution. |
| **Nethermind, juno, dotnet-libp2p** | By leveraging libp2p, Nethermind has positioned its projects (Juno and dotnet-libp2p) to contribute significantly to the decentralization and scalability of blockchain networks, particularly in the Ethereum and Starknet ecosystems. |
| **Drand / Randamu** | Libp2p enables direct peer-to-peer communication between Drand nodes, allowing for decentralized randomness generation and distribution. |
| **Anoma** | By leveraging libp2p and introducing sovereign domains, Anoma has created a scalable infrastructure that can accommodate diverse node capabilities and network conditions. |
| **Avail** | By utilizing libp2p, Avail has created a robust, scalable, and efficient light client network that enhances its data availability guarantees and improves user experience in interacting with the blockchain. |
| **Prysm (Prysmatic Labs)** | The adoption of libp2p has allowed Prysm to be interoperable with other Ethereum consensus clients, contributing to client diversity in the ecosystem. |
| **Lighthouse (Sigma Prime)** | The adoption of libp2p aligns with Lighthouse's security-first mindset, allowing for extensive reviews and monitoring of the networking stack. |
| **Arbitrum** | Arbitrum, which uses libp2p as part of its networking stack, has established itself as the most dominant and adopted L2 chain in the Ethereum rollup ecosystem, commanding approximately 50% of the L2 market share. |
| **Spacedrive** | Spacedrive implements a lazy connection system using libp2p, which establishes connections only when needed and closes them after a period of inactivity to preserve battery life and reduce network usage. |
| **Nym** | Nym's mixnet technology is integrated with libp2p to provide network-level privacy protection. The Nym libp2p module can be used by Ethereum validators to shield their network traffic, preventing IP address and metadata leakage. |
| **Mantle** | Mantle's use of libp2p contributes to its efficient peer-to-peer communication and block propagation, which are crucial for its L2 solution. |
| **Nillion** | Compute nodes in the Nillion network are configured as relay servers using libp2p's Circuit Relay protocol. |
| **Aave** | Leveraging libp2p's flexibility, Aave has successfully expanded to multiple blockchain networks, including Ethereum, Polygon, and Avalanche - increasing Aave's ecosystem expansion, with over 100 integrated projects and applications. |
| **Bittorrent** | By leveraging libp2p for peer-to-peer networking and steam management, BTFS has improved its scalability, supporting a growing ecosystem of users and developers. |
| **Internet Computer (IC)** | Internet Computer's networking layer built on libp2p has successfully implemented Byzantine Fault Tolerant (BFT) protocols, enhancing the security and reliability of the IC. |
| **Spritely** | Spritely uses libp2p as a networking layer for its Goblins distributed object programming environment. |
| **Iotex Project** | Since launching in 2019, IoTeX has handled more than 35 million transactions with a 99.9% reliability rate, partly due to its robust networking infrastructure powered by libp2p. |
| **Algorand** | Algorand is implementing libp2p to transition away from relying on centralized relay nodes, moving towards a more decentralized network structure. |
| **Peergos** | Peergos uses libp2p to build a peer-to-peer encrypted global filesystem with fine-grained access control, enhancing user privacy and data security. |
| **Moonbeam** | libp2p enables seamless communication between different blockchain networks, which aligns with Moonbeam's goal of providing an easy path to multi-chain implementation. |
| **MultiversX** | MultiversX's adoption of libp2p has contributed to improved connectivity with support for multiple transport protocols. |
| **Taiko Labs** | Taiko Labs has leveraged libp2p to build a robust, scalable, and efficient ZK-Rollup infrastructure. |

This list of notable users is incomplete and constantly growing. Additions are welcome and can be added via [PR on Github](https://github.com/libp2p/docs/tree/master/content/concepts/introduction).
