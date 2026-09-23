Class {
	#name : 'GossipSender',
	#superclass : 'Object',
	#instVars : [
		'gossiper',
		'socket'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
GossipSender class >> instance [ 
	^ instance ifNil: [ 
		instance := self new ]
]

{ #category : 'accessing' }
GossipSender >> gossiper: aGossiper [ 
	gossiper := aGossiper
]

{ #category : 'initialization' }
GossipSender >> initialize [ 
	super initialize.
	socket := Socket newUDP.
]

{ #category : 'utilities - objectiveC' }
GossipSender >> sendMessage: aMessage to: endpoint [ 
	self 
		sendMessage: aMessage 
		toAdress: endpoint address 
		port: endpoint port 
]

{ #category : 'utilities - objectiveC' }
GossipSender >> sendMessage: aMessage toAdress: address port: port [ 
	"Not a line per message. A round goes to three images every second, and each
	syn it answers costs an ack and each ack an ack2 - which on a deployment of
	five images is of the order of a million lines a day, through the transcript
	and out to the log host. What comes up and what goes down is still said; what
	travels is not."

	socket 
		sendUDPData: (STON toString: aMessage)
	 	toHost: address  
		port: port 
	
]

{ #category : 'accessing' }
GossipSender >> stop [
	socket closeAndDestroy 
]
