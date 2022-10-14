---
title: "Secure Communication"
weight: 3
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
summary: Before two peers can transmit data, the communication channel they established with a transport protocol should be secure. Learn about secure channels in libp2p.
---

# Secure bytes

Before two peers can transmit data, the communication channel they established 
with a transport protocol should be secure. A transport protocol like QUIC provides 
security guarantees out-of-the-box, but other transports in libp2p do not provide the 
logic to secure their channel. This requires an upgrade to the transport using an upgrader.
Security is always established first over the raw connection. 

{{% notice "info" %}}
Several security protocols are supported in libp2p for encryption, the two primary 
ones being Noise and TLS 1.3.
{{% /notice %}}

{{% children description="true"%}}
