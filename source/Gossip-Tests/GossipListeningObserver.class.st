"
An observer that keeps where each datagram came from, so a test can see which socket of the other side answered.
"
Class {
	#name : 'GossipListeningObserver',
	#superclass : 'GossipObserver',
	#instVars : [
		'sources'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'gossiping' }
GossipListeningObserver >> received: aString from: anEndpoint [

	self sources add: anEndpoint.
	super received: aString from: anEndpoint
]

{ #category : 'accessing' }
GossipListeningObserver >> sources [

	^ sources ifNil: [ sources := OrderedCollection new ]
]
