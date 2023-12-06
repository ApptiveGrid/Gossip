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
