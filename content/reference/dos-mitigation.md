---
title: "DOS Mitigation"
weight: 3
---

DOS mitigation is an essential part of any P2P application. We need to design
our protocols to be resilient to malicious peers. We need to monitor our
application for signs of suspicious activity or an attack. And we need to be
able to respond to an attack.

Here we'll cover how we can use libp2p to achieve the above goals.

# Table of contents

- [What we mean by a DOS attack](#what-we-mean-by-a-dos-attack)
- [Incoporating DOS mitigation from the start](#incoporating-dos-mitigation-from-the-start)
  - [Limit the number of concurrent streams your protocol needs](#limit-the-number-of-concurrent-streams-your-protocol-needs)
  - [Limit the number of connections your application needs](#limit-the-number-of-connections-your-application-needs)
  - [Reduce blast radius](#reduce-blast-radius)
  - [Fail2ban](#fail2ban)
  - [Leverage the resoure manager to limit resource (go-libp2p only)](#leverage-the-resoure-manager-to-limit-resource-go-libp2p-only)
  - [Rate limiting incoming connections (go-libp2p only)](#rate-limiting-incoming-connections-go-libp2p-only)
- [Monitoring your application](#monitoring-your-application)
- [Responding to an attack](#responding-to-an-attack)
  - [Who’s misbehaving?](#whos-misbehaving)
  - [How to block a misbehaving peer](#how-to-block-a-misbehaving-peer)
  - [How to automate blocking with fail2ban](#how-to-automate-blocking-with-fail2ban)
- [Summary](#summary)

# What we mean by a DOS attack

A DOS attack is any attack that can cause your application to crash, stall, or
otherwise fail to respond normally. An attack is considered viable if it takes
fewer resources to execute than the damage it does. In other words, if the
payoff is higher than the investment it is a viable attack and should be
mitigated. Here are a couple examples

1. One server opening many connections to a remote server and forcing that
   server to spend 10x the compute time to handle the request relative to the
   attacker server. This is attack viable because a single server amplifies it's
   affect 10x. This attack will continue to scale if the attacker adds more
   servers.

2. 100 servers asking a single server to do some work, but if this single server
   goes down it will indirectly cause the loss of an asset. If the asset is more
   valuable than the compute time of 100 servers, this attack is viable.

3. Many servers connecting to a single server such that that server can no
   longer accept new connections from an honest peer. This server is now
   isolated from the honest peers in the network. This is commonly called an
   eclipse attack and is viable if it's either cheap to eclipse this node, or if
   eclipsing this node has a high payoff.

Generally the effect on our application can range from crashing to stalling to
failing to handle new peers to degraded performance. Ideally we want
our application to at worst suffer a slight perfomance penalty, but otherwise
stay up and healthy.

In the next section we'll cover some design strategies you should incorporate
into your protocol to make sure your application stays up and healthy.

# Incoporating DOS mitigation from the start

The general strategy is to use the minimum amount of resources as possible, and
make sure that there's no untrusted amplification mechanism (e.g. an untrusted
node can force you do to 10x the work it does). A protocol level reputation
system can help (take a look at [GossipSub](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub) for inspiration) as well as
logging misbehaving nodes and actioning those logs separately (see fail2ban
below).

Here are some more specific recommendations

## Limit the number of concurrent streams your protocol needs

Each stream has some resource cost associated with it. Depending on the
transport and multiplexer, this can be bigger or smaller. Try to avoid having
too many concurrent streams open per peer for your protocol. Instead try to
limit the maximum number of concurrent streams to something reasonable (surely
you don't need >512 streams open at once for a peer?). Multiple concurrent
streams can be useful for logic or to avoid [Head-of-line
blocking](https://en.wikipedia.org/wiki/Head-of-line_blocking), but having too
many streams will offset these benefits.

Using a stream for a short period of time and then closing it is fine. It's
really the number of _concurrent_ streams that you need to be careful of.

## Limit the number of connections your application needs

Like streams, each connection has a resource cost associated with it. A
connection will usually represent a peer and a set of protocols with each their
own resource usage. So limiting connections can have a leveraged effect on your
resource usage. 

In go-libp2p the number of active connections is managed by the
[`connmgr`](https://pkg.go.dev/github.com/libp2p/go-libp2p@v0.21.0/p2p/net/connmgr#BasicConnMgr.Protect).
`ConnManager` will trim connections when you hit the high watermark number of
connections. You can protect certain connections with the `.Protect` method.

In rust-libp2p handlers should implement
[`connection_keep_alive`](https://docs.rs/libp2p/0.46.1/libp2p/swarm/trait.ConnectionHandler.html#tymethod.connection_keep_alive)
to define when a connection can be closed.

## Reduce blast radius

If you can split up your libp2p application into multiple separate processes you
can increase the resiliency of your overall system. For example your node may
have to help achieve consensus and respond to user queries. By splitting this up
into two processes you now rely on the OS’s guarantee that the user query
process won’t take down the consensus process.

## Fail2ban

If you can log when a peer is misbehaving or is malicious, you can then hook up
those logs to fail2ban and have fail2ban manage your firewall to automatically
block misbehaving nodes. go-libp2p includes some builtin support for this
usecase. More details below.


## Leverage the resoure manager to limit resource (go-libp2p only)

go-libp2p includes a powerful [resource
manager](https://github.com/libp2p/go-libp2p-resource-manager) that keeps track 
of resources used for each protocol, peer, connection, and more. You can use it
within your protocol implementation to make sure you don't allocate more than
some predetermined amount of memory per connection. It's basically a resource
accounting abstraction that you can make use of in your own application.

## Rate limiting incoming connections (go-libp2p only)

Depending on your use case, it can help to limit the number of inbound
connections. You can use go-libp2p's
[ConnectionGater](https://pkg.go.dev/github.com/libp2p/go-libp2p-core/connmgr#ConnectionGater)
and `InterceptAccept` for this. For a concrete example, take a look at how Prysm
implements their (Connection
Gater)[https://github.com/prysmaticlabs/prysm/blob/63a8690140c00ba6e3e4054cac3f38a5107b7fb2/beacon-chain/p2p/connection_gater.go#L43].

# Monitoring your application

Once we've designed our protocols to be resilient to DOS attacks and deployed
them, we then need to monitor our application to both verify our mitigation works
and to be alerted if a new attack vector is exploited.


Monitoring is implementation specific, so consult the links below to see how
your implementation does it.


For rust-libp2p look at the [libp2p-metrics crate](https://github.com/libp2p/rust-libp2p/tree/master/misc/metrics).

For go-libp2p resource usage take a look at the OpenCensus metrics exposed by the resource
manager
[here](https://pkg.go.dev/github.com/libp2p/go-libp2p-resource-manager@v0.5.2/obs).
In general go-libp2p wants to add more metrics across the stack in the future,
this work is being tracked in issue
[go-libp2p#1356](https://github.com/libp2p/go-libp2p/issues/1356).

# Responding to an attack

When you see that your node is being attacked (e.g. crashing, stalling, high cpu
usage), then the next step is responding to the attack.

## Who’s misbehaving?

To answer the question of which peer is misbehaving and harming you, go-libp2p
exposes a [canonical log
lines](https://github.com/libp2p/go-libp2p-core/blob/master/canonicallog/canonicallog.go#L18)
that identifies a misbehaving peers. A canonical log line is simply a log line
with a special format. For example here’s a peer status log line that tells us a
peer established a connection with us, and that this log line was randomly
sampled (1 out of 100).

```
Jul 27 12:14:14 ipfsNode ipfs[46133]: 2022-07-27T12:14:14.674Z        INFO        canonical-log        swarm/swarm_listen.go:128        CANONICAL_PEER_STATUS: peer=12D3KooWSbNLGMYeUuMSXDiHwbhXHzTJaWZzH95MZzeAob9BeB51 addr=/ip4/147.75.74.239/udp/4001/quic sample_rate=100 connection_status="established" dir="inbound"
```

To see these kinds of logs make sure you’ve enabled the `"canonical-log=info"`
log level. You can do this in code like
[so](https://github.com/libp2p/go-libp2p-core/blob/master/canonicallog/canonicallog_test.go#L14),
or by setting the environment variable `GOLOG_LOG_LEVEL="canonical-log=info"`.

In rust-libp2p you can do something similar yourself by logging a sample of
connection events from [SwarmEvent](https://docs.rs/libp2p/0.46.1/libp2p/swarm/enum.SwarmEvent.html).

## How to block a misbehaving peer

Once you’ve identified the misbehaving peer, you can block them with `iptables`
or `ufw`. Here we’ll outline how to block the peer with `ufw`. You can get the
ip address of the peer from the
[multiaddr](https://github.com/multiformats/multiaddr) in the log.

```bash
sudo ufw deny from 1.2.3.4
```

## How to automate blocking with fail2ban

You can hook up [fail2ban](https://www.fail2ban.org) to
automatically block connections from these misbehaving peers if they emit this
log line multiple times in some period of time. For example, a simple fail2ban
filter for go-libp2p would look like this:

```
[Definition]
failregex = ^.*[\t\s]CANONICAL_PEER_STATUS: .* addr=\/ip[46]\/<HOST>[^\s]*
```
`/etc/fail2ban/filter.d/go-libp2p-peer-status.conf`

This matches any canonical peer status logs. If a peer shows up often in these
sampled logs, something abnormal is happening. i.e. maybe they are churning
connections.

A conservative fail2ban rule for go-libp2p using the above filter would look
like this:

```
[go-libp2p-weird-behavior-iptables]
# Block an IP address if it fails a handshake or reconnects more than
# 50 times a second over the course of 3 minutes. Since
# we sample at 1% this means we block if we see more
# than 90 failed handshakes over 3 minutes. (50 logs/s * 1% = 1 log every 
# 2 seconds. for 60 * 3 seconds = 90 reqs in 3 minutes.)
enabled  = true
filter   = go-libp2p-peer-status
action   = iptables-allports[name=go-libp2p-fail2ban]
backend = systemd[journalflags=1]
# This uses systemd for logging. 
# This assumes you have a systemd service named ipfs-daemon.
journalmatch = _SYSTEMD_UNIT=ipfs-daemon.service
findtime = 180 # 3 minutes
bantime  = 600 # 10 minutes
maxretry = 90
```
`/etc/fail2ban/jail.d/go-libp2p-weird-behavior-iptables.conf`

Note that the above configuration is relying on systemd to get the logs for
ipfs. This will be different depending on your go-libp2p process.

For completeness here’s my systemd service definition for a [Kubo instance](https://github.com/ipfs/kubo):

```
$ cat /etc/systemd/system/ipfs-daemon.service
[Unit]
After=network.target
Description=ipfs-daemon

[Service]
Environment="LOCALE_ARCHIVE=/nix/store/r4jm7wfirgdr84zmsnq5qy7hvv14c7l7-glibc-locales-2.34-210/lib/locale/locale-archive"
Environment="PATH=/nix/store/7jr7pr4c6yb85xpzay5xafs5zlcadkhz-coreutils-9.0/bin:/nix/store/140f6s4nwiawrr3xyxarmcv2mk62m62y-findutils-4.9.0/bin:/nix/store/qd9jxc0q00cr7fp30y6jbbww20gj33lg-gnugrep-3.7/bin:/nix/store/lgvd2fh4cndlv8mnyy49jp1nplpml3xp-gnused-4.8/bin:/nix/store/0f3ncs289m2x1vmv2b3grd6l9x1yp2m3-systemd-250.4/bin:/nix/store/7jr7pr4c6yb85xpzay5xafs5zlcadkhz-coreutils-9.0/sbin:/nix/store/140f6s4nwiawrr3xyxarmcv2mk62m62y-findutils-4.9.0/sbin:/nix/store/qd9jxc0q00cr7fp30y6jbbww20gj33lg-gnugrep-3.7/sbin:/nix/store/lgvd2fh4cndlv8mnyy49jp1nplpml3xp-gnused-4.8/sbin:/nix/store/0f3ncs289m2x1vmv2b3grd6l9x1yp2m3-systemd-250.4/sbin"
Environment="TZDIR=/nix/store/n83qx7m848kg51lcjchwbkmlgdaxfckf-tzdata-2022a/share/zoneinfo"

Environment=GOLOG_LOG_LEVEL="canonical-log=info" LIBP2P_RCMGR=1
ExecStart=/nix/store/mmvd2akskpaszlradl8qv4v703v1cy11-kubo-0.0.1/bin/ipfs daemon
Restart=always
RestartSec=1min
User=ipfs
```

### Example screen recording of fail2ban in action

[fail2ban+go-libp2p.mov](./assets/fail2bango-libp2p.mov)

### Setting Up fail2ban

For a general guide to setting up fail2ban, consult this useful tutorial:
[How to protect ssh with fail2ban on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-20-04).
We’ll focus on the specifics around fail2ban and go-libp2p here.

Once you have fail2ban installed simple copy the above files into their
respective places. The filter definition into
`/etc/fail2ban/filter.d/go-libp2p-peer-status.conf` and the rule into
`/etc/fail2ban/jail.d/go-libp2p-weird-behavior-iptables.conf`. Remember you may
need to tweak the rule to read from the correct log location or change the
systemd service name. Also remember you need to enable the canonical log level
(see the above section for how to enable this log level). Finally restart
fail2ban to reload the configuration with `systemctl restart fail2ban`.

Verify our jail is active by running `fail2ban-client status
go-libp2p-weird-behavior-iptables`. If you see something like:

```
Status for the jail: go-libp2p-weird-behavior-iptables
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     0
|  `- Journal matches:  _SYSTEMD_UNIT=ipfs-daemon.service
`- Actions
   |- Currently banned: 0
   |- Total banned:     0
   `- Banned IP list:
```

Then you’re good to go! You’ve successfully set up a go-libp2p jail.

# Summary

Mitigating DOS attacks is hard because an attacker needs only one flaw, while a
protocol developer needs to cover _all_ their bases. Libp2p provides some tools
to design better protocols, but developers should still monitor their
applications to protect against novel attacks. Finally developers should
leverage existing tools like `fail2ban` to automate blocking misbehaving nodes
by logging when peers behave maliciously.