---
title: "Publish/Subscribe"
weight: 8
pre: '<i class="fas fa-fw fa-book"></i> <b> </b>'
chapter: true
---

# Message Data

Publish/Subscribe is a system where peers congregate around topics they are
interested in. Peers interested in a topic are said to be subscribed to that
topic:

![Diagram showing a shaded area with curved outline representing a topic.
Scattered within the shaded area are twelve dots representing peers. A label
points to the dots which reads “Peers subscribed to topic”.](subscribed_peers.png)

Peers can send messages to topics. Each message gets delivered to all peers
subscribed to the topic:

![Diagram with two panels showing progression from left to right. In the first
panel are scattered dots within a shaded area representing peers subscribed to a
topic. From one of the dots comes a speech bubble labeled with “Message”. In the
second panel all dots now have a copy of the speech bubble above them
representing that the message has been transmitted to all peers subscribed to
the topic.](message_delivered_to_all.png)

Example uses of pub/sub:

* **Chat rooms.** Each room is a pub/sub topic and clients post chat messages to
    which are received by all other clients in the room.
* **File sharing.** Each pub/sub topic represents a file that can be downloaded.
    Uploaders and downloaders advertise which pieces of the file they have in
    the pub/sub topic and coordinate downloads that will happen outside the
    pub/sub system.

## Design goals

In a peer-to-peer pub/sub system all peers participate in delivering messages
throughout the network. There are several different designs for peer-to-peer
pub/sub systems which offer different trade-offs. Desirable properties include:

* **Reliability:** All messages get delivered to all peers subscribed to the topic.
* **Speed:** Messages are delivered quickly.
* **Efficiency:** The network is not flooded with excess copies of messages.
* **Resilience:** Peers can join and leave the network without disrupting it.
  There is no central point of failure.
* **Scale:** Topics can have enormous numbers of subscribers and handle a large
    throughput of messages.
* **Simplicity:** The system is simple to understand and implement. Each peer
  only needs to remember a small amount of state.

libp2p currently uses a design called **gossipsub**. It is named after the fact
that peers gossip to each other about which messages they have seen and use this
information to maintain a message delivery network.

## Discovery

Before a peer can subscribe to a topic it must find other peers and establish
network connections with them. The pub/sub system doesn’t have any way to
discover peers by itself. Instead, it relies upon the application to find new
peers on its behalf, a process called **ambient peer discovery**.

Potential methods for discovering peers include:

* Distributed hash tables
* Local network broadcasts
* Exchanging peer lists with existing peers
* Centralized trackers or rendezvous points
* Lists of bootstrap peers

For example, in a BitTorrent application, most of the above methods would
already be used in the process of downloading files. By reusing peers found
while the BitTorrent application goes about its regular business, the
application could build up a robust pub/sub network too.

Discovered peers are asked if they support the pub/sub protocol, and if so, are
added to the pub/sub network.

## Types of peering

In gossipsub, peers connect to each other via either **full-message** peerings
or **metadata-only** peerings. The overall network structure is made up of these
two networks:

![Diagram showing a large shaded area with many interconnected dots inside
representing connected peers all subscribed to the same topic. Thick, dark lines
labelled “Full-message peering” connect all the dots in a loose mesh, forming
many triangles and polygons. Between these lines runs a dense mesh of thinner,
lighter lines labelled “Metadata-only peering”. These lines run from each dot to
almost every other dot around it, criss-crossing over each other
frequently.](types_of_peering.png)

### Full-message

Full-message peerings are used to transmit the full contents of messages
throughout the network. This network is sparsely-connected with each peer only
being connected to a few other peers. (In the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md)
this sparsely-connected network is called a *mesh* and peers within it are
called *mesh members*.)

Limiting the number of full-message peerings is useful because it keeps the
amount of network traffic under control; each peer only forwards messages to a
few other peers, rather than all of them. Each peer has a target number of peers
it wants to be connected to. In this example each peer would ideally like to be
connected to <span class="configurable">3</span> other peers, but would settle
for <span class="configurable">2</span>–<span class="configurable">4</span>
connections:

![Diagram showing a large shaded area with scattered dots inside connected by
thick, dark lines representing full-message peerings between peers. Most of the
dots have three dark lines running from them to other dots. One of the dots has
four lines running from it and is labelled as “Peer reached upper bound”. A
different dot has only two lines running from it and is labelled “Peer reached
lower bound”.  Beneath the diagram is a legend reading “Network peering degree = 3;
Upper bound = 4; Lower bound = 2“ accompanied with small symbols showing dots
with three, four and two lines running from them
respectively.](full_message_network.png)

<div class="notices note" ><p>Throughout this guide, numbers
<span class="configurable">highlighted in purple</span> can be configured
by the developer.</p></div>

The peering degree (also called the *network degree* or *D*) controls the
trade-off between speed, reliability, resilience and efficiency of the network.
A higher peering degree helps messages get delivered faster, with a better
chance of reaching all subscribers and with less chance of any peer disrupting
the network by leaving. However, a high peering degree also causes additional
redundant copies of each message to be sent throughout the network, increasing
the bandwidth required to participate in the network.

In libp2p’s default implementation the ideal network peering degree is
<span class="configurable">6</span> with anywhere from
<span class="configurable">4</span>–<span class="configurable">12</span>
being acceptable.

### Metadata-only

In addition to the sparsely-connected network of full-message peerings, there is
also a densely-connected network of metadata-only peerings. This network is made
up of all the network connections between peers that aren’t full-message
peerings.

The metadata-only network shares gossip about which messages are available and
performs functions to help maintain the network of full-message peerings.

![Diagram showing a large shaded area with scattered dots inside connected by
many thin, light lines representing metadata-only peerings between peers. The
lines between the dots are labelled “Each peering is a network connection
between two peers”.](metadata_only_network.png)

## Grafting and pruning

Peerings are **bidirectional**, meaning that for any two connected peers, both
peers consider their connection to be full-message or both peers consider their
connection to be metadata-only.

Either peer can change the connection type by notifying the other. **Grafting** is
the process of converting a metadata-only connection to full-message. **Pruning**
is the opposite process; converting a full-message peering to metadata-only:

![Diagram showing two side-by-side, two-step processes. In the first process is
a thin, light line connecting two dots representing two peers connected by a
metadata-only connection. From the left dot emanates a speech bubble reading
“I’m grafting our connection into a full-message peering” below the speech
bubble is an arrow showing the bubble travelling along the connection to the dot
on the right. In the following step, the line becomes thick, dark and is now
labelled “Full-message peering”. The second process is the reverse of the first
process; two dots are connected by a thick, dark line which becomes a thin,
light line labelled “Metadata-only peering”. The speech bubble reads “I’m
pruning our connection back to a metadata-only peering.”](graft_prune.png)

When a peer has too few full-message peerings it will randomly graft some of its
metadata-only peerings to become full-message peerings:

![Diagram with three panels showing a progression from top to bottom. In the
first panel is a dot with many lines radiating out from it representing a peer
with many connections. Two of the lines are dark representing full-message
connections. Next to this are a series of circles, the first two of which are
shaded dark, labelled “Start with 2 full-content peerings”. The first three
circles in the series are labelled “Too few”. The next nine circles are labelled
“Acceptable amount”. The circles after that are labelled “Too many”. The sixth
circle in the series is singled out with a label “Ideal”. In the second panel,
four of the previously light lines radiating out from the dot have been
highlighted green. A dice symbol is present indicating random selection of the
now highlighted lines. Four circles in the series are also highlighted green, up
to the circle labelled “Ideal”. The panel is titled “Select more peers to graft
to get to the ideal number”. In the final panel the highlighted green lines and
dots have become dark to indicate they have become full-content peerings. The
title reads “Grafting complete”.](maintain_graft.png)

Conversely, when a peer has too many full-message peerings it will randomly
prune some of them back to metadata-only:

![Diagram with three panels showing a progression from top to bottom, similar to
the previous diagram. In the first panel is a dot with many lines radiating out
from it representing a peer with many connections. Fourteen of the lines are
dark representing full-message connections. There are also a few light lines in
the mix representing metadata-only peerings. Next to this are a series of
circles, the first fourteen of which are shaded dark, labelled “Start with 14
full-content peerings”. The first three circles in the series are labelled “Too
few”. The next nine circles are labelled “Acceptable amount”. The circles after
that are labelled “Too many”. The sixth circle in the series is singled out with
a label “Ideal”. In the second panel, eight of the previously dark lines
radiating out from the dot have been highlighted pink. A dice symbol is present
indicating random selection of the now highlighted lines. Eight circles in the
series are also highlighted pink, from the end down to the circle labelled
“Ideal”. The panel is titled “Select peers to prune to get the ideal number”. In
the final panel the highlighted pink lines and dots have become light to
indicate they have become metadata-only peerings. The title reads “Pruning
complete”.](maintain_prune.png)

In libp2p’s implementation, each peer performs a series of checks every
<span class="configurable">1</span> second. These checks are called the
*heartbeat*. Grafting and pruning happens during this time.

## Subscribing and unsubscribing

Peers keep track of which topics their directly-connected peers are subscribed
to. Using this information each peer is able to build up a picture of the topics
around them and which peers are subscribed to each topic:

![Diagram showing a large dot in the center surrounded by smaller dots which are
connected by thin, light lines to the large dot. The large dot is identified as
“Viewing from this peer’s perspective” and the smaller dots are identified as
“Directly-connected peer”. Behind the dots are five differently-colored shaded
areas, some overlapping and some disjoint. Each area is labelled as a topic,
from “Topic 1” to “Topic 5”. The shaded areas fade out with distance from the
large, central dot indicating that the peer’s perspective has limited range.
One of the smaller dots that does not share a shaded area with the large dot is
labelled “Peers keep track of other’s subscriptions even if not subscribed to
the same topics as them”.](subscriptions_local_view.png)

Keeping track of subscriptions happens by sending **subscribe** and
**unsubscribe** messages. When a new connection is established between two peers
they start by sending each other the list of topics they are subscribed to:

![Diagram showing two dots connected by a thin, light line. Each dot has a
speech bubble emanating from it with an arrow showing it moving along the
connecting line towards the other dot. The left dot’s speech bubble says “I am
subscribed to: Topic 1, Topic 2, Topic 3”. The right dot’s speech bubble says “I
am subscribed to: Topic 1, Topic 5”.](subscription_list_first_connect.png)

Then over time, whenever a peer subscribes or unsubscribes from a topic, it will
send each of its peers a subscribe or unsubscribe message. These messages are
sent to all connected peers regardless of whether the receiving peer is
subscribed to the topic in question:

![Diagram showing two dots connected by a thin, light line. The left dot has a
speech bubble emanating from it with an arrow showing it moving along the
connecting line towards the right dot. The speech bubble says “I am
subscribed to: Topic 5. I am unsubscribed from: Topic 2, Topic 3.”](subscription_list_change.png)

Subscribe and unsubscribe messages go hand-in-hand with graft and prune
messages. When a peer subscribes to a topic it will pick some peers that will
become its full-message peers for that topic and send them graft messages at the
same time as their subscribe messages:

![Diagram with two panels showing a downward progression. The first panel shows
a central dot connected to two other dots, one to its left and one to its right
by thin, light lines. The right dot is inside a shaded area labelled “Topic 3”.
Two speech bubbles emanate from the central dot, one pointing left towards the
left dot and the other pointing right towards the right dot. The left speech
bubble says “I am subscribed to Topic 3”. The right speech bubble says “I am
subscribed to Topic 3. Also, I’m grafting our connection into a full-message
peering.” The next panel shows the same three dots, however the central dot is
now inside the shaded area labelled “Topic 3” and the line connecting the
central and right dots has become thick and dark indicating a full-message
peering.](subscribe_graft.png)

When a peer unsubscribes from a topic it will notify its full-message peers that
their connection has been pruned at the same time as sending their unsubscribe
messages:

![Diagram with two panels showing a downward progression. It’s similar to the
previous diagram but reversed order. The first panel shows a central dot
connected to two other dots, one to its left and one to its right. The line
connecting the central and left dots is thin and light while the line connecting
the central and right dots is thick and dark. The central and right dots are
inside a shaded area labelled “Topic 3”. Two speech bubbles emanate from the
central dot, one pointing left towards the left dot and the other pointing right
towards the right dot. The left speech bubble says “I am unsubscribed from Topic
3”. The right speech bubble says “I am unsubscribed from Topic 3. Also, I’m
pruning our connection back to a metadata-only peering.” The next panel shows
the same three dots, however the central dot is no longer inside the area
labelled “Topic 3” and the line connecting the central and right dots has become
thin and light like the left line to indicate a metadata-only
peering.](unsubscribe_prune.png)

## Sending messages

When a peer wants to publish a message it sends a copy to all full-message peers
it is connected to:

![Diagram with two panels showing progression from left to right. The first
panel is titled “Peer creates new message of its own”. A small, unlabelled
speech bubble emanates from a dot. The dot has four thick, dark lines radiating
outward from it. The second panel is titled “Message sent to all other
full-message peers”. It shows four copies of the speech bubble now moving away
from the dot along each of the four lines.](full_message_send.png)

Similarly, when a peer receives a new message from another peer, it stores the
message and forwards a copy to all other full-message peers it is connected to:

![Diagram with three panels showing progression from left to right. The first
panel is titled “Incoming message”. A small speech bubble travels along
a thick, dark line towards a dot indicating a peer. There are also three other
thick, dark lines radiating outward from the dot. The second panel is titled
“Peer stores a copy of the message”. It shows the same dot with lines radiating
outward. The speech bubble is now centred above the dot. The final panel is
titled “Message forwarded to all other full-message peers”. It shows three
copies of the speech bubble now moving away from the dot along the three lines
that the speech bubble has not appeared on yet.](full_message_forward.png)

In the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#controlling-the-flood),
peers are also known as *routers* because of this function they have in routing
messages through the network.

Peers remember a list of recently seen messages. This lets peers act upon a
message only the first time they see it and ignore retransmissions of already
seen messages.

Peers might also choose to validate the contents of each message received. What
counts as valid and invalid depends on the application. For example, a chat
application might enforce that all messages must be shorter than 100 characters.
If the application tells libp2p that a message is invalid then that message will
be dropped and not replicated further through the network.

## Gossip

Peers gossip about messages they have recently seen. Every
<span class="configurable">1</span> second each peer randomly selects
<span class="configurable">6</span> metadata-only peers and sends them a list of
recently seen messages.

![Diagram with three panels showing progression from left to right. The first
panel is titled “Every 1 second…”. It shows a dot with many thin, light lines
radiating outwards representing metadata-only connections. A stopwatch symbol is
present indicating passage of time. The second panel is titled “Select 6
metadata-only peerings at random”. Six of the lines radiating outwards have been
highlighted yellow and a dice symbol is present indicating random selection. The
final panel is titled “Send them a list of recently seen messages”. Each of the
now-highlighted lines has a speech bubble travelling along it moving outwards
from the central dot. The six speech bubbles are identical and read “I have
seen:” followed by three small speech bubble symbols inside the larger speech
bubble, in different shades of purple to indicate three different messages.
One of the small purple speech bubbles is labelled “Seen messages specify the
sender and sequence number, but not the full message contents”.](gossip_deliver.png)

Gossiping gives peers a chance to notice in case they missed a message on the
full-message network. If a peer notices it is repeatedly missing messages then
it can set up new full-message peerings with peers that do have the messages.

Here is an example of how a specific message can be requested across a
metadata-only peering:

![Diagram with six panels showing a downward progression. Each panel shows
two dots connected by a thin, light line representing two peers connected
by a metadata-only connection. Each of the dots also has several other lines
radiating outwards, some thin and light, some thick and dark. These lines
represent a mix of metadata-only and full-message peerings to other peers not
pictured. The first panel is titled “Peer receives a message from their
full-message peers”. On the left of the diagram there are three purple speech
bubbles travelling along three thick, dark lines towards the dot on the left.
The second panel is titled “Peer waits until heartbeat and selects random
metadata-only peers”. Above the left dot are stopwatch and dice symbols
representing the passage of time and random selection. Three of the lines
connected to the left dot that were previously thin and light have now been
highlighted yellow, including the line connecting the left and right dots. The
highlighted lines represent the connections that were randomly selected. The
third panel is titled “Newly received message is gossiped to metadata-only
peers”. This panel still shows the yellow highlighted connections. Emanating
from the left dot and travelling along the line connecting it to the right dot
is a speech bubble that reads “I have seen:” followed by a small purple speech
bubble to represent the message that the left dot just received. The fourth
panel is titled “Peer notices that it does not have the gossiped message and
requests it”. The previously highlighted lines have gone back to being thin and
light. The right dot has a speech bubble emanating from it, travelling to the
left peer that reads “Please send:” followed by the same small purple speech
bubble. The fifth panel is titled “Requested message is transferred”. There is
now a purple speech bubble travelling along the line connecting the two dots
from left to right. The final panel is titled “Newly received message is
broadcast to full-content peers”. There are now three copies of the purple
speech bubble travelling outwards from the right dot along the three thick, dark
lines connected to it.](request_gossiped_message.png)

In the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#control-messages),
gossip announcing recently seen messages are called *IHAVE* messages and
requests for specific messages are called *IWANT* messages.

## Fan-out

Peers are allowed to publish messages to topics they are not subscribed to.
There are some special rules about how to do this to help ensure these messages
are delivered reliably.

The first time a peer wants to publish a message to a topic it is not subscribed
to, it randomly picks <span class="configurable">6</span> peers
(<span class="configurable">3</span> shown below) that are
subscribed to that topic and remembers them as **fan-out** peers for that topic:

![Diagram with two panels showing progression from left to right. The first
panel is titled “Peer wants to publish a message to a topic it is not subscribed
to”. It shows a small cluster of dots within a shaded area representing peers
subscribed to a topic. The dots are connected by a mix of thin, light and thick,
dark lines representing metadata-only and full-message peerings. Outside the
shaded area is a single dot representing a peer not subscribed to the topic.
This dot is connected to several of the dots inside the shaded area by thin,
light lines. The second panel is titled “Randomly select 3 peers subscribed to
the topic and remember them as fan-out peers”. In this panel, three of the lines
connecting the outside dot to dots inside the shaded area have become blue and
now have arrowheads at the end pointing towards the peer inside the shaded area
they are connected to. These lines represent fan-out peerings. A dice symbol is
present indicating random selection of which metadata-only peerings became
fan-out peerings.](fanout_initial_pick.png)

Unlike the other types of peering, fan-out peerings are unidirectional; they
always point from the peer outside the topic to a peer subscribed to the topic.
Peers subscribed to the topic are not told that they have been selected
and still treat the connection as any other metadata-only peering.

Each time the sender wants to send a message, it sends the message to its
fan-out peers, who then distribute the message within the topic:

![Diagram with two panels showing progression from left to right. Each panel
shows the same cluster of peers subscribed to a topic with a single peer outside
as shown in the previous diagram. The first panel is titled “New message sent to
fan-out peers”. It shows three purple speech bubbles travelling along three blue
arrows from the single towards peers inside the shaded area. This represents
three application messages being sent along three fan-out connections to three
peers subscribed to the topic. The second panel is titled “Once inside the
topic, the message is forwarded to all other subscribers as usual”. The purple
speech bubbles have moved from outside the shaded area to inside out. Now there
is a copy of the speech bubble above every dot in the shaded
area.](fanout_message_send.png)

If the sender goes to send a message but notices some of their fan-out peers
went away since last time, they will randomly select additional fan-out peers
to top them back up to <span class="configurable">6</span>.

When a peer subscribes to a topic, if it already has some fan-out peers it will
prefer them to become the full-message peers:

![Diagram with two panels showing progression from left to right. Each panel
shows the same cluster of peers subscribed to a topic with a single peer outside
as shown in the previous diagrams. The first panel is titled “Peer has existing
fan-out peerings”. Of the lines that connect the dot outside the shaded area
with dots inside the shaded area, three of them are blue and have arrowheads
pointing towards dots inside the shaded area, while the rest are thin, light and
have no arrowheads. This represents the peer not subscribed to the topic having
three fan-out peerings with peers subscribed to the topic and the rest of its
peerings are metadata-only. The second panel is titled “Upon subscribing to the
topic, fan-out peerings preferentially become full-message peerings”. The single
peer that was previously outside the shaded area is now inside it, representing
that it is now subscribed to the topic. The three previously-blue arrows have
become thick, dark lines representing former fan-out peerings becoming
full-message peerings. The other lines from the dot are still thin and light as
before.](fanout_grafting_preference.png)

After <span class="configurable">2</span> minutes of not sending any messages to
a topic, all the fan-out peers for that topic are forgotten:

![Diagram with two panels showing progression from left to right. Each panel
shows the same cluster of peers subscribed to a topic with a single peer
outside, including three blue, arrowed fan-out peerings as shown in the previous
diagrams. The first panel is titled “After not publishing any message for 2
minutes…” There is a stopwatch above the single dot indicating the passage of
time. The second panel is titled “All fan-out peerings revert to metadata-only
peerings”. In this panel the three previously blue, arrowed lines connecting
the single dot to dots inside the shaded area have become thin and light,
representing the peer’s fan-out peerings becoming metadata-only peerings.](fanout_forget.png)

## Network packets

The packets that peers actually send each other over the network are a
combination of all the different message types seen in this guide (application
messages, have/want, subscribe/unsubscribe, graft/prune). This structure allows
several different requests to be batched up and sent in a single network packet.

Here is a graphical representation of the overall network packet structure:

![Diagram showing a large speech bubble titled “Network packet”. The bubble is
divided into four main sections titled “Application messages”, “I have seen
these messages”, “Please send me these messages”, “Subscription changes” and
“Grafting and pruning”. Inside the section titled “Application messages” is a
smaller, purple speech bubble labelled “Application message”. The purple speech
bubble contains several filled-in fields in the style of a paper form. The
sender field says “Peer A”. The sequence number field says 5. The recipients
(topic ID’s) field had three lines, which read “Topic 1”, “Topic 2”, and “Topic
3”. The message body field says “The heaviest domestic cat on record is 21.297
kilograms.” The final two fields are for the sender public key and sender
signature. Each of these contains a series of random-looking numbers between 0
and 255, representing a series of bytes. Below the purple speech bubble is
another also labelled “Application message”, however this bubble fades out and
no fields are visible, representing the presence of additional application
messages that have been elided for presentation in this diagram. In the section
titled “I have seen these messages” (subtitle: “IHAVE”), there is a table with
three columns. The columns are titled “Recipient (Topic ID)”, “Sender” and
“Sequence number”. There are three rows in the table, each row populated with a
topic name, sender and sequence number. The data is illustrative and the
particular values are not significant. In the section titled “Please send me
these messages” (subtitle: “IWANT”), there is a table similar to the previous
one but with only sender and sequence number columns; the recipient column is
not present. Again, there are three rows in the table, populated with
illustrative senders and sequence numbers. In the section titled “Subscription
changes” is a table with two columns. The first column is titled “For this
topic…” and the second column is titled “I want to…”, with the choice of
subscribe or unsubscribe. The table has three rows populated with data. Two
of the topics are being subscribed to and one is being unsubscribed from. In the
final section, which is titled “Grafting and pruning” is another table with two
columns, similar to the previous table. The first column is titled “For this
topic…”, however the second column is titled “You have been…” with the choice of
grafted or pruned. There are three rows in this table. Two of the topics
have been grafted and one has been pruned (no particular connection to the
previous table).](network_packet_structure.png)

See the [specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md#protobuf) for the exact [Protocol Buffers](https://developers.google.com/protocol-buffers)
schema used to encode network packets.

## State

Here is a summary of the state each peer must remember to participate in the
pub/sub network:

* **Subscriptions:** List of topics subscribed to.
* **Fan-out topics:** These are the topics messaged recently but not subscribed
    to. For each topic the time of the last sent message to that topic is
    remembered.
* **List of peers currently connected to:** For each peer connected to, the
    state includes all the topics they are subscribed to and whether the peering
    for each topic is full-content, metadata-only or fan-out.
* **Recently seen messages**: This is a cache of recently seen messages. It is
    used to detect and ignore retransmitted messages. For each message the state
    includes who sent it and the sequence number, which is enough to uniquely
    identify any message. For very recent messages, the full message contents
    is kept so that it can be sent to any peers that request the message.

![Diagram titled “Peer state”. There are four sections titled “Topics I
subscribe to”, “Topics I recently sent a message to”, “Peers currently connected
to” and “Recently seen messages”. In the section titled “Topics I subscribe to”
is a list of three arbitrary topic names, “Topic 1”, “Topic 4” and “Topic 5”. In
the section titled “Topics I recently sent a message to” (subtitle: “but don’t
subscribe to”), is a table listing topic IDs and the time of last sent message
for each topic ID. There are two topics listed, Topic 6 and Topic 7, with last
messages sent 10 seconds ago and 35 seconds ago respectively. The section
titled “Peers currently connected to” contains a large table. The columns
are titled “Peer ID”, “Topics they subscribe to”, and “Type of peering“
which has the choice of full-message, metadata-only or fan-out. The table is
populated with six different peers, some of which are subscribed to several
topics, so have multiple rows in the “Topics they subscribe to” and “Type of
peering” columns. For each topic that each peer subscribes to one of the
boxes is ticked for full-message, metadata-only or fan-out. The topics for
which full-message is ticked are all topics listed above in the “Topics I
subscribe to” section. Likewise, for the topics which fan-out is ticked, the
topics all appear above in the “Topics I recently sent a message to”
section. In the final section, which is titled “Recently seen messages”, is
another large table. The columns are “Sender (Peer ID)”, “Sequence number”,
“Time first seen” and “Full message”. The first four table rows are
bracketed with a label “Last few seconds”. Rows within this bracket all have
the full message column populated with a purple speech bubble representing
that the full message contents are remembered as part of the state for
messages seen in the last few seconds. All eight of the table rows are
bracketed with the label “Last 2 minutes”, however for the last four rows
the full message column is empty. These rows only have the sender (Peer ID),
sequence number and time first seen columns populated. The table rows are
listed in order of time first seen, from 1 second ago in the top row to 90
seconds ago in the bottom row. Some of the sequence numbers are shared between
messages, but only where the sender is different.](state.png)

## More information

For more detail and a discussion of other pub/sub designs that influenced the
design of gossipsub, see the [gossipsub specification](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/README.md).

For implementation details, see the [gossipsub.go](https://github.com/libp2p/go-libp2p-pubsub/blob/master/gossipsub.go)
file in the source code of [go-libp2p-pubsub](https://github.com/libp2p/go-libp2p-pubsub),
which is the canonical implementation of gossipsub in libp2p.
