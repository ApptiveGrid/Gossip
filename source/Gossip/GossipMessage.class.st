Class {
	#name : #GossipMessage,
	#superclass : #Object,
	#instVars : [
		'sender'
	],
	#category : #Gossip
}

{ #category : #'as yet unclassified' }
GossipMessage >> processIn: aGossiper for: anEndpoint [ 
	| states |
	states := aGossiper stateAt: anEndpoint.
	self halt.
]

{ #category : #accessing }
GossipMessage >> sender: aGossipEndpoint [ 
	sender := aGossipEndpoint 
]
