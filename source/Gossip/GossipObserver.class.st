"
A gossiper that reads the cluster without joining it.

It learns what every member knows - the endpoints, their application states, when each was last seen - and it is known by none of them. That is the whole point: a tool on a laptop that comes and goes sees the same replicated state as a member, and its coming and going is nothing the cluster has to notice, now or once failure detection arrives.

It gets there by never having an entry of its own. A member learns another only from the state that one publishes about itself, and that state comes into being in Gossiper>>localEndpointState, which only #gossip touches. The syn sent here carries the digests of what is known and nothing about the sender; the node answers to the address the syn names and keeps nothing of it. An empty digest brings the whole table in the ack, a current one brings what moved.

One node per round rather than three. There is no fan-out to keep up, and the question is not whether the cluster hears from this one but whether this one hears from the cluster. It stays with a node that answers and moves on to another the first round that brings no answer - which, over UDP, may also be a lost datagram; moving on is cheap, and the next node knows the same.

What it does not avoid: when it moves to a node that is behind it, that node asks in its ack for what it lacks, and the ack2 sent back carries it. That is state of others, replicated anyway, relayed once more - it does not make this one a member.
"
Class {
	#name : 'GossipObserver',
	#superclass : 'Gossiper',
	#instVars : [
		'node',
		'answered'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'gossiping' }
GossipObserver >> candidateNodes [
	"Whom it could ask: everything learned and the seeds as the way in, never
	itself. The same set a member draws from."

	| candidates |
	candidates := Set new.
	candidates
		addAll: self endpoints keys;
		addAll: (self seedNodes ifNil: [ #(  ) ]);
		remove: self localEndpoint ifAbsent: [  ].
	^ candidates
]

{ #category : 'gossiping' }
GossipObserver >> gossip [
	"A syn to one node, with the digests of what is known here and no word about
	this one. Unlike Gossiper>>gossip there is no heartbeat to raise and no entry
	to touch - touching it is what would make this a member."

	(node isNil or: [ answered not ]) ifTrue: [ node := self nextNode ].
	node ifNil: [ ^ self ].
	answered := false.
	self
		sendMessage: (GossipSynMessage new
				 sender: self localEndpoint;
				 digests: self endpoints digests;
				 yourself)
		to: node
]

{ #category : 'initialization' }
GossipObserver >> initialize [

	super initialize.
	answered := false
]

{ #category : 'accessing' }
GossipObserver >> localEndpointState [
	"There is none, and asking for one is a mistake: the state would be created,
	travel with the next ack2 and make this observer a member after all."

	^ self error: 'an observer has no state of its own'
]

{ #category : 'gossiping' }
GossipObserver >> nextNode [
	"Another node than the one that did not answer, if there is another. With only
	one to ask, that one is asked again - silence from the only way in is no reason
	to stop trying it."

	| others |
	"node asks, not the candidates: before the first round it is nil, and
	GossipEndpoint>>= sends #address to whatever it is compared with."
	others := self candidateNodes reject: [ :each | node = each ].
	others isEmpty ifTrue: [ ^ node ].
	^ others atRandom
]

{ #category : 'accessing' }
GossipObserver >> node [
	"The node it currently reads from, nil before the first round."

	^ node
]

{ #category : 'gossiping' }
GossipObserver >> receivedMessage: aMessage from: anEndpoint [
	"Anything arriving is an answer. Nobody else knows this address, and the
	endpoint a datagram comes from need not be the one it was sent to - behind a
	port mapping it is not - so the sender is not compared."

	answered := true.
	super receivedMessage: aMessage from: anEndpoint
]
