Class {
	#name : #GossipEndpoints,
	#superclass : #Object,
	#instVars : [
		'gossiper',
		'endpointStates'
	],
	#classInstVars : [
		'instance'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipEndpoints class >> instance [ 
	^ instance ifNil: [ 
		instance := self new ]
]

{ #category : #'as yet unclassified' }
GossipEndpoints >> applyChanges: aDictionary [  
	| localEndpointState |
	aDictionary keysAndValuesDo: [ :endpoint :endpointState |
		localEndpointState := endpointStates 
			at: endpoint
			ifAbsentPut: [
				GossipEndpointState new
					endpoint: endpoint ].
		endpointState applyChangesTo: localEndpointState  ]
]

{ #category : #accessing }
GossipEndpoints >> digests [
	| digests |
	digests := OrderedCollection new.
	endpointStates keysAndValuesDo: [ :endpoint :states |
		digests add: (GossipDigest 
			endpoint: endpoint 
			generation: gossiper generation 
			version: states maxVersion ) ].
	^ digests
]

{ #category : #accessing }
GossipEndpoints >> endpointStateAt: key [
	^  endpointStates 
		at: key 
		ifAbsent: [ KeyNotFound signal: 'no endpoint state for ', key printString ]
]

{ #category : #accessing }
GossipEndpoints >> endpointStateAt: key ifAbsent: aBlock [
	^  endpointStates 
		at: key 
		ifAbsent: aBlock
]

{ #category : #accessing }
GossipEndpoints >> endpointStateAt: key ifAbsentPut: aBlock [
	^  endpointStates 
		at: key 
		ifAbsentPut: aBlock
]

{ #category : #accessing }
GossipEndpoints >> endpointStateAt: endpoint overwrite: aGossipEndpointState [ 
	gossiper log: 'updating ', endpoint asString.
	aGossipEndpointState isEmpty ifFalse: [  
	endpointStates at: endpoint put: aGossipEndpointState ]
]

{ #category : #accessing }
GossipEndpoints >> endpointStateAt: key put: value [
	| valueHolder |
	valueHolder := self localEndpoint 
		stateAt: key
		ifAbsentPut: [ GossipApplicationState new ].
	valueHolder setValue: value endpointState: self
	
]

{ #category : #accessing }
GossipEndpoints >> gossiper: aGossiper [ 
	gossiper := aGossiper
]

{ #category : #testing }
GossipEndpoints >> includesKey: aGossipEndpoint [ 
	^ endpointStates includesKey: aGossipEndpoint 
]

{ #category : #initialization }
GossipEndpoints >> initialize [ 
	super initialize.
	endpointStates := Dictionary new
]

{ #category : #testing }
GossipEndpoints >> isEmpty [ 
	^ endpointStates isEmpty
]

{ #category : #accessing }
GossipEndpoints >> keys [
	^ endpointStates keys
]

{ #category : #enumerating }
GossipEndpoints >> keysAndValuesDo: aBlock [
	endpointStates keysAndValuesDo: aBlock
]

{ #category : #accessing }
GossipEndpoints >> localEndpointState [
	^ self endpointStateAt: gossiper localEndpoint
]

{ #category : #'instance creation' }
GossipEndpoints >> newEndpointStateFor: endpoint [ 
	^ endpointStates 
		at: endpoint 
		put: (GossipEndpointState new endpoint: endpoint)
]

{ #category : #'as yet unclassified' }
GossipEndpoints >> processAck2Message: ack2Message [
	self applyChanges: ack2Message delta.

]

{ #category : #'as yet unclassified' }
GossipEndpoints >> processAckMessage: ackMessage for: ack2Message [ 
	self applyChanges: ackMessage delta.
	self processDigests: ackMessage digests forMessage: ack2Message
]

{ #category : #'as yet unclassified' }
GossipEndpoints >> processDigest: digest forMessage: message [  
	| endpointState |
	endpointState := self 
		endpointStateAt: digest endpoint 
		ifAbsent: [ ^ message endpointUnknownFor: digest ].
	endpointState  
		processDigest: digest 
		forMessage: message
	
]

{ #category : #'as yet unclassified' }
GossipEndpoints >> processDigests: synDigests forMessage: ack2Message [ 
	synDigests do: [ :digest |
		self processDigest: digest forMessage: ack2Message ].  
]
