Class {
	#name : #GossipReceiver,
	#superclass : #Object,
	#instVars : [
		'loop',
		'process',
		'socket',
		'messageHandler'
	],
	#category : #Gossip
}

{ #category : #initialization }
GossipReceiver >> initialize [ 
	super initialize.
	loop := true.
]

{ #category : #accessing }
GossipReceiver >> messageHandler: anObject [

	messageHandler := anObject
]

{ #category : #accessing }
GossipReceiver >> port [ 
	^ 1999
]

{ #category : #running }
GossipReceiver >> run [ 
	socket := Socket newUDP 
		setPort: self port; 
		yourself.
	process := [ self runLoop ]
		forkAt: Processor userBackgroundPriority 
		named: 'Gossip receiver on port ', self port printString
]

{ #category : #running }
GossipReceiver >> runLoop [ 
	| buffer result |
	[ [ loop ] whileTrue: [
		buffer := String new: 256.
		socket waitForData.
		result := socket receiveUDPDataInto: buffer.
		messageHandler 
			value: (buffer copyFrom: 1 to: result first)
			value: result second 
			value: result third.
	 ] ]
		ensure: [ 
			Transcript show: 'closing socket on port ', self port printString; cr.
			socket closeAndDestroy ] 
]

{ #category : #accessing }
GossipReceiver >> stop [ 
	process terminate
]
