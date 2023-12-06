Class {
	#name : #GossipSimpleMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'string'
	],
	#category : #Gossip
}

{ #category : #'as yet unclassified' }
GossipSimpleMessage >> processIn: aGossiper for: anEndpoint [ 
	Transcript show: 'got message: ', string printString; cr
]

{ #category : #accessing }
GossipSimpleMessage >> string [

	^ string
]

{ #category : #accessing }
GossipSimpleMessage >> string: anObject [

	string := anObject
]
