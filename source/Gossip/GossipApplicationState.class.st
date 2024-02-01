Class {
	#name : #GossipApplicationState,
	#superclass : #Object,
	#instVars : [
		'version',
		'value'
	],
	#category : #Gossip
}

{ #category : #initialization }
GossipApplicationState >> initializeVersionFrom: aGossipEndpointState [ 
	self shouldBeImplemented.
]

{ #category : #accessing }
GossipApplicationState >> maxVersion [

	^ version
]

{ #category : #accessing }
GossipApplicationState >> maxVersion: anObject [

	version := anObject
]

{ #category : #printing }
GossipApplicationState >> printOn: aStream [ 
	aStream << '[' << value printString << ':'  << version printString << ']' 
]

{ #category : #initialization }
GossipApplicationState >> setValue: anObject [
	version ifNil: [ version := 0 ].
	version := version + 1.
	value := anObject
]

{ #category : #initialization }
GossipApplicationState >> setValue: anObject endpointState: endpointState [
	value := anObject.
	version := endpointState nextVersion
]

{ #category : #accessing }
GossipApplicationState >> value [

	^ value
]

{ #category : #accessing }
GossipApplicationState >> value: anObject [

	value := anObject
]
