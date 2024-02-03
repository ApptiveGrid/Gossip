Class {
	#name : #Gossiper,
	#superclass : #Object,
	#instVars : [
		'server',
		'sender',
		'endpoints',
		'seedNodes',
		'generation',
		'process',
		'duration'
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
Gossiper >> defaultDuration [
	^ 1 second
]

{ #category : #accessing }
Gossiper >> duration [

	^ duration ifNil: [ 
		duration := self defaultDuration ]
]

{ #category : #accessing }
Gossiper >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
Gossiper >> endpoints [
	^ endpoints ifNil: [ 
		endpoints := GossipEndpoints new
			gossiper: self;
			yourself ]
]

{ #category : #accessing }
Gossiper >> generation [
	^ generation 
]

{ #category : #'as yet unclassified' }
Gossiper >> gossip [
	| message |
	self localEndpointState increaseHeartbeat.
	message := GossipSynMessage new
		sender: self localEndpoint;  
		digests: self endpoints digests.
	self randomNodes do: [ :endpoint |
		self sendMessage: message to: endpoint  ]
]

{ #category : #initialization }
Gossiper >> initialize [ 
	super initialize.
	generation := (Time microsecondClockValue / 1000) rounded .
]

{ #category : #accessing }
Gossiper >> localEndpoint [
	^ self server endpoint
]

{ #category : #accessing }
Gossiper >> localEndpointState [
	^ self endpoints 
		endpointStateAt: self localEndpoint
		ifAbsentPut: [ 
			Transcript show: 'initializing ', self localEndpoint printString, ' with generation ', generation printString; cr.
			GossipEndpointState new
				endpoint: self localEndpoint;
				generation: generation;
				yourself  ]
]

{ #category : #private }
Gossiper >> log: aString [ 
	Transcript 
		show: self localEndpoint asString;
		show: ': ';
		show: aString;
		cr
]

{ #category : #'instance creation' }
Gossiper >> newMessage: aClass [ 
	^ aClass new
		sender: self localEndpoint
]

{ #category : #accessing }
Gossiper >> port: anInteger [ 
	self server port: anInteger 
]

{ #category : #printing }
Gossiper >> printOn: aStream [ 
	aStream << 'gossiper: ' << self localEndpoint asString
]

{ #category : #'as yet unclassified' }
Gossiper >> randomNodes [
	^ self seedNodes copyWithout: self localEndpoint
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
Gossiper >> run [
	process ifNotNil: [ process terminate ].
	process := [ self runLoop ] forkNamed: self localEndpoint printString, ' gossiper loop'
]

{ #category : #accessing }
Gossiper >> runLoop [
	[ self gossip.
		self duration wait ] repeat
	
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
	self server run.
	self run
]

{ #category : #accessing }
Gossiper >> stateAt: aString [ 
	^ (self localEndpoint stateAt: aString) value
]

{ #category : #accessing }
Gossiper >> stateAt: key put: value [
	| valueHolder |
	valueHolder := self localEndpoint 
		stateAt: key
		ifAbsentPut: [ GossipApplicationState new  ].
	valueHolder setValue: value endpointState: self localEndpoint 
	
]

{ #category : #accessing }
Gossiper >> stop [
	server ifNotNil: [  
		server stop ].
	sender ifNotNil: [ 
		sender stop ]
]
