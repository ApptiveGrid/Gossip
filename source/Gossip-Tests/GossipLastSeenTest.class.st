"
What ""last seen"" means, and what it deliberately does not mean.

Two gossipers, no sockets: the state of the far one is handed to the near one by hand, exactly as a delta would arrive. Checked is that the timestamp follows the far one's own heartbeat - not the mere fact that somebody mentioned it again - and that it is stamped with the clock of the image doing the seeing.
"
Class {
	#name : 'GossipLastSeenTest',
	#superclass : 'TestCase',
	#instVars : [
		'here',
		'there',
		'clock',
		'thereEndpoint'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipLastSeenTest >> lastSeenOfThere [
	^ (here endpoints endpointStateAt: thereEndpoint ifAbsent: [ ^ nil ]) lastSeen
]

{ #category : 'running' }
GossipLastSeenTest >> setUp [
	super setUp.
	clock := GossipManualClock from: (DateAndTime year: 2026 month: 9 day: 22).
	here := Gossiper new
		address: #[127 0 0 1];
		port: 9001;
		clock: clock;
		yourself.
	there := Gossiper new
		address: #[127 0 0 1];
		port: 9002;
		yourself.
	thereEndpoint := there localEndpoint.
	"A gossiper knows nobody, not even itself, until it first touches its own state."
	here localEndpointState.
	there localEndpointState
]

{ #category : 'running' }
GossipLastSeenTest >> tellHereAboutThere [
	"Hand over what the far gossiper would send about itself."
	here endpoints applyChanges: (Dictionary new
		at: thereEndpoint put: there localEndpointState allStates;
		yourself)
]

{ #category : 'tests' }
GossipLastSeenTest >> testAHeartbeatThatMovedStampsItAgain [
	| first |
	self tellHereAboutThere.
	first := self lastSeenOfThere.
	clock advanceBy: 30 seconds.
	there localEndpointState increaseHeartbeat.
	self tellHereAboutThere.
	self assert: self lastSeenOfThere equals: first + 30 seconds
]

{ #category : 'tests' }
GossipLastSeenTest >> testAnEndpointNeverHeardOfHasNoTimestamp [
	"nil is the answer to 'never heard of', and it has to stay distinguishable
	from 'heard of long ago'."
	self assert: self lastSeenOfThere isNil
]

{ #category : 'tests' }
GossipLastSeenTest >> testGossipingStampsTheLocalEntry [
	"Every member gets the same kind of answer, this image included."
	here seedNodes: { here localEndpoint }.
	here localEndpointState seenAt: nil.
	here gossip.
	self assert: here localEndpointState lastSeen equals: clock now
]

{ #category : 'tests' }
GossipLastSeenTest >> testHearingTheSameStateAgainDoesNotStampIt [
	"The far node said nothing new; somebody merely repeated it. That is not a
	sign of life, and this is the whole reason the timestamp is not simply set on
	every message that arrives."
	| first |
	self tellHereAboutThere.
	first := self lastSeenOfThere.
	clock advanceBy: 30 seconds.
	self tellHereAboutThere.
	self assert: self lastSeenOfThere equals: first
]

{ #category : 'tests' }
GossipLastSeenTest >> testLearningAnEndpointStampsIt [
	self tellHereAboutThere.
	self assert: self lastSeenOfThere equals: clock now
]

{ #category : 'tests' }
GossipLastSeenTest >> testTheTimestampComesFromTheSeeingImage [
	"It is stamped by the image that saw it, with its own clock - which is also
	why it is never part of what travels."
	there clock: (GossipManualClock from: (DateAndTime year: 1999 month: 1 day: 1)).
	self tellHereAboutThere.
	self assert: self lastSeenOfThere equals: clock now
]
