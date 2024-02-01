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

{ #category : #accessing }
GossipEndpoints >> at: endpoint overwrite: aGossipEndpointState [ 
	gossiper log: 'updating ', endpoint asString.
	aGossipEndpointState isEmpty ifFalse: [  
	endpointStates at: endpoint put: aGossipEndpointState ]
]

{ #category : #accessing }
GossipEndpoints >> digests [
	| digests |
	digests := OrderedCollection new.
	endpointStates keysAndValuesDo: [ :endpoint :states |
		digests add: (GossipDigest 
			endpoint: endpoint 
			generation: 1 
			version: states maxVersion ) ].
	^ digests
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
GossipEndpoints >> myEndpoint [
	^ self stateAt: gossiper myEndpoint
]

{ #category : #accessing }
GossipEndpoints >> stateAt: key [
	^  endpointStates 
		at: key 
		ifAbsentPut: [ GossipEndpointState new ]
]

{ #category : #accessing }
GossipEndpoints >> stateAt: key put: value [
	| valueHolder |
	valueHolder := self myEndpoint 
		stateAt: key
		ifAbsentPut: [ GossipApplicationState new ].
	valueHolder setValue: value endpointState: self
	
]
