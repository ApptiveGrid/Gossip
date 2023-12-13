Class {
	#name : #GossipSynMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'digests'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipSynMessage >> digests [

	^ digests
]

{ #category : #accessing }
GossipSynMessage >> digests: anObject [

	digests := anObject
]

{ #category : #'as yet unclassified' }
GossipSynMessage >> processIn: gossiper for: anEndpoint [ 
	| states localEndpoints needed ack myStates |
	localEndpoints := gossiper endpoints keys asOrderedCollection.
	needed := OrderedCollection new.
	myStates := Dictionary new.
	digests do: [ :digest | 
		(gossiper endpoints includesKey: digest endpoint)
			ifTrue: [  
				localEndpoints remove: digest endpoint ifAbsent: [  ].
				states := gossiper endpoints stateAt: digest endpoint.
				(states maxVersion = digest maxVersion) ifFalse: [ 
					(states maxVersion > digest maxVersion) 
						ifTrue: [ myStates at: digest endpoint put: states ]
						ifFalse: [ needed add: digest ] ] ]
			ifFalse: [ needed add: digest ] ].
	localEndpoints do: [ :endpoint |
		myStates at: endpoint put: (gossiper endpoints stateAt: endpoint) ].
	ack := GossipAckMessage new 
		sender: gossiper endpoint;
		digests: needed;
		delta: myStates.
	gossiper sendMessage: ack to: sender
   
]
