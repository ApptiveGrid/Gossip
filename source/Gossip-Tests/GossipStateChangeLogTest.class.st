"
What the log says when the cluster changes, and what it does not say when nothing happens.

The line per message was taken out on 2026-09-23 because at five members it wrote around a million lines a day and none of them carried anything: gossip runs, and that is all they said. What is wanted instead is the opposite - silence while the cluster is at rest, and a line for each thing that actually moved: an endpoint heard of for the first time, one that came back as a new incarnation, an application value that changed.

The trap is in the middle of that. A delta names every key it carries, whether the value moved or not, so a line written where the delta is applied would be the line per message again under another name. Hence the comparison against what was held before, and hence the test that a value repeated unchanged says nothing.

No sockets: what the far gossiper would send is handed to the near one by hand, as in GossipRestartTest. The near one is a TestGossiper, which keeps what it logs instead of writing it out.
"
Class {
	#name : 'GossipStateChangeLogTest',
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
GossipStateChangeLogTest >> logged [
	^ here loggedLines
]

{ #category : 'running' }
GossipStateChangeLogTest >> loggedSince: aMark [
	^ here loggedLines allButFirst: aMark
]

{ #category : 'running' }
GossipStateChangeLogTest >> mark [
	"How much had been said before the step under test."

	^ here loggedLines size
]

{ #category : 'running' }
GossipStateChangeLogTest >> restartOfThere [
	"The same endpoint with a generation drawn anew, which is all a restart is."

	| restarted |
	restarted := Gossiper new
		             address: #[ 127 0 0 1 ];
		             port: 9002;
		             yourself.
	restarted localEndpointState generation:
		there localEndpointState generation + 1.
	^ restarted
]

{ #category : 'running' }
GossipStateChangeLogTest >> setUp [
	super setUp.
	clock := GossipManualClock from: (DateAndTime year: 2026 month: 9 day: 24).
	here := TestGossiper new
		        address: #[ 127 0 0 1 ];
		        port: 9001;
		        clock: clock;
		        yourself.
	there := Gossiper new
		         address: #[ 127 0 0 1 ];
		         port: 9002;
		         yourself.
	thereEndpoint := there localEndpoint.
	here localEndpointState.
	there localEndpointState
]

{ #category : 'running' }
GossipStateChangeLogTest >> tell: aGossiper [
	"Hand over what that gossiper would send about itself - as a copy, which is the
	point. On the wire a delta is encoded and decoded, so the far image's objects
	never arrive here. Passing the originals instead, as handing over allStates
	directly does, leaves both sides holding one and the same
	GossipApplicationState: a later change over there is then already visible here
	before any message arrives, and a test that compares before with after measures
	the shortcut rather than the code."

	| state states |
	state := aGossiper localEndpointState.
	states := Dictionary new.
	state allStates applicationStates keysAndValuesDo: [ :key :each |
		states at: key put: (GossipApplicationState new
				 value: each value;
				 maxVersion: each version;
				 yourself) ].
	here endpoints applyChanges: (Dictionary new
			 at: thereEndpoint
			 put: (GossipEndpointStateDelta new
					 heartbeatState: (GossipHeartbeatState new
							 generation: state generation;
							 version: state heartbeatState version;
							 yourself);
					 applicationStates: states;
					 yourself);
			 yourself)
]

{ #category : 'tests' }
GossipStateChangeLogTest >> testANewEndpointIsSaidOnce [
	"Hearing of an endpoint is an event. Hearing of it again is not."

	| mark |
	self tell: there.
	self assert: (self logged anySatisfy: [ :each |
			 each includesSubstring: 'new endpoint' ]).
	mark := self mark.
	self tell: there.
	self assertEmpty: (self loggedSince: mark)
]

{ #category : 'tests' }
GossipStateChangeLogTest >> testANewValueIsAnnounced [
	"A key this image has never held for that endpoint. There is nothing to compare
	it with, so it is announced rather than reported as a change."

	there localEndpointState applicationStateAt: 'type' put: #base.
	self tell: there.
	self assert: (self logged anySatisfy: [ :each |
			 each includesSubstring: 'announces type' ])
]

{ #category : 'tests' }
GossipStateChangeLogTest >> testARepeatedValueIsSilent [
	"The one that matters. A delta carries every key it knows about on every round,
	so taking the delta as the event would put back the line per message that was
	taken out on 2026-09-23 - a million a day saying only that gossip runs."

	| mark |
	there localEndpointState applicationStateAt: 'type' put: #base.
	self tell: there.
	mark := self mark.
	there localEndpointState increaseHeartbeat.
	self tell: there.
	self assertEmpty: (self loggedSince: mark)
]

{ #category : 'tests' }
GossipStateChangeLogTest >> testARestartIsSaidAsARestart [
	"Not the same event as meeting an endpoint for the first time, although by the
	time the state has been replaced the two look alike. On a deploy this is the line
	that says what happened."

	| mark |
	self tell: there.
	mark := self mark.
	self tell: self restartOfThere.
	self assert: ((self loggedSince: mark) anySatisfy: [ :each |
			 each includesSubstring: 'restarted' ])
]

{ #category : 'tests' }
GossipStateChangeLogTest >> testAValueChangeIsReported [
	"From what to what, because a value that moved is worth reading only together
	with what it moved from."

	| mark |
	there localEndpointState applicationStateAt: 'type' put: #base.
	self tell: there.
	mark := self mark.
	there localEndpointState applicationStateAt: 'type' put: #account.
	self tell: there.
	self assert: ((self loggedSince: mark) anySatisfy: [ :each |
			 each includesSubstring: 'changes type' ]).
	self assert: ((self loggedSince: mark) anySatisfy: [ :each |
			 each includesSubstring: 'account' ])
]

{ #category : 'tests' }
GossipStateChangeLogTest >> testTheHeartbeatAloneIsSilent [
	"Every member moves its heartbeat every round. That is the pulse, not an event,
	and lastSeen is where it belongs."

	| mark |
	self tell: there.
	mark := self mark.
	3 timesRepeat: [
		there localEndpointState increaseHeartbeat.
		self tell: there ].
	self assertEmpty: (self loggedSince: mark)
]
