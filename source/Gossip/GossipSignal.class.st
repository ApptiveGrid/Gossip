"
What gossip says about itself, on Pharo's own signal channel instead of straight on the Transcript.

A StringSignal, so anything already listening for StringSignal hears it as well, while an image that wants only gossip can start a logger for this class alone. Beacon-Core is part of the base image, so this costs Gossip no dependency.

What gets said is deliberately rare - see GossipEndpoints for which events earn a line, and why a delta arriving is not one of them.
"
Class {
	#name : 'GossipSignal',
	#superclass : 'StringSignal',
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'printing' }
GossipSignal >> printOneLineOn: aStream [
	"Without the timestamp BeaconSignal puts in front. These lines are written to be
	read in a log, and a log stamps its own time: on alpha the containers run with
	docker's syslog driver, so every line already arrives with date, host and
	container in front of it. A second timestamp in the middle of that is noise. The
	time is still on the signal for anyone reading it as an object.

	The class name stays. Several kinds of signal land in the same stream, and it is
	what says which one spoke - AGSignal on the ApptiveGrid side drops the timestamp
	the same way, but leaves nothing in its place except two numbers."

	aStream
		nextPutAll: self class name;
		space.
	self printOneLineContentsOn: aStream
]
