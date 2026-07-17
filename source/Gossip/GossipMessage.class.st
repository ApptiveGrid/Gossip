Class {
	#name : 'GossipMessage',
	#superclass : 'Object',
	#instVars : [
		'sender'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
GossipMessage >> sender: aGossipEndpoint [ 
	sender := aGossipEndpoint 
]
