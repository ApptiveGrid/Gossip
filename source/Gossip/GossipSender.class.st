Class {
	#name : #GossipSender,
	#superclass : #Object,
	#instVars : [
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
	socket 
		sendUDPData: (STON toString: aMessage)
	 	toHost: address 
		port: port 
	
]
