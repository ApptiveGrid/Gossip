Class {
	#name : #GossiperTest,
	#superclass : #TestCase,
	#instVars : [
		'gossiper'
	],
	#category : #Gossip
}

{ #category : #running }
GossiperTest >> setUp [ 
	super setUp.
	gossiper := TestGossiper new 
]

{ #category : #tests }
GossiperTest >> testReceiveAckOnSyn [
	| message |
	message := GossipSynMessage new 
		digests: GossipDigest exampleList.
	gossiper 
		receivedMessage: message 
		from: GossipEndpoint example2.
	self assert: gossiper sentMessages size equals: 1
]
