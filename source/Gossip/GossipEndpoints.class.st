Class {
	#name : #GossipEndpoints,
	#superclass : #Object,
	#instVars : [
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

{ #category : #testing }
GossipEndpoints >> includesKey: aGossipEndpoint [ 
	^ endpointStates includesKey: aGossipEndpoint 
]

{ #category : #initialization }
GossipEndpoints >> initialize [ 
	super initialize.
	endpointStates := Dictionary new
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
	^ self stateAt: GossipEndpoint me
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
		ifAbsentPut: [ GossipVersionedValue new ].
	valueHolder setValue: value
	
]
