Class {
	#name : #Gossiper,
	#superclass : #Object,
	#instVars : [
		'server',
		'sender',
		'endpoints',
		'seedNodes'
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
Gossiper >> address [
	^ self server address
]

{ #category : #accessing }
Gossiper >> address: address [ 
	self server address: address
]

{ #category : #accessing }
Gossiper >> endpoint [
	^ self server endpoint
]

{ #category : #accessing }
Gossiper >> endpoints [
	^ endpoints ifNil: [ 
		endpoints := GossipEndpoints new
			gossiper: self;
			yourself ]
]

{ #category : #'as yet unclassified' }
Gossiper >> gossip [
	| message |
	message := GossipSynMessage new
		sender: self endpoint;  
		digests: self endpoints digests.
	self randomNodes do: [ :endpoint |
		self sendMessage: message to: endpoint  ]
]

{ #category : #private }
Gossiper >> log: aString [ 
	Transcript 
		show: self endpoint asString;
		show: ': ';
		show: aString;
		cr
]

{ #category : #accessing }
Gossiper >> myEndpoint [
	^ self endpoints stateAt: self endpoint
]

{ #category : #accessing }
Gossiper >> myEndpointState [
	^ self endpoints at: GossipEndpoint me
]

{ #category : #'instance creation' }
Gossiper >> newMessage: aClass [ 
	^ aClass new
		sender: self endpoint
]

{ #category : #accessing }
Gossiper >> port: anInteger [ 
	self server port: anInteger 
]

{ #category : #printing }
Gossiper >> printOn: aStream [ 
	aStream << 'gossiper: ' << self endpoint asString
]

{ #category : #'as yet unclassified' }
Gossiper >> randomNodes [
	^ self seedNodes copyWithout: self endpoint
]

{ #category : #'as yet unclassified' }
Gossiper >> received: aString from: endpoint [
	self 
		receivedMessage: (STON fromString: aString) 
		from: endpoint.

]

{ #category : #'as yet unclassified' }
Gossiper >> receivedMessage: aMessage from: endpoint [
	aMessage processIn: self
]

{ #category : #accessing }
Gossiper >> seedNodes [
	^ seedNodes
]

{ #category : #accessing }
Gossiper >> seedNodes: aCollection [ 
	seedNodes := aCollection
]

{ #category : #'utilities - objectiveC' }
Gossiper >> sendMessage: aGossipSimpleMessage to: endpoint [
	self
		sendMessage: aGossipSimpleMessage 
		toAdress: endpoint address 
		port: endpoint port 
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
		sender := GossipSender new
			gossiper: self;
			yourself  ]
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
