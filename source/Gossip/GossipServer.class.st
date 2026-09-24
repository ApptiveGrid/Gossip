Class {
	#name : 'GossipServer',
	#superclass : 'Object',
	#instVars : [
		'loop',
		'process',
		'socket',
		'messageHandler',
		'port',
		'publishedPort',
		'gossiper',
		'address'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'as yet unclassified' }
GossipServer class >> myAddress [
	^ NetNameResolver addressForName:  NetNameResolver localHostName
]

{ #category : 'accessing' }
GossipServer >> address [ 
	^ address ifNil: [ 
		address := self class myAddress ]
]

{ #category : 'accessing' }
GossipServer >> address: aCollection [
	address := aCollection 
]

{ #category : 'accessing' }
GossipServer >> bufferSize [
	"The largest payload a UDP datagram can carry. It is deliberately not a guess at
	how big a message gets: whatever the cluster grows to, the buffer must not be
	the thing that cuts a message in half.

	It used to be 4096, and that was a cliff rather than a limit. Measured with one
	key per member, an ack carrying a full delta is 1344 bytes at five members, 2832
	at eleven and 4320 at seventeen - so somewhere past sixteen members the first
	message would have been cut short, and a cut-short message is what ended the
	receive loop (see #received:from:). Around 248 bytes per member, this holds a
	cluster of some 260.

	The datagram still has to cross the network in one piece. On the Nebula overlay,
	whose MTU is 1280, five members already exceed it and IP fragments it - measured
	on alpha on 2026-09-23, where fragmented datagrams arrive. Losing one fragment
	loses the whole datagram, which gossip survives by repeating itself every round.
	Chunking the ack or leaving the single datagram behind stay open; neither is
	needed to take the cliff away."

	^ 65507
]

{ #category : 'accessing' }
GossipServer >> defaultPort [ 
	^ 1999
]

{ #category : 'accessing' }
GossipServer >> endpoint [
	"What this server is to everybody else: the address it publishes and the port
	it publishes, neither of which has to be what the socket sees."

	^ GossipEndpoint address: self address port: self publishedPort
]

{ #category : 'accessing' }
GossipServer >> gossiper: anObject [

	gossiper := anObject
]

{ #category : 'initialization' }
GossipServer >> initialize [ 
	super initialize.
	loop := true.
]

{ #category : 'accessing' }
GossipServer >> port [ 
	^ port ifNil: [ 
		port := self defaultPort ]
]

{ #category : 'accessing' }
GossipServer >> port: anInteger [ 
	"The port the socket binds. What others are told to answer to is the published
	port, which follows this one unless it is set."

	port := anInteger
]

{ #category : 'accessing' }
GossipServer >> publishedPort [
	"The port other images are told to answer to. Behind a port mapping that is not
	the port the socket binds - every container binds the same number and the host
	maps a different one to each - and gossip answers to the endpoint a message
	declares rather than to the socket it arrived from, so it is the published one
	that has to be reachable.

	The same seam as #address, and there for the same reason: what this process can
	see of itself is not what the others can reach. Answers the bound port when
	nothing is set, which is the truth wherever nothing maps."

	^ publishedPort ifNil: [ self port ]
]

{ #category : 'accessing' }
GossipServer >> publishedPort: anInteger [ 
	publishedPort := anInteger
]

{ #category : 'running' }
GossipServer >> received: aString from: anEndpoint [
	"One datagram, and nothing that can be wrong with it may stop the loop. This used
	to run inside the whileTrue: with nothing catching: a single message that did not
	parse - which is exactly what a datagram larger than the buffer becomes - left the
	loop through the ensure:, closed the socket, and ended discovery for this image,
	silently and for good.

	A datagram that fills the buffer exactly is not parsed at all. What arrived is a
	prefix, and a prefix of STON is either an error or, worse, a shorter message that
	parses and says something untrue.

	The error is logged by class and size, never by its text: a STONReaderError
	carries the whole message it failed on, and putting that in a log is how one bad
	datagram becomes a megabyte."

	aString size = self bufferSize ifTrue: [
		^ gossiper log: 'dropped a datagram from ' , anEndpoint printString
			  , ' that filled the whole buffer - it was cut short' ].
	[ gossiper received: aString from: anEndpoint ]
		on: Error
		do: [ :anError |
			gossiper log: 'could not read a datagram of ' , aString size printString
				, ' bytes from ' , anEndpoint printString , ': ' , anError class name ]
]

{ #category : 'running' }
GossipServer >> run [ 
	socket := Socket newUDP 
		setPort: self port; 
		yourself.
	process := [ self runLoop ]
		forkAt: Processor userBackgroundPriority 
		named: 'Gossip receiver on port ', self port printString
]

{ #category : 'running' }
GossipServer >> runLoop [
	"The buffer is allocated once rather than per datagram, and it is the largest a
	UDP datagram can be - so that it is never the buffer that decides a message was
	too big."

	| buffer result |
	buffer := String new: self bufferSize.
	[
	[ loop ] whileTrue: [
		socket waitForData.
		result := socket receiveUDPDataInto: buffer.
		self
			received: (buffer copyFrom: 1 to: result first)
			from: (GossipEndpoint fromUDP: result) ] ] ensure: [
		gossiper ifNotNil: [
			gossiper log: 'the receiver on port ' , self port printString , ' is stopping' ].
		socket closeAndDestroy ]
]

{ #category : 'accessing' }
GossipServer >> stop [ 
	process ifNotNil: [  
		process terminate ].
	socket ifNotNil: [  
		socket closeAndDestroy ]
]
