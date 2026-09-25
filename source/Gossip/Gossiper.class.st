Class {
	#name : 'Gossiper',
	#superclass : 'Object',
	#instVars : [
		'server',
		'sender',
		'endpoints',
		'seedNodes',
		'generation',
		'process',
		'duration',
		'running',
		'clock'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
Gossiper class >> instance [ 
	^ instance ifNil: [ 
		instance := self new ]
]

{ #category : 'not defined protocol' }
Gossiper >> addToList: aKey item: anItem [
	| holder list |
	holder := self localEndpointState applicationStateAt: aKey ifAbsentPut: [ GossipApplicationState new ].
	list := holder value ifNil: [ GossipListValue new ].
	list add: anItem.
	self localEndpointState applicationStateAt: aKey put: list
]

{ #category : 'accessing' }
Gossiper >> address [
	^ self server address
]

{ #category : 'accessing' }
Gossiper >> address: address [ 
	self server address: address
]

{ #category : 'accessing' }
Gossiper >> clock [
	"Where this image reads the time for 'last seen'. In production the class
	DateAndTime itself, which already understands now; a test or a simulation puts
	its own clock here. One clock per reader, never a shared one - that is what
	keeps clock skew between images representable at all."
	^ clock ifNil: [ clock := DateAndTime ]
]

{ #category : 'accessing' }
Gossiper >> clock: anObject [
	clock := anObject
]

{ #category : 'accessing' }
Gossiper >> defaultDuration [
	^ 1 second
]

{ #category : 'accessing' }
Gossiper >> duration [

	^ duration ifNil: [ 
		duration := self defaultDuration ]
]

{ #category : 'accessing' }
Gossiper >> duration: anObject [

	duration := anObject
]

{ #category : 'accessing' }
Gossiper >> endpoints [
	^ endpoints ifNil: [ 
		endpoints := GossipEndpoints new
			gossiper: self;
			yourself ]
]

{ #category : 'accessing' }
Gossiper >> generation [
	^ generation 
]

{ #category : 'as yet unclassified' }
Gossiper >> gossip [
	| message state |
	state := self localEndpointState.
	state increaseHeartbeat.
	"This image is seen whenever it speaks, so the answer to 'when last seen' is
	the same kind of answer for every member, its own entry included."
	state seenAt: self clock now.
	message := GossipSynMessage new
		sender: self localEndpoint;
		digests: self endpoints digests.
	self randomNodes do: [ :endpoint |
		self sendMessage: message to: endpoint ]
]

{ #category : 'initialization' }
Gossiper >> initialize [ 
	super initialize.
	running := false.
	generation := self newGeneration
]

{ #category : 'accessing' }
Gossiper >> localEndpoint [
	^ self server endpoint
]

{ #category : 'accessing' }
Gossiper >> localEndpointState [
	^ self endpoints
		  endpointStateAt: self localEndpoint
		  ifAbsentPut: [
			  self log: 'this incarnation is generation ' , generation printString.
			  GossipEndpointState new
				  endpoint: self localEndpoint;
				  generation: generation;
				  yourself ]
]

{ #category : 'private' }
Gossiper >> log: aString [
	"Through Beacon rather than straight onto the Transcript. The Transcript is one
	possible listener, not the channel itself: an image that wants these lines
	elsewhere - a file, a collector, nowhere at all - says so by registering a
	logger, and does not have to reach into Gossip to do it.

	The speaker is named in the line because the listener cannot know it: several
	gossipers can run in one image, and in the tests here they do."

	GossipSignal emit: self localEndpoint asString , ': ' , aString
]

{ #category : 'gossiping' }
Gossiper >> newGeneration [
	"A number for this incarnation: higher than the one before it, and ordering
	sensibly against what other images draw. The wall clock in milliseconds does
	both. It is raised past the previous one where it has to be, because two
	incarnations can fall in the same millisecond - not in a deployment, easily in a
	simulation."

	^ (Time microsecondClockValue / 1000) rounded
	  max: (generation ifNil: [ 0 ]) + 1
]

{ #category : 'instance creation' }
Gossiper >> newMessage: aClass [ 
	^ aClass new
		sender: self localEndpoint
]

{ #category : 'accessing' }
Gossiper >> port: anInteger [ 
	self server port: anInteger 
]

{ #category : 'accessing' }
Gossiper >> publishedPort: anInteger [ 
	"What the others are told to answer to, when that is not the port the socket
	binds. See GossipServer>>publishedPort."

	self server publishedPort: anInteger
]

{ #category : 'printing' }
Gossiper >> printOn: aStream [ 
	aStream << 'gossiper: ' << self localEndpoint asString
]

{ #category : 'gossiping' }
Gossiper >> gossipTargetCount [
	"How many images this one speaks to in a round. Three, whatever the cluster
	knows: what a round costs has to stay flat while the membership grows, and that
	is the whole point of gossip."

	^ 3
]

{ #category : 'gossiping' }
Gossiper >> randomNodes [
	"Whom this image talks to in this round: three at random out of everything it
	has learned, with a seed always among them.

	The seeds are the way in, not the conversation. Before anything is learned they
	are the only candidates there are; afterwards they are candidates like any
	other, and the one guarantee kept on top is that a seed is always in the set.
	That is what carries a returning image back into a cluster, and what keeps two
	halves that have only heard of each other through a third from drifting apart.

	This used to answer the seed list and nothing else, so an image spoke only ever
	to its seeds no matter how many members it knew. It did not show while every
	image seeded every other one; it shows the moment the seeds are a chosen few.

	A seed is put in place of one of the three rather than added to them: the set
	stays three however many members there are."

	| seeds candidates chosen |
	seeds := (self seedNodes ifNil: [ #(  ) ]) reject: [ :each |
		         each = self localEndpoint ].
	candidates := Set new.
	candidates
		addAll: self endpoints keys;
		addAll: seeds;
		remove: self localEndpoint ifAbsent: [  ].
	candidates isEmpty ifTrue: [ ^ #(  ) ].
	chosen := (candidates asArray shuffled first:
		           (self gossipTargetCount min: candidates size)) asOrderedCollection.
	(seeds isEmpty or: [
		 chosen anySatisfy: [ :each | seeds includes: each ] ]) ifFalse: [
		chosen at: chosen size put: seeds atRandom ].
	^ chosen
]

{ #category : 'as yet unclassified' }
Gossiper >> received: aString from: endpoint [
	self 
		receivedMessage: (STON fromString: aString) 
		from: endpoint.

]

{ #category : 'as yet unclassified' }
Gossiper >> receivedMessage: aMessage from: endpoint [
	aMessage processIn: self from: endpoint
]

{ #category : 'utilities - objectiveC' }
Gossiper >> reply: aGossipMessage to: anEndpoint [
	"Out of the socket this gossiper listens on, not the one it sends from. An answer
	to where a message came from has to leave the way that message arrived: a
	gateway that translated the question lets back only what comes from the
	address and port the question went to."

	self server send: (STON toString: aGossipMessage) to: anEndpoint
]

{ #category : 'not defined protocol' }
Gossiper >> removeFromList: aKey item: anItem [
	| holder list |
	holder := self localEndpointState applicationStateAt: aKey ifAbsentPut: [ GossipApplicationState new ].
	list := holder value ifNil: [ GossipListValue new ].
	list remove: anItem.
	self localEndpointState applicationStateAt: aKey put: list
]

{ #category : 'gossiping' }
Gossiper >> restart [
	"What a restart does to a gossiper, without a process being restarted: whatever
	it had learned is gone, and it comes back under the same endpoint as a new
	incarnation.

	That is all a restart is as far as the protocol is concerned. The others
	recognise the higher generation and replace what they held rather than merging
	it - GossipEndpointState>>processDigest:forMessage: asks for a complete refresh,
	GossipEndpoints>>apply:to: does the replacing.

	The socket is not touched: whether this gossiper runs and where it listens is the
	caller's business, and in a simulation there is no socket at all. Which is the
	point of having this - a gossiper wired into a model cannot be swapped for a
	fresh one the way a test holding two objects can."

	endpoints := nil.
	generation := self newGeneration
]

{ #category : 'accessing' }
Gossiper >> run [
	running := true.
	process ifNotNil: [ process terminate ].
	process := [ self runLoop ] forkNamed: self localEndpoint printString, ' gossiper loop'
]

{ #category : 'accessing' }
Gossiper >> runLoop [
	[ running ] whileTrue: [
		self gossip.
		self duration wait ]
]

{ #category : 'accessing' }
Gossiper >> seedNodes [
	^ seedNodes
]

{ #category : 'accessing' }
Gossiper >> seedNodes: aCollection [ 
	seedNodes := aCollection
]

{ #category : 'utilities - objectiveC' }
Gossiper >> sendMessage: aGossipSimpleMessage to: endpoint [
	self
		sendMessage: aGossipSimpleMessage 
		toAdress: endpoint address 
		port: endpoint port 
]

{ #category : 'utilities - objectiveC' }
Gossiper >> sendMessage: aGossipSimpleMessage toAdress: aCollection port: anInteger [ 
	self sender 
		sendMessage: aGossipSimpleMessage 
		toAdress: aCollection 
		port: anInteger 
]

{ #category : 'accessing' }
Gossiper >> sender [
	^ sender ifNil: [ 
		sender := GossipSender new
			gossiper: self;
			yourself  ]
]

{ #category : 'accessing' }
Gossiper >> server [ 
	^ server ifNil: [
		server := GossipServer new 
			gossiper: self;
			yourself ]
]

{ #category : 'accessing' }
Gossiper >> start [ 
	self server run.
	self run
]

{ #category : 'accessing' }
Gossiper >> stateAt: aString [ 
	^ (self localEndpointState applicationStateAt: aString) value
]

{ #category : 'accessing' }
Gossiper >> stateAt: key put: value [
	self localEndpointState applicationStateAt: key put: value
]

{ #category : 'accessing' }
Gossiper >> stop [
	"Leave the loop before closing the sockets, and make sure no process outlives
	this call. This used to close the sockets and leave the loop running, so a
	stopped gossiper kept sending into a destroyed socket every duration - which
	surfaces much later, and somewhere else, as a TestFailedByForkedProcess in
	whatever test happens to be running at the time."
	running := false.
	process ifNotNil: [ :p |
		p terminate.
		process := nil ].
	server ifNotNil: [ server stop ].
	sender ifNotNil: [ sender stop ]
]
