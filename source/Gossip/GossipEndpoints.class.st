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
GossipEndpoints >> applyChanges: aCollection [ 
	aCollection ifNotEmpty: [ self halt. ]
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
		ifAbsentPut: [ 
			GossipEndpointState new
				endpoint: key ]
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
	valueHolder := self myEndpoint 
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
GossipEndpoints >> myEndpointState [
	^ self endpointStateAt: gossiper myEndpoint
]
