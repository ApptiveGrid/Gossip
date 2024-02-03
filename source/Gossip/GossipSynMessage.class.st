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

{ #category : #'as yet unclassified' }
GossipSynMessage >> processIn: gossiper [
	| ack |
	ack := gossiper newMessage: GossipAckMessage.
	gossiper endpoints 
		processDigests: digests 
		forMessage: ack.
	gossiper 
		sendMessage: ack 
		to: sender
   
]
