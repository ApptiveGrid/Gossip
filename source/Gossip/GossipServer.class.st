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
	| buffer result |
	[ [ loop ] whileTrue: [
		buffer := String new: 4096.
		socket waitForData.
		result := socket receiveUDPDataInto: buffer.
		gossiper 
			received:  (buffer copyFrom: 1 to: result first)
			from: (GossipEndpoint fromUDP: result)
	 ] ]
		ensure: [ 
			Transcript show: 'closing socket on port ', self port printString; cr.
			socket closeAndDestroy ] 
]

{ #category : 'accessing' }
GossipServer >> stop [ 
	process ifNotNil: [  
		process terminate ].
	socket ifNotNil: [  
		socket closeAndDestroy ]
]
