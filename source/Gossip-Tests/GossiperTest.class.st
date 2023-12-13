Class {
	#name : #GossiperTest,
	#superclass : #TestCase,
	#instVars : [
		'gossiper'
	],
	#category : #'Gossip-Tests'
}

{ #category : #running }
GossiperTest >> setUp [ 
	super setUp.
	gossiper := TestGossiper new 
]

{ #category : #tests }
GossiperTest >> testReceiveAckOnSyn [
	| message |
	message := (gossiper newMessage: GossipSynMessage) 
		digests: GossipDigest exampleList.
	gossiper 
		receivedMessage: message 
		from: GossipEndpoint example2.
	self assert: gossiper sentMessages size equals: 1
]
