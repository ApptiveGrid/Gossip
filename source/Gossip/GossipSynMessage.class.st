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
	| states localEndpoints needed ack |
	localEndpoints := gossiper endpoints keys.
	needed := OrderedCollection new.
	digests do: [ :digest | 
		(gossiper endpoints includesKey: digest endpoint)
			ifTrue: [  
				localEndpoints remove: digest endpoint ifAbsent: [  ].
				states := gossiper endpoints stateAt: digest endpoint.
				(states maxVersion = digest maxVersion) ifFalse: [ 
					(states maxVersion > digest maxVersion) 
						ifTrue: [ self halt ]
						ifFalse: [ self halt ] ] ]
			ifFalse: [ needed add: digest ] ].
	ack := GossipAckMessage new 
		digests: needed.
	gossiper sendMessage: ack to: anEndpoint 
   
]
