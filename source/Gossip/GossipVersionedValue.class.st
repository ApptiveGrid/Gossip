Class {
	#name : #GossipVersionedValue,
	#superclass : #Object,
	#instVars : [
		'version',
		'value'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipVersionedValue >> maxVersion [

	^ version
]

{ #category : #accessing }
GossipVersionedValue >> maxVersion: anObject [

	version := anObject
]

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
