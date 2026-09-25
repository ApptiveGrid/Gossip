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
DevsGossiper >> reply: aGossipMessage to: endpoint [
	"A simulated host has one server and nothing like a second socket, so an answer
	leaves the way everything else does. What the simulation can check is the
	address it is sent to."

	self sendMessage: aGossipMessage to: endpoint
]

{ #category : 'not defined protocol' }
DevsGossiper >> sendMessage: aGossipMessage to: endpoint [
	devsServer
		send: (STON toString: aGossipMessage)
		to: endpoint port printString
		port: 1
]
