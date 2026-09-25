Class {
	#name : 'GossipEndpoints',
	#superclass : 'Object',
	#instVars : [
		'gossiper',
		'endpointStates'
	],
	#classInstVars : [
		'instance'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
GossipEndpoints class >> instance [ 
	^ instance ifNil: [ 
		instance := self new ]
]

{ #category : 'accessing' }
GossipEndpoints >> applicationValuesOf: anEndpointStateOrNil [
	"The plain values this image holds for one endpoint, keyed the way a delta is
	keyed. Read before the delta is applied, so that afterwards the two can be
	compared - which is the point of taking it at all: a delta names every key it
	carries, moved or not, so logging on arrival rather than on change would put
	back the line per message that was taken out on 2026-09-23."

	| values |
	values := Dictionary new.
	anEndpointStateOrNil ifNil: [ ^ values ].
	anEndpointStateOrNil allStates applicationStates keysAndValuesDo: [ :key :each |
		values at: key put: each value ].
	^ values
]

{ #category : 'as yet unclassified' }
GossipEndpoints >> apply: aDelta to: anEndpoint [
	"What has arrived about one endpoint - which is not always about the same
	incarnation of it. An image draws a new generation every time it starts, so a
	neighbour that has restarted sends a higher one than the one held here. That is a
	new incarnation: what is held is gone, and the state is replaced rather than
	merged. A lower generation is an older incarnation still travelling and is
	dropped. Only inside one generation are the two merged, which is what the
	heartbeat's version is for.

	The digest side has known this all along - GossipEndpointState>>processDigest:forMessage:
	asks for a complete refresh when it sees a higher generation. This side signalled
	'generation mismatch' instead, which cost the delta that had just arrived and put
	a walkback in every neighbour's log on every restart. Found on alpha on
	2026-09-23, where a deploy restarts all five images at once."

	| local known isNew valuesBefore versionBefore |
	local := endpointStates at: anEndpoint ifAbsent: [ nil ].
	known := local ifNotNil: [ :each | each generation ].
	"A state built here and never heard from carries no generation; those do not
	travel, so an incoming one without a generation is this same incarnation."
	(known notNil and: [ aDelta generation notNil ]) ifTrue: [
		aDelta generation < known ifTrue: [ ^ self ] ].
	isNew := known isNil or: [
		         aDelta generation notNil and: [ aDelta generation > known ] ].
	valuesBefore := self applicationValuesOf: local.
	isNew ifTrue: [
		self logIncarnationOf: anEndpoint from: known to: aDelta generation.
		local := endpointStates
			         at: anEndpoint
			         put: (GossipEndpointState new
					          endpoint: anEndpoint;
					          generation: aDelta generation;
					          yourself) ].
	versionBefore := local heartbeatState version.
	aDelta applyChangesTo: local.
	self logChangesOf: anEndpoint in: aDelta against: valuesBefore.
	"Only a heartbeat that moved forward says the node itself is still there.
	Hearing its state relayed once more, unchanged, says nothing about it - and that
	is the whole point of the timestamp. A new incarnation counts as movement: it
	starts counting from one again, so its version says nothing, but the node itself
	is demonstrably there."
	(isNew or: [ local heartbeatState version > versionBefore ])
		ifTrue: [ local seenAt: self clock now ]
]

{ #category : 'as yet unclassified' }
GossipEndpoints >> applyChanges: aDictionary [
	aDictionary keysAndValuesDo: [ :endpoint :delta |
		self apply: delta to: endpoint ]
]

{ #category : 'accessing' }
GossipEndpoints >> clock [
	"The clock of the gossiper these endpoints belong to. Standing on its own -
	as in the tests that exercise message handling alone - the wall clock does."
	^ gossiper ifNil: [ DateAndTime ] ifNotNil: [ gossiper clock ]
]

{ #category : 'accessing' }
GossipEndpoints >> digests [
	| digests |
	digests := OrderedCollection new.
	endpointStates keysAndValuesDo: [ :endpoint :enpointState |
		digests add: (GossipDigest 
			endpoint: endpoint 
			generation: enpointState generation 
			version: enpointState maxVersion ) ].
	^ digests
]

{ #category : 'accessing' }
GossipEndpoints >> endpointStateAt: key [
	^  endpointStates 
		at: key 
		ifAbsent: [ KeyNotFound signal: 'no endpoint state for ', key printString ]
]

{ #category : 'accessing' }
GossipEndpoints >> endpointStateAt: key ifAbsent: aBlock [
	^  endpointStates 
		at: key 
		ifAbsent: aBlock
]

{ #category : 'accessing' }
GossipEndpoints >> endpointStateAt: key ifAbsentPut: aBlock [
	^  endpointStates 
		at: key 
		ifAbsentPut: aBlock
]

{ #category : 'accessing' }
GossipEndpoints >> endpointStateAt: endpoint overwrite: aGossipEndpointState [ 
	"Silent for the same reason as GossipSender: every round updates every
	endpoint it hears about, so this said nothing except that gossip is running."

	aGossipEndpointState isEmpty ifFalse: [  
	endpointStates at: endpoint put: aGossipEndpointState ]
]

{ #category : 'accessing' }
GossipEndpoints >> endpointStateAt: key put: value [
	self localEndpointState applicationStateAt: key put: value
]

{ #category : 'accessing' }
GossipEndpoints >> gossiper: aGossiper [ 
	gossiper := aGossiper
]

{ #category : 'testing' }
GossipEndpoints >> includesKey: aGossipEndpoint [ 
	^ endpointStates includesKey: aGossipEndpoint 
]

{ #category : 'initialization' }
GossipEndpoints >> initialize [ 
	super initialize.
	endpointStates := Dictionary new
]

{ #category : 'testing' }
GossipEndpoints >> isEmpty [ 
	^ endpointStates isEmpty
]

{ #category : 'logging' }
GossipEndpoints >> isListLike: aValue [
	"A value that is worth saying as a difference rather than in full. A String is a
	collection and is not one of these."

	^ aValue isCollection and: [ aValue isString not ]
]

{ #category : 'accessing' }
GossipEndpoints >> keys [
	^ endpointStates keys
]

{ #category : 'enumerating' }
GossipEndpoints >> keysAndValuesDo: aBlock [
	endpointStates keysAndValuesDo: aBlock
]

{ #category : 'accessing' }
GossipEndpoints >> localEndpointState [
	^ self endpointStateAt: gossiper localEndpoint
]

{ #category : 'logging' }
GossipEndpoints >> log: aString [
	"Through the gossiper, which owns the channel. Standing on its own - as in the
	tests that exercise message handling alone - there is nobody to tell."

	gossiper ifNotNil: [ :each | each log: aString ]
]

{ #category : 'logging' }
GossipEndpoints >> logChangesOf: anEndpoint in: aDelta against: oldValues [
	"One line for every application value that actually moved, and nothing for the
	rest. The comparison is what makes this rare enough to be worth reading: at rest
	the cluster says nothing at all, and a line means something happened."

	aDelta applicationStates keysAndValuesDo: [ :key :each |
		(oldValues includesKey: key)
			ifFalse: [
				self log: anEndpoint asString , ' announces ' , key asString , ' = '
					, (self said: each value against: nil) ]
			ifTrue: [
				(oldValues at: key) = each value ifFalse: [
					self log: anEndpoint asString , ' changes ' , key asString , ' '
						, (self said: each value against: (oldValues at: key)) ] ] ]
]

{ #category : 'logging' }
GossipEndpoints >> logDifferenceLimit [
	"How many comings and goings a single line carries before it says how many more
	there were. Eight, because a line has to stay readable in a syslog - and because
	a difference longer than that is not a change one reads item by item anyway."

	^ 8
]

{ #category : 'logging' }
GossipEndpoints >> logIncarnationOf: anEndpoint from: aGeneration to: aNewGeneration [
	"Two events that look the same by the time the state has been replaced: an
	endpoint nobody here had heard of, and one that was here and has come back as a
	different incarnation of itself. The second is the one worth seeing on a deploy."

	aGeneration
		ifNil: [
			self log: 'new endpoint ' , anEndpoint asString , ', generation '
				, aNewGeneration printString ]
		ifNotNil: [
			self log: anEndpoint asString , ' restarted, generation '
				, aGeneration printString , ' -> ' , aNewGeneration printString ]
]

{ #category : 'instance creation' }
GossipEndpoints >> newEndpointStateFor: endpoint [ 
	^ endpointStates 
		at: endpoint 
		put: (GossipEndpointState new endpoint: endpoint)
]

{ #category : 'as yet unclassified' }
GossipEndpoints >> processAck2Message: ack2Message [
	self applyChanges: ack2Message delta.

]

{ #category : 'as yet unclassified' }
GossipEndpoints >> processAckMessage: ackMessage for: ack2Message [ 
	self applyChanges: ackMessage delta.
	self processDigests: ackMessage digests forMessage: ack2Message
]

{ #category : 'as yet unclassified' }
GossipEndpoints >> processDigest: digest forMessage: message [  
	| endpointState |
	endpointState := self 
		endpointStateAt: digest endpoint 
		ifAbsent: [ ^ message endpointUnknownFor: digest ].
	endpointState  
		processDigest: digest 
		forMessage: message
	
]

{ #category : 'as yet unclassified' }
GossipEndpoints >> processDigests: digestList forMessage: ack2Message [ 
	digestList do: [ :digest |
		self processDigest: digest forMessage: ack2Message ].  
]

{ #category : 'as yet unclassified' }
GossipEndpoints >> processDigestsAndState: digestList forMessage: ack2Message [ 
	| localEndpoints |
	localEndpoints := endpointStates keys asOrderedCollection.
	digestList do: [ :digest |
		localEndpoints remove: digest endpoint ifAbsent: [ ].
		self processDigest: digest forMessage: ack2Message ].  
	localEndpoints do: [ :endpoint | 
		ack2Message updateEndpoint: endpoint with: (endpointStates at: endpoint) allStates ]
	
]

{ #category : 'as yet unclassified' }
GossipEndpoints >> processSynMessage: ackMessage for: ack2Message [ 
	self processDigestsAndState: ackMessage digests forMessage: ack2Message
]

{ #category : 'logging' }
GossipEndpoints >> said: aValue against: anOldValueOrNil [
	"How a value is put into a line. A scalar is said outright, the old one and the
	new one, which is what this log has always done and reads best for a type or an
	endpoint.

	A collection is said as a **difference**, because printing both sides in full is
	how a log turns into a wall: an image that publishes the databases it holds open
	would print the whole set twice on every open and every close, on every member
	that hears it. What is wanted there is what came and what went, and at rest
	nothing is printed at all because nothing moved.

	Long differences are cut off. A member that comes back publishes everything it
	has at once, and that line should stay a line."

	| old added removed parts |
	(self isListLike: aValue) ifFalse: [
		^ anOldValueOrNil
			  ifNil: [ aValue printString ]
			  ifNotNil: [ 'from ' , anOldValueOrNil printString , ' to '
				  , aValue printString ] ].
	old := (self isListLike: anOldValueOrNil)
		       ifTrue: [ anOldValueOrNil asArray ]
		       ifFalse: [ #(  ) ].
	added := aValue asArray reject: [ :each | old includes: each ].
	removed := old reject: [ :each | aValue includes: each ].
	parts := (added collect: [ :each | '+' , each printString ])
	         , (removed collect: [ :each | '-' , each printString ]).
	parts size > self logDifferenceLimit ifTrue: [
		^ (' ' join: (parts first: self logDifferenceLimit)) , ' and '
		  , (parts size - self logDifferenceLimit) printString , ' more' ].
	^ ' ' join: parts
]
