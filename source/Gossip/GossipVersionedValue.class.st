Class {
	#name : #GossipVersionedValue,
	#superclass : #Object,
	#instVars : [
		'version',
		'value'
	],
	#category : #Gossip
}

{ #category : #printing }
GossipVersionedValue >> printOn: aStream [ 
	aStream << '[' << value printString << ':'  << version printString << ']' 
]

{ #category : #initialization }
GossipVersionedValue >> setValue: anObject [
	version ifNil: [ version := 0 ].
	version := version + 1.
	value := anObject
]

{ #category : #accessing }
GossipVersionedValue >> value [

	^ value
]

{ #category : #accessing }
GossipVersionedValue >> value: anObject [

	value := anObject
]

{ #category : #accessing }
GossipVersionedValue >> version [

	^ version
]

{ #category : #accessing }
GossipVersionedValue >> version: anObject [

	version := anObject
]