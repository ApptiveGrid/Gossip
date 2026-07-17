Class {
	#name : 'DevsGossiper',
	#superclass : 'Gossiper',
	#instVars : [
		'devsServer'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'not defined protocol' }
DevsGossiper >> devsServer [
	^ devsServer
]

{ #category : 'not defined protocol' }
DevsGossiper >> devsServer: aDevsServer [
	devsServer := aDevsServer
]

{ #category : 'not defined protocol' }
DevsGossiper >> sendMessage: aGossipMessage to: endpoint [
	devsServer
		send: (STON toString: aGossipMessage)
		to: endpoint port printString
		port: 1
]
