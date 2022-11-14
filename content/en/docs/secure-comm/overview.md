---
title : "Overview"
description: "Before two peers can transmit data, the communication channel they established with a transport protocol should be secure. Learn about secure channels in libp2p."
weight: 1
---

Before two peers can transmit data, the communication channel they established
with a transport protocol should be secure. A transport protocol like QUIC provides
security guarantees out-of-the-box, but other transports in libp2p do not provide
the logic to secure their channel. This requires an upgrade to the transport using an
upgrader. Security is always established first over the raw connection.
