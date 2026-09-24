"
That one datagram cannot end the receive loop, and that the buffer is not the thing deciding a message is too big.

This is what stood between gossip and production. The receive loop parsed every datagram inside a whileTrue: with nothing catching, so an unparseable one left through the ensure:, closed the socket and ended discovery for that image - silently, and until somebody restarted it. And a datagram larger than the buffer is exactly an unparseable one: what arrives is a prefix of STON.

No sockets here. What is exercised is the handling of one datagram, which is where all of that lived.
"
Class {
	#name : 'GossipDatagramSizeTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossiper',
		'server',
		'from'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipDatagramSizeTest >> ackFor: aCount [
	"What a member sends when it hands over everything it knows: a cluster of that
	size, one key each, in one message."

	| other ack |
	other := Gossiper new
		         address: #[ 10 10 0 6 ];
		         port: 3601;
		         yourself.
	other localEndpointState.
	other stateAt: 'type' put: #base.
	2 to: aCount do: [ :i |
		| endpoint state |
		endpoint := GossipEndpoint
			             address: { 10. 10. 0. i } asByteArray
			             port: 3600 + i.
		state := other endpoints newEndpointStateFor: endpoint.
		state applicationStateAt: 'type' put: #base ].
	ack := GossipAckMessage new.
	other endpoints keysAndValuesDo: [ :endpoint :state |
		ack updateEndpoint: endpoint with: state allStates ].
	^ STON toString: ack
]

{ #category : 'running' }
GossipDatagramSizeTest >> setUp [
	super setUp.
	gossiper := TestGossiper new
		            address: #[ 127 0 0 1 ];
		            port: 9001;
		            yourself.
	gossiper localEndpointState.
	server := GossipServer new
		          port: 9001;
		          gossiper: gossiper;
		          yourself.
	from := GossipEndpoint address: #[ 127 0 0 1 ] port: 9002
]

{ #category : 'tests' }
GossipDatagramSizeTest >> testADatagramFillingTheBufferIsNotParsedAtAll [
	"It is a prefix of a message, and a prefix either fails to parse or - worse -
	parses into something shorter that says what was never sent."

	| mark |
	mark := gossiper loggedLines size.
	server received: (String new: server bufferSize) from: from.
	self assert: gossiper receivedMessages isEmpty.
	self assert:
		((gossiper loggedLines allButFirst: mark) anySatisfy: [ :each |
			 each includesSubstring: 'cut short' ])
]

{ #category : 'tests' }
GossipDatagramSizeTest >> testAnAckForALargeClusterStillFits [
	"Seventeen members was where the old buffer of 4096 gave way. The point is not
	that this number is enough, it is that the buffer no longer has an opinion."

	self assert: (self ackFor: 17) size < server bufferSize.
	self assert: (self ackFor: 60) size < server bufferSize
]

{ #category : 'tests' }
GossipDatagramSizeTest >> testAnUnreadableDatagramDoesNotStopTheLoop [
	"The whole point. Before this, one of these closed the socket and discovery was
	over for this image until somebody noticed."

	self
		shouldnt: [ server received: 'this is not STON at all' from: from ]
		raise: Error
]

{ #category : 'tests' }
GossipDatagramSizeTest >> testAnUnreadableDatagramIsSaidOnce [
	"Logged by class and size, never by its text: a STONReaderError carries the whole
	message it failed on, and putting that in a log is how one bad datagram becomes a
	megabyte."

	| mark line |
	mark := gossiper loggedLines size.
	server received: 'this is not STON at all' from: from.
	line := (gossiper loggedLines allButFirst: mark) detect: [ :each |
		         each includesSubstring: 'could not read' ].
	self assert: (line includesSubstring: 'STONReaderError').
	self deny: (line includesSubstring: 'this is not STON at all')
]

{ #category : 'tests' }
GossipDatagramSizeTest >> testAReadableDatagramStillArrives [
	"The guard must not cost the ordinary case."

	| message |
	message := STON toString: GossipSynMessage new.
	server received: message from: from.
	self assert: gossiper receivedMessages size equals: 1
]
