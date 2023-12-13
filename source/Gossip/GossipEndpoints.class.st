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

{ #category : #accessing }
GossipEndpoints >> endpointAt: key [
	^  endpointStates 
		at: key 
		ifAbsentPut: [ GossipEndpointState new ]
]

{ #category : #initialization }
GossipEndpoints >> initialize [ 
	super initialize.
	endpointStates := Dictionary new
]

{ #category : #accessing }
GossipEndpoints >> myEndpoint [
	^ self endpointAt: GossipEndpoint me
]

{ #category : #accessing }
GossipEndpoints >> stateAt: aString [ 
	^ (self myEndpoint stateAt: aString) value
]

{ #category : #accessing }
GossipEndpoints >> stateAt: key put: value [
	| valueHolder |
	valueHolder := self myEndpoint 
		stateAt: key
		ifAbsentPut: [ GossipVersionedValue new ].
	valueHolder setValue: value
	
]
