Class {
	#name : #GossipSynMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'list'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipSynMessage >> list: anUndefinedObject [ 
	list := anUndefinedObject 
]
