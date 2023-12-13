Class {
	#name : #GossipSynMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'digests'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipSynMessage >> digests [

	^ digests
]

{ #category : #accessing }
GossipSynMessage >> digests: anObject [

	digests := anObject
]
