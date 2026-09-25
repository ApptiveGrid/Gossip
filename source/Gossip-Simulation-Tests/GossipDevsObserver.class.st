"
An observer on the DEVS network, sending the way DevsGossiper does.
"
Class {
	#name : 'GossipDevsObserver',
	#superclass : 'GossipObserver',
	#instVars : [
		'devsServer'
	],
	#category : 'Gossip-Simulation-Tests',
	#package : 'Gossip-Simulation-Tests'
}

{ #category : 'accessing' }
GossipDevsObserver >> devsServer: aDevsServer [

	devsServer := aDevsServer
]

{ #category : 'accessing' }
GossipDevsObserver >> sendMessage: aGossipMessage to: anEndpoint [

	devsServer
		send: (STON toString: aGossipMessage)
		to: anEndpoint port printString
		port: 1
]
