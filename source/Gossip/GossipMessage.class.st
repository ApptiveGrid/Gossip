Class {
	#name : 'GossipMessage',
	#superclass : 'Object',
	#instVars : [
		'sender'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'processing' }
GossipMessage >> processIn: aGossiper from: anEndpoint [
	"Where the datagram came from, for the one message that can be answered there.
	Every other message has no use for it and does what it always did."

	^ self processIn: aGossiper
]

{ #category : 'accessing' }
GossipMessage >> sender: aGossipEndpoint [ 
	sender := aGossipEndpoint 
]
