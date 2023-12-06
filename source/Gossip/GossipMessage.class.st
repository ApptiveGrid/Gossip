Class {
	#name : #GossipMessage,
	#superclass : #Object,
	#category : #Gossip
}

{ #category : #'as yet unclassified' }
GossipMessage >> processIn: aGossiper for: anEndpoint [ 
	self subclassResponsibility 
]
