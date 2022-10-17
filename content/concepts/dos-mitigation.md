---
title: "DoS Mitigation"
weight: 11
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
aliases: /reference/dos-mitigation/
summary: DoS mitigation is an essential part of any peer-to-peer application. Learn how to design protocols to be resilient to malicious peers.
---

# DoS Mitigation

DoS mitigation is an essential part of any peer-to-peer application. We need to design
our protocols to be resilient to malicious peers. We need to monitor our
application for signs of suspicious activity or an attack. And we need to be
able to respond to an attack.

Here we'll cover how we can use libp2p to achieve the above goals.

## Table of contents <!-- omit in toc -->

- [DoS Mitigation](#dos-mitigation)
  - [What we mean by a DOS attack](#what-we-mean-by-a-dos-attack)
  - [Incorporating DOS mitigation from the start](#incorporating-dos-mitigation-from-the-start)
    - [Limit the number of connections your application needs](#limit-the-number-of-connections-your-application-needs)
    - [Transient Connections](#transient-connections)
    - [Limit the number of concurrent streams per connection your protocol needs](#limit-the-number-of-concurrent-streams-per-connection-your-protocol-needs)
    - [Reduce blast radius](#reduce-blast-radius)
    - [Fail2ban](#fail2ban)
    - [Leverage the resource manager to limit resource usage (go-libp2p only)](#leverage-the-resource-manager-to-limit-resource-usage-go-libp2p-only)
    - [Rate limiting incoming connections (go-libp2p only)](#rate-limiting-incoming-connections-go-libp2p-only)
  - [Monitoring your application](#monitoring-your-application)
  - [Responding to an attack](#responding-to-an-attack)
    - [Who’s misbehaving?](#whos-misbehaving)
    - [How to block a misbehaving peer](#how-to-block-a-misbehaving-peer)
    - [How to automate blocking with fail2ban](#how-to-automate-blocking-with-fail2ban)
      - [Example screen recording of fail2ban in action](#example-screen-recording-of-fail2ban-in-action)
      - [Setting Up fail2ban](#setting-up-fail2ban)
    - [Leverage Resource Manager and a set of trusted peers to form an allow list (go-libp2p only)](#leverage-resource-manager-and-a-set-of-trusted-peers-to-form-an-allow-list-go-libp2p-only)
  - [Summary](#summary)

## What we mean by a DOS attack

A DOS attack is any attack that can cause your application to crash, stall, or
otherwise fail to respond normally. An attack is considered viable if it takes
fewer resources to execute than the damage it does. In other words, if the
payoff is higher than the investment it is a viable attack and should be
mitigated. Here are a few examples:

1. A node opening many connections to a remote node and forcing that
   node to spend 10x the compute time to handle the request relative to the
   attacker node. This is attack viable because a single node amplifies its
   affect 10x. This attack will continue to scale if the attacker adds more
   nodes.

2. 100 nodes asking a single node to do some work, but if this single node
   goes down it will indirectly cause the loss of an asset. If the asset is more
   valuable than the compute time of 100 nodes, this attack is viable.

3. Many nodes connecting to a single node such that that node can no
   longer accept new connections from an honest peer. This node is now
   isolated from the honest peers in the network. This is commonly called an
   eclipse attack and is viable if it's either cheap to eclipse this node, or if
   eclipsing this node has a high payoff.

Generally, the effect on our application can range from crashing to stalling to
failing to handle new peers to degraded performance. Ideally we want
our application to at worst suffer a slight performance penalty, but otherwise
stay up and healthy.

In the next section we'll cover some design strategies you should incorporate
into your protocol to make sure your application stays up and healthy.

## Incorporating DOS mitigation from the start

The general strategy is to use the minimum amount of resources as possible and
make sure that there's no untrusted amplification mechanism (e.g. an untrusted
node can force you to do 10x the work it does). A protocol-level reputation
system can help (take a look at [GossipSub](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub) for inspiration) as well as
logging misbehaving nodes and actioning those logs separately (see [fail2ban](#how-to-automate-blocking-with-fail2ban)
below).

Below are some more specific recommendations

### Limit the number of connections your application needs

Each connection has a resource cost associated with it. A connection will
usually represent a peer and a set of protocols with each their own resource
usage. So limiting connections can have a leveraged effect on your resource
usage.

In go-libp2p the number of active connections is managed by the
[`ConnManager`](https://pkg.go.dev/github.com/libp2p/go-libp2p/p2p/net/connmgr).
The `ConnManager` will trim connections when you hit the high watermark number of
connections, and try to keep the number of connections above the low watermark.
You can protect certain connections with the
[`.Protect`](https://pkg.go.dev/github.com/libp2p/go-libp2p/p2p/net/connmgr#BasicConnMgr.Protect)
method. The `ConnManager` is in charge of pruning connections to stay below the
defined high watermark, in contrast, the [Resource Manager](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/resource-manager) represents a hard
limit where connections will fail to be created in the first place once we've
reached our limits. Use the Resource Manager when you need hard limits and the
`ConnManager` when you have a range of connections you want to keep. There are
multiple knobs here that do similar things, so take care to set these. We know
this is not ideal and we are tracking this issue
[here](https://github.com/libp2p/go-libp2p/issues/1640), contributions welcome.


In rust-libp2p handlers should implement
[`connection_keep_alive`](https://docs.rs/libp2p/latest/libp2p/swarm/trait.ConnectionHandler.html#tymethod.connection_keep_alive)
to define when a connection can be closed. The swarm will close connections when
the root behavior no longer needs it.

You can also set hard limits on the number of connections your application is
allowed to use. In go-libp2p this is done by the [Resource
Manager](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/resource-manager) and setting
limits on the [system
scope](https://github.com/libp2p/go-libp2p/blob/v0.22.0/p2p/host/resource-manager/limit_defaults.go#L342).
In rust-libp2p this is done by using
[`ConnectionLimits`](https://docs.rs/libp2p/latest/libp2p/swarm/struct.ConnectionLimits.html)
and passing it to the
[`SwarmBuilder`](https://docs.rs/libp2p/latest/libp2p/swarm/struct.SwarmBuilder.html#method.connection_limits).

### Transient Connections

When a connection is first established to libp2p but before that connection has
been tied to a specific peer (before security and muxer have been negotiated),
it is labeled as "transient" in go-libp2p and "negotiating" in rust-libp2p. Both
go-libp2p and rust-libp2p limit the total number of connections that can be in
this state since it can be an avenue for DOS attacks. The defaults should work
well for most applications, but you may need to change them if your use case
involves supporting a lot of connections at once as quickly as possible, or if
you want to only handle very few connections at once. We recommend not changing
this until you see tangible benefits. And if so, please let us know by filing an
issue – we'd be interested in understanding your use case.

In go-libp2p you can tune this by changing the connection limit in the
[transient
scope](https://github.com/libp2p/go-libp2p/blob/v0.22.0/p2p/host/resource-manager/limit_defaults.go#L342).

In rust-libp2p you can tune this with `ConnectionLimits` as explained above.

### Limit the number of concurrent streams per connection your protocol needs

Each stream has some resource cost associated with it. Depending on the
transport and multiplexer, this can be bigger or smaller. Design your protocol
to avoid having too many concurrent streams open per peer for your protocol.
Instead, try to limit the maximum number of concurrent streams to something
reasonable (surely you don't need >512 streams open at once for a peer?).
Multiple concurrent streams can be useful for logic or to avoid [Head-of-line
blocking](https://en.wikipedia.org/wiki/Head-of-line_blocking), but having too
many streams will offset these benefits.

Using a stream for a short period of time and then closing it is fine. It's
the number of _concurrent_ streams that you need to be careful of.

The Identify protocol serves as an example of how a protocol can limit the
number of concurrent streams it uses. For go-libp2p look at how `pushSemaphore`
is 
[created](https://github.com/libp2p/go-libp2p/blob/v0.22.0/p2p/protocol/identify/id.go#L149)
and
[used](https://github.com/libp2p/go-libp2p/blob/v0.22.0/p2p/protocol/identify/peer_loop.go#L181).
For rust-libp2p look at how
[MAX_NUM_INBOUND_SUBSTREAMS](https://github.com/libp2p/rust-libp2p/blob/v0.47.0/protocols/kad/src/handler.rs#L562)
is used to limit the number of concurrent inbound substreams.

As another example, imagine we are building an RPC-style protocol where responses
take minutes. Here are two ways we could implement it:

1. Open a stream for each RPC call, and keep that stream open until the RPC call
   returns.
2. Open a stream for the start of the call then close it. The remote side will
   open a new stream with the response.

Assume we make a lot of concurrent calls. Method 1 would result in a large
number of concurrent and mostly inactive streams. Method 2 would result in a
fewer number of concurrent streams, and thus lower memory footprint.

If we add a limit in this protocol of say 10 streams, then method 1 will mean
we can only have 10 concurrent RPC calls, while method 2 would let us have a
much larger number of concurrent RPC calls.

### Reduce blast radius

If you can split up your libp2p application into multiple separate processes you
can increase the resiliency of your overall system. For example, your node may
have to help achieve consensus and respond to user queries. By splitting this up
into two processes you now rely on the OS’s guarantee that the user query
process won’t take down the consensus process.

### Fail2ban

If you can log when a peer is misbehaving or is malicious, you can then hook up
those logs to fail2ban and have fail2ban manage your firewall to automatically
block misbehaving nodes. go-libp2p includes some built-in support for this
use case. More details below.

### Leverage the resource manager to limit resource usage (go-libp2p only)

go-libp2p includes a powerful [resource
manager](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/resource-manager) that keeps track 
of resources used for each protocol, peer, connection, and more. You can use it
within your protocol implementation to make sure you don't allocate more than
some predetermined amount of memory per connection. It's basically a resource
accounting abstraction that you can make use of in your own application.

### Rate limiting incoming connections (go-libp2p only)

Depending on your use case, it can help to limit the number of inbound
connections. You can use go-libp2p's
[ConnectionGater](https://pkg.go.dev/github.com/libp2p/go-libp2p-core/connmgr#ConnectionGater)
and `InterceptAccept` for this. For a concrete example, take a look at how Prysm
implements their [Connection
Gater](https://github.com/prysmaticlabs/prysm/blob/63a8690140c00ba6e3e4054cac3f38a5107b7fb2/beacon-chain/p2p/connection_gater.go#L43).

## Monitoring your application

Once we've designed our protocols to be resilient to DOS attacks and deployed
them, we then need to monitor our application both to verify our mitigation works
and to be alerted if a new attack vector is exploited.

Monitoring is implementation specific, so consult the links below to see how
your implementation does it.

For rust-libp2p look at the [libp2p-metrics crate](https://github.com/libp2p/rust-libp2p/tree/master/misc/metrics).

For go-libp2p resource usage take a look at the OpenCensus metrics exposed by the resource
manager
[here](https://pkg.go.dev/github.com/libp2p/go-libp2p-resource-manager/obs).
In general, go-libp2p wants to add more metrics across the stack.
This work is being tracked in issue
[go-libp2p#1356](https://github.com/libp2p/go-libp2p/issues/1356).

## Responding to an attack

When you see that your node is being attacked (e.g. crashing, stalling, high cpu
usage), then the next step is responding to the attack.

### Who’s misbehaving?

To answer the question of which peer is misbehaving and harming you, go-libp2p
exposes a [canonical log
lines](https://github.com/libp2p/go-libp2p/blob/v0.22.0/core/canonicallog/canonicallog.go#L18)
that identifies misbehaving peers. A canonical log line is simply a log line
with a special format. For example here’s a peer status log line that tells us a
peer established a connection with us, and that this log line was randomly
sampled (1 out of 100).

```
Jul 27 12:14:14 ipfsNode ipfs[46133]: 2022-07-27T12:14:14.674Z        INFO        canonical-log        swarm/swarm_listen.go:128        CANONICAL_PEER_STATUS: peer=12D3KooWSbNLGMYeUuMSXDiHwbhXHzTJaWZzH95MZzeAob9BeB51 addr=/ip4/147.75.74.239/udp/4001/quic sample_rate=100 connection_status="established" dir="inbound"
```

To see these kinds of logs make sure you’ve enabled the `"canonical-log=info"`
log level. You can do this in code like
[so](https://github.com/libp2p/go-libp2p/blob/v0.22.0/core/canonicallog/canonicallog_test.go#L15),
or by setting the environment variable `GOLOG_LOG_LEVEL="canonical-log=info"`.

In rust-libp2p you can do something similar yourself by logging a sample of
connection events from [SwarmEvent](https://docs.rs/libp2p/latest/libp2p/swarm/enum.SwarmEvent.html).

### How to block a misbehaving peer

Once you’ve identified the misbehaving peer, you can block them with `iptables`
or `ufw`. Here we’ll outline how to block the peer with `ufw`. You can get the
ip address of the peer from the
[multiaddr](https://github.com/multiformats/multiaddr) in the log.

```bash
sudo ufw deny from 1.2.3.4
```

### How to automate blocking with fail2ban

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
filter   = go-libp2p-peer-status # This is the filename of the filter above.
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

#### Example screen recording of fail2ban in action

<!-- {{ <video library="1" src="fail2bango-libp2p.mp4"> }} -->

[fail2ban+go-libp2p screen recording](/images/fail2bango-libp2p.mp4)

#### Setting Up fail2ban

We’ll focus on the specifics around fail2ban and go-libp2p here.  The steps to
take are:

1. Install fail2ban.  For a general guide to setting up fail2ban, consult this useful tutorial: [https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-20-04](https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-20-04).
2. Copy the above files into their respective places.
    1. The filter definition into `/etc/fail2ban/filter.d/go-libp2p-peer-status.conf`
    2. The rule into `/etc/fail2ban/jail.d/go-libp2p-weird-behavior-iptables.conf`.
3. Remember you may need to tweak the rule to read from the correct log location or change the systemd service name.
4. Remember you need to enable the canonical log level (see the above section for how to enable this log level).
5. Restart fail2ban to reload the configuration with `systemctl restart fail2ban`.
6. Verify our jail is active by running `fail2ban-client status go-libp2p-weird-behavior-iptables`. If you see something like:

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

### Leverage Resource Manager and a set of trusted peers to form an allow list (go-libp2p only)

The [resource manager](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/resource-manager) can
accept a list of trusted multiaddrs and can use a different set of limits in
case the normal system limits are reached. This is useful if you're currently
experiencing an attack since you can set low limits for general use, and
higher limits for trusted peers. See the [allowlist
section](https://github.com/libp2p/go-libp2p/tree/master/p2p/host/resource-manager#allowlisting-multiaddrs-to-mitigate-eclipse-attacks)
for more details.

## Summary

Mitigating DOS attacks is hard because an attacker needs only one flaw, while a
protocol developer needs to cover _all_ their bases. Libp2p provides some tools
to design better protocols, but developers should still monitor their
applications to protect against novel attacks. Finally, developers should
leverage existing tools like `fail2ban` to automate blocking misbehaving nodes
by logging when peers behave maliciously.
