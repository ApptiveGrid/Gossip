Class {
	#name : #GossipAck2Message,
	#superclass : #GossipMessage,
	#instVars : [
		'delta'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipAck2Message >> delta [
	^ delta
]

{ #category : #accessing }
GossipAck2Message >> delta: anObject [

	delta := anObject
]

{ #category : #initialization }
GossipAck2Message >> initialize [ 
	super initialize.
	delta := Dictionary new
]

{ #category : #initialization }
GossipAck2Message >> initializeFromAckMessage: aGossipAckMessage andEndpoints: endpoints [ 
	endpoints applyChanges: aGossipAckMessage delta.
	aGossipAckMessage digests do: [ :digest | | endpointState |
		endpointState := endpoints 
				endpointStateAt: digest endpoint
				ifAbsentPut: [
					GossipEndpointState new
						endpoint: digest endpoint;
						generation: digest generation ].
		self 
			processDigest: digest 
			forEndpointState: endpointState ]
]

{ #category : #initialization }
GossipAck2Message >> processDigest: digest forEndpointState: endpointState [ 
	(digest generation = endpointState generation) ifFalse: [ 
			(digest generation > endpointState generation)
				ifTrue: [ self halt ]
				ifFalse: [ self halt ]
			].
		(digest version = endpointState maxVersion) ifFalse: [ 
			(digest version > endpointState maxVersion) 
				ifTrue: [ self halt]
				ifFalse: [ 
					delta 
						at: endpointState endpoint 
						put: (endpointState applicationStatesAfterVersion: digest version)  ] ] 
]

{ #category : #'as yet unclassified' }
GossipAck2Message >> processIn: aGossiper [
	delta keysAndValuesDo: [ :endpoint :s |
		aGossiper endpoints endpointStateAt: endpoint overwrite: s ]
]
