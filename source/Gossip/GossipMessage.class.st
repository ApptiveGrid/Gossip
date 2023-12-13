Class {
	#name : #GossipMessage,
	#superclass : #Object,
	#instVars : [
		'sender'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipMessage >> sender: aGossipEndpoint [ 
	sender := aGossipEndpoint 
]
