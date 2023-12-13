Class {
	#name : #GossipSender,
	#superclass : #Object,
	#instVars : [
		'gossiper',
		'socket'
	],
	#classInstVars : [
		'instance'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipSender class >> instance [ 
	^ instance ifNil: [ 
		instance := self new ]
]

{ #category : #accessing }
GossipSender >> gossiper: aGossiper [ 
	gossiper := aGossiper
]

{ #category : #initialization }
GossipSender >> initialize [ 
	super initialize.
	socket := Socket newUDP.
]

{ #category : #'utilities - objectiveC' }
GossipSender >> sendMessage: aMessage to: endpoint [ 
	self 
		sendMessage: aMessage 
		toAdress: endpoint address 
		port: endpoint port 
]

{ #category : #'utilities - objectiveC' }
GossipSender >> sendMessage: aMessage toAdress: address port: port [ 
	gossiper log: 'sending ', aMessage class name, ' to ', address asSocketAddress printString, ':', port asString.
	socket 
		sendUDPData: (STON toString: aMessage)
	 	toHost: address  
		port: port 
	
]

{ #category : #accessing }
GossipSender >> stop [
	socket closeAndDestroy 
]
