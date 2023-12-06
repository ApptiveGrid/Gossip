Class {
	#name : #Gossiper,
	#superclass : #Object,
	#instVars : [
		'server'
	],
	#classInstVars : [
		'instance'
	],
	#category : #Gossip
}

{ #category : #accessing }
Gossiper class >> instance [ 
	^ instance ifNil: [ 
		instance := self new ]
]

{ #category : #'as yet unclassified' }
Gossiper >> received: aString from: endpoint [
	| message |
	message := STON fromString: aString.
	message processIn: self for: endpoint
]

{ #category : #'utilities - objectiveC' }
Gossiper >> sendMessage: aGossipSimpleMessage toAdress: aCollection port: anInteger [ 
	self shouldBeImplemented.
]

{ #category : #accessing }
Gossiper >> start [ 
	server := GossipServer new 
		gossiper: self;
		run
]

{ #category : #accessing }
Gossiper >> stop [
	server stop
]
