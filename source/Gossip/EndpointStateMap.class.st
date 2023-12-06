Class {
	#name : #EndpointStateMap,
	#superclass : #Object,
	#instVars : [
		'states'
	],
	#category : #Gossip
}

{ #category : #initialization }
EndpointStateMap >> initialize [ 
	super initialize.
	states := Dictionary new
]

{ #category : #accessing }
EndpointStateMap >> stateAt: aString ifAbsentPut: aBlock [
	^ states 
		at: aString 
		ifAbsentPut: aBlock
]
