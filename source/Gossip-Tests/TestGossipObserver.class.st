"
An observer that keeps what it would send instead of sending it, so that whom it asks can be looked at without a socket.
"
Class {
	#name : 'TestGossipObserver',
	#superclass : 'GossipObserver',
	#instVars : [
		'sentMessages'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'initialization' }
TestGossipObserver >> initialize [

	super initialize.
	sentMessages := OrderedCollection new
]

{ #category : 'accessing' }
TestGossipObserver >> sendMessage: aMessage to: anEndpoint [

	sentMessages add: aMessage -> anEndpoint
]

{ #category : 'accessing' }
TestGossipObserver >> sentMessages [

	^ sentMessages
]

{ #category : 'accessing' }
TestGossipObserver >> sentSyns [

	^ sentMessages select: [ :each | each key isKindOf: GossipSynMessage ]
]
