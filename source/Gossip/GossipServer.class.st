Class {
	#name : #GossipServer,
	#superclass : #Object,
	#instVars : [
		'loop',
		'process',
		'socket',
		'messageHandler',
		'port',
		'gossiper'
	],
	#classInstVars : [
		'instance'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipServer class >> instance [ 
	^ instance ifNil: [ 
		instance := self new ]
]

{ #category : #accessing }
GossipServer >> defaultPort [ 
	^ 1999
]

{ #category : #accessing }
GossipServer >> gossiper: anObject [

	gossiper := anObject
]

{ #category : #initialization }
GossipServer >> initialize [ 
	super initialize.
	loop := true.
]

{ #category : #accessing }
GossipServer >> port [ 
	^ port ifNil: [ 
		port := self defaultPort ]
]

{ #category : #accessing }
GossipServer >> port: anInteger [ 
	port := anInteger
]

{ #category : #running }
GossipServer >> run [ 
	socket := Socket newUDP 
		setPort: self port; 
		yourself.
	process := [ self runLoop ]
		forkAt: Processor userBackgroundPriority 
		named: 'Gossip receiver on port ', self port printString
]

{ #category : #running }
GossipServer >> runLoop [ 
	| buffer result |
	[ [ loop ] whileTrue: [
		buffer := String new: 256.
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

{ #category : #accessing }
GossipServer >> stop [ 
	process terminate.
	socket closeAndDestroy 
]
