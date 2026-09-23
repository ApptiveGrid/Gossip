"
What happens when a neighbour comes back as a different incarnation of itself.

An image draws a new generation every time it starts, so everything it says afterwards is about a node the others thought they already knew. Gossip's answer is that the higher generation wins outright: what was held is gone and is replaced, not merged. The digest side has always done this; the delta side signalled an error instead, which is what an alpha deploy found on 2026-09-23 by restarting all five images at once.

Two gossipers, no sockets: what the far one would send is handed to the near one by hand, exactly as a delta would arrive. The restart is a second gossiper on the same endpoint with a higher generation - which is all a restart is.
"
Class {
	#name : 'GossipRestartTest',
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
GossipRestartTest >> restartOfThere [
	"What the far image is after a restart: the same endpoint, a generation drawn
	anew, and a state that counts from the beginning again."

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
GossipRestartTest >> setUp [
	super setUp.
	clock := GossipManualClock from: (DateAndTime year: 2026 month: 9 day: 23).
	here := Gossiper new
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
GossipRestartTest >> stateOfThere [
	^ here endpoints endpointStateAt: thereEndpoint ifAbsent: [ nil ]
]

{ #category : 'running' }
GossipRestartTest >> tell: aGossiper [
	"Hand over what that gossiper would send about itself."

	here endpoints applyChanges: (Dictionary new
			 at: thereEndpoint put: aGossiper localEndpointState allStates;
			 yourself)
]

{ #category : 'tests' }
GossipRestartTest >> testAnOlderIncarnationIsDropped [
	"A message about the incarnation before the restart is still travelling. It says
	nothing about the node as it is now, so nothing of it is taken."

	| restarted |
	there localEndpointState applicationStateAt: 'type' put: #before.
	restarted := self restartOfThere.
	restarted localEndpointState applicationStateAt: 'type' put: #after.
	self tell: restarted.
	self tell: there.
	self
		assert: (self stateOfThere applicationStateAt: 'type') value
		equals: #after
]

{ #category : 'tests' }
GossipRestartTest >> testARestartIsSeenAgain [
	"What Stufe 6 asks of a restart: it turns up again and 'last seen' moves
	forward. It cannot come from the version - a new incarnation counts from one
	again, so the version went down rather than up."

	| before |
	self tell: there.
	before := self stateOfThere lastSeen.
	clock advanceBy: 30 seconds.
	self tell: self restartOfThere.
	self assert: self stateOfThere lastSeen equals: before + 30 seconds
]

{ #category : 'tests' }
GossipRestartTest >> testARestartReplacesWhatWasHeld [
	"The state before the restart is gone with the image that held it. What a
	restarted neighbour says about itself is the whole truth about it, and nothing
	of the old incarnation survives underneath."

	there localEndpointState applicationStateAt: 'gone' put: #yes.
	self tell: there.
	self tell: self restartOfThere.
	self
		assert: (self stateOfThere applicationStateAt: 'gone' ifAbsent: [ nil ])
		equals: nil
]

{ #category : 'tests' }
GossipRestartTest >> testARestartTakesTheNewGeneration [
	"It used to signal 'generation mismatch' here, which cost the delta and wrote a
	walkback into the log of every neighbour on every restart."

	| restarted |
	self tell: there.
	restarted := self restartOfThere.
	self tell: restarted.
	self
		assert: self stateOfThere generation
		equals: restarted localEndpointState generation
]

{ #category : 'tests' }
GossipRestartTest >> testTheSameIncarnationIsStillMerged [
	"Inside one generation nothing changes: the higher version wins, and a state
	that is merely repeated does not count as a sign of life."

	| before |
	there localEndpointState applicationStateAt: 'type' put: #base.
	self tell: there.
	before := self stateOfThere lastSeen.
	clock advanceBy: 30 seconds.
	there localEndpointState increaseHeartbeat.
	self tell: there.
	self assert: self stateOfThere lastSeen equals: before + 30 seconds.
	self
		assert: (self stateOfThere applicationStateAt: 'type') value
		equals: #base
]
