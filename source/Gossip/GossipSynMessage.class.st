Class {
	#name : 'GossipSynMessage',
	#superclass : 'GossipMessage',
	#instVars : [
		'digests'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
GossipSynMessage >> digests [

	^ digests
]

{ #category : 'accessing' }
GossipSynMessage >> digests: anObject [

	digests := anObject
]

{ #category : 'as yet unclassified' }
GossipSynMessage >> processIn: gossiper [

	^ self processIn: gossiper from: nil
]

{ #category : 'as yet unclassified' }
GossipSynMessage >> processIn: gossiper from: anEndpoint [
	"A syn that names its sender is answered there, which is what a member does: its
	datagrams leave from a socket of their own, and behind a port mapping the address
	they arrive from is not one that can be answered at all.

	A syn that names nobody asks to be answered where it came from. That is how a
	GossipObserver asks, and the only way it can be answered from behind a NAT: the
	address it has is not one the cluster can reach, and the reply only finds its way
	back if it takes the way the question came - back to the source, and out of the
	socket the question went to, so that a translating gateway recognises it as the
	answer to what passed through it."

	| ack |
	ack := gossiper newMessage: GossipAckMessage.
	gossiper endpoints processSynMessage: self for: ack.
	sender
		ifNil: [ gossiper reply: ack to: anEndpoint ]
		ifNotNil: [ gossiper sendMessage: ack to: sender ]
]
