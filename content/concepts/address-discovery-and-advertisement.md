---
title: Address Discovery and Advertisement
weight: 2
---

This post explains how a `go-libp2p` node discovers its dialable addresses and advertises them to other peers. While it might seem trivial at first glance, there’s a lot going on behind the scenes. Let’s dive in.

### Address Discovery

The following address sets make up a libp2p node’s complete **set of dialable addresses**:

- The network interface addresses a node explicitly listens on/binds to.

- The node’s publicly visible addresses(“observed addresses”) it learns from other peers using the [Identify][spec_identify]
  protocol. This is especially relevant if the node is behind a NAT.

- Relay addresses a node discovers after connecting to public Relay servers if it determines it’s not publicly dialable.

- Addresses assigned by the nodes local hardware router via a port mapping protocol such as UPnP.

{{% notice "note" %}}
A node can use one, some, or all of the above address sets to build up the complete set of its dialable
addresses depending on various factors such as the interfaces it’s listening on, if it uses a port mapping protocol
or not, its NAT reachability, if it has been configured to use Relays, etc.
{{% /notice %}}

Let’s dig deeper into how each of those address sets are built.

#### Network Interface Addresses

- These are the network interface addresses a libp2p node explicitly binds to by either passing in the
`libp2p.ListenAddrs(addrs..)` option when constructing a `Host` or by calling the `h.Network().Listen(addrs..)` API.

Instead of strict addresses, users can pass in ephemeral IPv4 (`/ip4/0.0.0.0/tcp/0`) and/or IPv6 (`/ip6/::/tcp/0`) addresses to listen on all available network interfaces.
Thus, we need to resolve the unspecified addresses.
Earlier, we used to resolve the unspecified addresses by using all available network interfaces but this quickly
led to address explosion and a lot of the interfaces were un-usable anyways
(link local interfaces, docker interfaces etc.).

- So, we now resolve unspecified addresses using ONLY the primary network interface addresses
(which we discover using the [netroute][net_route] library) and the loopback interface addresses for both IPv4 and v6.
The primary network interface is basically the interface that would be used to send a packet to the public network
i.e. to an IP address not on the same network as us.
It is usually the “default” entry in the kernel’s Routing table.

#### Observed Addresses

- If the peer is behind a NAT, the NAT device would assign a NATT’d address to any outgoing packets sent by the peer.
In this case, the peer’s address that would be observed by the outside world would be different from the address
the peer is listening on.

- For NAT traversal and hole punching, it is important for a peer to know it’s observed address in such cases so that
it can share them with other peers if it’s fairly confident(we’ll get to how this confidence is built in a moment)
that it’s dialable on those addresses.

- To facilitate this, we take help from the [Identify][spec_identify] protocol. For the purposes of
  our discussion, the relevant part is that when two peers connect, they exchange an
  `Identify` message with each other to inform the other peer of it’s dialable addresses, keys,
  supported protocols etc. One of the fields they put in there is called `observedAddr`
  which is populated with the other peer’s address they observe on the connection which enables the other peer to
  learn it’s observed addresses.

- However, we can’t share all such observed addresses with the world as that could lead to us sharing a whole bunch
  of undialable addresses. For example, we could simply be using ephemeral ports for some outbound connections
  thus causing them to be assigned different NAT mappings than the mapping for the address we are listening on,
  some of them could be loopback addresses etc.

- As mentioned above, before we share such observed addresses with
  the world, we need a fair degree of confidence that they are indeed dialable and reachable from outside.
  We need to do some analytics here and this is where the `ObservedAddrManager` component comes in.

#### The Observed Address Manager

- The purpose of the Observed Address Manager is to help us determine which observed address should be shared
with the world.

- Every observed address we get using the Identify protocol is recorded in the Observed Address Manager.

- When the Host wants to build it’s address set, one of the steps it takes is to ask the Observed Address Manager
  for the addresses it thinks should be shared.

- Here are the rules used by the Manager to determine which addresses will be shared:
    - The observed address should NOT be a loopback address.

    - The local address we see on the connection that led to this observation should be one of the network interface
      addresses we are listening on. This ensures we don’t share observations that were created by the use of
      ephemeral ports for outbound connections.
      We want to ensure the NAT port mapping for the observed address is the same as that for one of our interface
      listen addresses.

    - The same address should have been observed by 4 different peers (different here means different IP addresses)
      within the past 40 minutes.

    - The address has been seen at least once in the last 10 minutes(offers some protection against changes in our
      own network conditions).

    - On top of all the above, the observed address manager selects ONLY the “top” two observed addresses for
      each group of (IP address + Transport protocol). For ranking, we prefer observations created because of
      inbound connections over outbound ones(obviously), using the number of peers who reported that same
      observed address to resolve ties.

#### Relay Addresses: Using AutoRelay, AutoNAT and Relay Servers

- We use [circuit relays][spec_relay] to enable other peers to connect to us when we discover we are completely
  NATT’d and are not dialable at all. The basic idea is that we connect to a publicly reachable “relay” server and
  then create a “relay address” which we can advertise.
  A relay address is usually a combination of the Relay server’s address combined with it’s peer id.
  Any peer that then wants to talk to us can do so via the relay server.

- There are three parts to this:
    - Discovering we are completely NATT’d and thus NOT dialable at all using `AutoNAT`.

    - Discovering Relay Servers we can connect to and building relay addresses by using `AutoRelay`.

    - Creating long lived connections with the Relay server and advertising relay addresses in `AutoRelay`.

    #### AutoNAT: Discovering we are NOT dialable/NATT’d
    - To discover that we are NOT dialable, we use a component called [AutoNAT][autonat_repo].
    - The basic idea is this:
        - An AutoNAT client send it’s list of dialable addresses to an AutoNAT server and asks the AutoNAT server to
      see if it can dial the client back on one of those addresses.

        - If the AutoNAT server is successful, it replies to the original request with a success message along with
      the address it was able to successfully dial on.

        - If the AutoNAT server fails to dial back the node, it sends back a failure message to the client.

        - A peer can become an AutoNAT server by providing services on the “"/libp2p/autonat/1.0.0" protocol.

        - Peers that want to discover their reachability are AutoNAT clients.
        They periodically pick a random AutoNAT server they are connected to, send the server it’s complete list of
        dialable addresses(by asking the Host) and ask for a dial back. The interface listen addresses, UPnP addresses
        AND observed addresses selected by the Observed Address Manager discussed above contribute to this list of
        dialable addresses.

        - Once an AutoNAT client has enough votes on whether it is publicly dialable(Public Reachability) or
        NOT(private Reachability), it emits an `EvtLocalReachabilityChanged` event with the reachability information.

        - Note that the Reachability status can always flip from Private to Public and vice versa as the peer discovers
          new dialable addresses and gets periodic dial back responses from AutoNAT servers.




    #### Discovering Relay Servers

    - A peer can be a Relay server if the `libp2p.EnableRelay` option is set on it with the `circuit.OptHop`
  option and the `libp2p.EnableAutoRelay` is also set on it.

    - When a Relay server is created, it starts advertising itself as the provider of the Relay `/libp2p/relay`
  namespace on the DHT.

    - Any peer that wants to connect to a Relay server can then look for them by searching for providers of the
  `/libp2p/relay` namespace on the DHT and then randomly picking one Relay server that’s dialable.

    #### Creating long lived connections with the Relay server and advertising relay addresses

    - Once a peer knows it has private reachability by using AutoNAT, the only way it can be dialled from
    outside is through Relay servers.

    - So, when a peer receivers an `EvtLocalReachabilityChanged` event with Private reachability, it searches the
    DHT for Relay servers as described above and connects to one of them.

    - It then creates a Relay address for itself by combining the address of the Relay server with it’s peerID and
    adds it to the dialable address set of the peer. In this case, the peer also removes all public addresses from
    it’s set of dialable addresses as it overwrites them with the Relay addresses since it does NOT have public
    reachability. This means it will remove public interface addresses, UPnP addresses and even public observed
    addresses it is confident about from it’s set of dialable addresses. However it will retain all
    private IP addresses it discovers using all these mechanisms so peers on the same network can dial it
    without using Relays.

    - Note that the connection with the Relay server should be a long lived one as peers can ONLY connect to it
    using the relay address if it is connected to the Relay server.

    - If a peer discovers it has public reachability by seeing an “EvtLocalReachabilityChanged” event for it,
    it stops advertising Relay addresses.

    - When a peer with private reachability loses connection to it’s Relay server, it will remove the corresponding
    relay addresses from it’s address set and look for a new Relay server to connect to.

    - When a peer connects to a new Relay server, it adds the corresponding Relay address to it’s set
    of dialable addresses.

    - The component that listens to NAT reachability events, connects to Relay servers and builds/advertises
    Relay addresses is called `AutoRelay`. It can be enabled by using the `libp2p.EnableRelay(nil)` and `libp2p.EnableAutoRelay()` option on the Host.

{{% notice "note" %}}
We can also configure AutoRelay to use static relay servers rather than discovering them via DHT by
using the `libp2p.StaticRelays(relayServerAddrs...)` option on the Host.
{{% /notice %}}

### Advertising Dialable Addresses

The first section covered how a libp2p nodes “discovers” it’s dialable addresses.
All the methods and address sets discussed above go into making the final set of a node’s dialable addresses.
The way a libp2p peer shares these dialable addresses with other peers is:

- When a peer connects to other peers, it asks it’s `Host` for it’s current set of dialable addresses.

- This will include some or all of the address sets discussed above (Interface, Relay etc. etc.).

- Put those addresses in the `listenAddrs` field of the `Identify` message and send the `Identify` message to
  the other peer.

- When a peer receives another peer’s dialable addresses from the ` `listenAddrs` field of the Identify message,
  it stores them in it’s peerstore for some time. The timing does NOT matter to this discussion.

- Any peer can then lookup a peer’s addresses by asking the DHT network to find the peer with that peerID by
  using the `FindPeer` DHT API. The DHT nodes will use the addresses stored in their peerstore as described above
  to find and return the addresses of the peer. Looking up peer addresses in this manner by using the DHT is called
  Peer Routing.

    #### Handling changes to the peer’s dialable addresses

    All well and good so far. But the set of a peer’s dialable addresses is ofcourse not a static set. A peer can
    start listening on new interfaces, see more of it’s observed addresses, change it’s network, be assigned a new
    IP address by the Router etc. Hence, we also need a mechanism to detect changes to a peer’s dialable addresses set
    and advertise these changes to the world on the fly. The way we do this is by
    **running an event loop** in the `Host`.


    #### When does the Host event loop fire ?
    - Every 5 seconds.

    - When the user starts listening on a new interface address/es by calling `Host.Network.Listen(addrs...)`.

    - When `AutoRelay` detects a change in it’s reachability(private -> public or vice versa), creates a
    connection with a new relay server or loses connection with an existing relay server since all of these would
    cause a change in it’s relay addresses.

    #### What does the Host do when the event loop fires ?
    - Updates it’s primary network interface address by using the netroute library as discussed above
    (if it has changed). This takes care of network changes/routers assigning new addresses via DHCP.

    - Builds a new address set by using all the addresses discovered by the various mechanisms described in the
    `Address Discovery` section and compares it with the previous address set.

    - If the new address set is different from the previous address set, it fires an `EvtLocalAddressesUpdated` event.

    - The ID service listens for the `EvtLocalAddressesUpdated` event and pushes the new set of addresses to all
    peers it is connected to via the `Identify Push` protocol.
    The ID service is the same service that also handles the `Identify` protocol described above.


{{% notice "note" %}}
While the blog post mentions that a peer shares it’s dialable addresses with other peers in the
`Identify` and `Identify Push` messages, what it actually shares is a `Signed Peer Record`
containing all the addresses and signed with it’s private key.
That way, anyone who receives that address set can verify that it was announced by the intended peer.
You can read more about how this works at https://github.com/libp2p/specs/pull/217.
{{% /notice %}}

[net_route]: https://github.com/libp2p/go-netroute
[spec_identify]: https://github.com/libp2p/specs/tree/master/identify
[spec_relay]: https://github.com/libp2p/specs/blob/master/relay/README.md
[autonat_repo]: https://github.com/libp2p/go-libp2p-autonat
