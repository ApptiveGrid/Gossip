"
A clock that does not move by itself: whoever is testing sets it and moves it on. Otherwise it behaves like DateAndTime.

It is the test side of the seam in Gossiper>>clock, which in production is the class DateAndTime itself. Each gossiper holds its own clock, which is what makes it possible to show two images disagreeing about the time - and it is also why a ""last seen"" timestamp is local knowledge and never travels.
"
Class {
	#name : 'GossipManualClock',
	#superclass : 'Object',
	#instVars : [
		'now'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'instance creation' }
GossipManualClock class >> from: aDateAndTime [
	^ self new
		now: aDateAndTime;
		yourself
]

{ #category : 'accessing' }
GossipManualClock >> advanceBy: aDuration [
	"Move the clock forward and answer the new time."
	now := now + aDuration.
	^ now
]

{ #category : 'initialization' }
GossipManualClock >> initialize [
	super initialize.
	now := DateAndTime now
]

{ #category : 'accessing' }
GossipManualClock >> now [
	^ now
]

{ #category : 'accessing' }
GossipManualClock >> now: aTime [
	now := aTime
]
