Class {
	#name : #GossipEndpointState,
	#superclass : #Object,
	#instVars : [
		'states'
	],
	#category : #Gossip
}

{ #category : #initialization }
GossipEndpointState >> initialize [ 
	super initialize.
	states := Dictionary new
]

{ #category : #accessing }
GossipEndpointState >> maxVersion [
	^ states 
		ifNotEmpty: [ states values max: [ :each | each maxVersion ] ]
		ifEmpty: [ 0 ]
]

{ #category : #accessing }
GossipEndpointState >> stateAt: aString [ 
	^ states 
		at: aString 
		ifAbsent: [ KeyNotFound signal: 'state ', aString printString, ' not found' ]
]

{ #category : #accessing }
GossipEndpointState >> stateAt: aString ifAbsentPut: aBlock [
	^ states 
		at: aString 
		ifAbsentPut: aBlock
]

{ #category : #accessing }
GossipEndpointState >> stateAt: aString put: anObject [	
	| valueHolder |
	valueHolder  := states 
		at: aString 
		ifAbsentPut: [ GossipVersionedValue new ].
	valueHolder setValue: anObject
]
