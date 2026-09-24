"
What gossip says about itself, on Pharo's own signal channel instead of straight on the Transcript.

A StringSignal, so anything already listening for StringSignal hears it as well, while an image that wants only gossip can start a logger for this class alone. Beacon-Core is part of the base image, so this costs Gossip no dependency.

What gets said is deliberately rare - see GossipEndpoints for which events earn a line, and why a delta arriving is not one of them.
"
Class {
	#name : 'GossipSignal',
	#superclass : 'StringSignal',
	#classInstVars : [
		'printsTimestamp'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
GossipSignal class >> printsTimestamp [
	"Whether the one-line form begins with the signal's own timestamp, the way
	BeaconSignal's does. True unless someone says otherwise, so an image that does
	nothing gets Beacon's behaviour and nothing here surprises it."

	^ printsTimestamp ifNil: [ printsTimestamp := true ]
]

{ #category : 'accessing' }
GossipSignal class >> printsTimestamp: aBoolean [
	"Set this to false where the log already stamps its own time - a container
	behind docker's syslog driver, for instance, whose lines arrive with date, host
	and container in front of them. Then one date per line instead of two.

	It is the printed form that changes, never the signal: the timestamp stays on
	the object either way, for anyone reading it as data rather than as text."

	printsTimestamp := aBoolean
]

{ #category : 'printing' }
GossipSignal >> printOneLineOn: aStream [
	"Both forms are wanted, so the timestamp is a switch rather than a decision made
	here - see printsTimestamp:. The class name is not: several kinds of signal land
	in the same stream, and it is what says which one spoke."

	self class printsTimestamp ifTrue: [
		aStream
			nextPutAll: self timestamp asString;
			space ].
	aStream
		nextPutAll: self class name;
		space.
	self printOneLineContentsOn: aStream
]
