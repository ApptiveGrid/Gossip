Class {
	#name : #GossipAckMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'digests',
		'delta'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipAckMessage >> delta [

	^ delta
]

{ #category : #accessing }
GossipAckMessage >> delta: anObject [

	delta := anObject
]

{ #category : #accessing }
GossipAckMessage >> digests [
	^ digests
]

{ #category : #accessing }
GossipAckMessage >> digests: aCollection [ 
	digests := aCollection 
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> endpointRestartFor: digest [ 
	digests add: digest fromStart.
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> endpointUnknownFor: digest [ 
	digests add: digest fromStart 
]

{ #category : #initialization }
GossipAckMessage >> initialize [ 
	super initialize.
	digests := OrderedCollection new.
	delta := Dictionary new
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> processIn: aGossiper [
	| ack2 |
	ack2 := aGossiper newMessage: GossipAck2Message.
	aGossiper endpoints processAckMessage: self for: ack2. 
	aGossiper sendMessage: ack2 to: sender 
	
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> requestUpdatesFrom: digest since: anInteger [ 
	digests add: (digest startingFrom: anInteger).
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> updateEndpoint: digest with: stateDelta [ 
	delta at: digest endpoint put: stateDelta 
]
