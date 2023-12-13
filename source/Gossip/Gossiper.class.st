Class {
	#name : #Gossiper,
	#superclass : #Object,
	#instVars : [
		'server',
		'sender'
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

{ #category : #accessing }
Gossiper >> myEndpoint [
	^ self endpoints at: GossipEndpoint me
]

{ #category : #accessing }
Gossiper >> myEndpointState [
	^ self endpoints at: GossipEndpoint me
]

{ #category : #accessing }
Gossiper >> port: anInteger [ 
	self server port: anInteger 
]

{ #category : #'as yet unclassified' }
Gossiper >> received: aString from: endpoint [
	self 
		receivedMessage: (STON fromString: aString) 
		from: endpoint.

]

{ #category : #'as yet unclassified' }
Gossiper >> receivedMessage: aMessage from: endpoint [
	aMessage processIn: self endpoints for: endpoint
]

{ #category : #'utilities - objectiveC' }
Gossiper >> sendMessage: aGossipSimpleMessage toAdress: aCollection port: anInteger [ 
	self sender 
		sendMessage: aGossipSimpleMessage 
		toAdress: aCollection 
		port: anInteger 
]

{ #category : #accessing }
Gossiper >> sender [
	^ sender ifNil: [ 
		sender := GossipSender new  ]
]

{ #category : #accessing }
Gossiper >> server [ 
	^ server ifNil: [
		server := GossipServer new 
			gossiper: self;
			yourself ]
]

{ #category : #accessing }
Gossiper >> start [ 
	self server run

]

{ #category : #accessing }
Gossiper >> stateAt: aString [ 
	^ (self myEndpoint stateAt: aString) value
]

{ #category : #accessing }
Gossiper >> stateAt: key put: value [
	| valueHolder |
	valueHolder := self myEndpoint 
		stateAt: key
		ifAbsentPut: [ GossipVersionedValue new ].
	valueHolder setValue: value
	
]

{ #category : #accessing }
Gossiper >> stop [
	server ifNotNil: [  
		server stop ].
	sender ifNotNil: [ 
		sender stop ]
]
