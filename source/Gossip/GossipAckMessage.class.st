Class {
	#name : #GossipAckMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'digests'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipAckMessage >> digests: aCollection [ 
	digests := aCollection 
]
