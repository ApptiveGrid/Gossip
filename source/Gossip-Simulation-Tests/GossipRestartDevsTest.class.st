"
A member goes away and comes back, inside one run and on a real gossip protocol.

Restarting is not a network fault, so it does not belong to the router: a node that returns is the same endpoint under a new incarnation, and gossip has the generation for exactly that. #restart is the lever - it forgets what the gossiper had learned and draws a higher generation, which is all a process restart is as far as the protocol is concerned.

What this is for: half of the recovery combinations. A partition that heals and a node that comes back are the two ways a cluster gets its member list wrong, and until now only the first could be played.

Rounds are added while events are still pending, for the reason given in GossipRelayDevsTest: a component that has run out of events is scheduled at infinity, and feeding its queue from outside does not reschedule it.
"
Class {
	#name : 'GossipRestartDevsTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossA',
		'gossB',
		'network',
		'router',
		'simulation',
		'endpointA',
		'endpointB'
	],
	#category : 'Gossip-Simulation-Tests',
	#package : 'Gossip-Simulation-Tests'
}

{ #category : 'running' }
GossipRestartDevsTest >> addHost: aString with: aGossiper [

	| server |
	server := DEVSPluggableServer new
		          name: ('server' , aString) asSymbol;
		          port: 1;
		          yourself.
	network addHost: (DEVSNetworkHost new
			 name: ('host' , aString) asSymbol;
			 address: aString;
			 addServer: server;
			 yourself).
	server onIncomingDo: [ :message :srv |
		aGossiper
			received: message payload
			from: (GossipEndpoint
					 address: #[ 127 0 0 1 ]
					 port: message sourceAddress asInteger).
		nil ].
	^ server
]

{ #category : 'running' }
GossipRestartDevsTest >> generationOfAAt: aGossiper [

	^ (aGossiper endpoints endpointStateAt: endpointA ifAbsent: [ ^ nil ])
		  generation
]

{ #category : 'running' }
GossipRestartDevsTest >> gossiperOn: aPort [

	| gossiper |
	gossiper := DevsGossiper new.
	gossiper
		address: #[ 127 0 0 1 ];
		port: aPort;
		seedNodes: {
				(GossipEndpoint address: #[ 127 0 0 1 ] port: 9001).
				(GossipEndpoint address: #[ 127 0 0 1 ] port: 9002) };
		devsServer: (self addHost: aPort printString with: gossiper).
	^ gossiper
]

{ #category : 'running' }
GossipRestartDevsTest >> runRounds: aNumber from: aTick doing: aBlock [
	"One round per step, with the step number handed to the block so a test can say
	when the restart happens."

	| tick |
	tick := aTick.
	1 to: aNumber do: [ :each |
		aBlock value: each.
		gossA gossip.
		gossB gossip.
		tick := tick + 12.
		simulation runTo: tick ].
	simulation runTo: tick + 200.
	^ tick + 200
]

{ #category : 'running' }
GossipRestartDevsTest >> setUp [

	super setUp.
	network := DEVSNetwork new
		           name: #net;
		           yourself.
	router := network router: DEVSFaultInjectingNetworkRouter new.
	endpointA := GossipEndpoint address: #[ 127 0 0 1 ] port: 9001.
	endpointB := GossipEndpoint address: #[ 127 0 0 1 ] port: 9002.
	gossA := self gossiperOn: 9001.
	gossB := self gossiperOn: 9002.
	gossA stateAt: 'service.test' put: 'before'.
	gossB stateAt: 'service.test' put: 'B'.
	simulation := DEVSSimulation new
		              model: network;
		              coordinator: DEVSRootSolver new;
		              yourself
]

{ #category : 'tests' }
GossipRestartDevsTest >> testARestartIsSeenAsANewIncarnation [
	"The whole point of the generation: B held A under one number and holds it under
	a higher one afterwards, without anyone saying so."

	| before |
	before := nil.
	self runRounds: 10 from: 0 doing: [ :round |
		round = 4 ifTrue: [
			before := self generationOfAAt: gossB.
			gossA restart.
			gossA stateAt: 'service.test' put: 'after' ] ].
	self assert: before notNil.
	self assert: (self generationOfAAt: gossB) > before
]

{ #category : 'tests' }
GossipRestartDevsTest >> testTheReturnedMemberIsOneMemberAgain [
	"Not a duplicate. The endpoint is the member's identity, so a returning image is
	the same entry - which is what makes the generation necessary in the first
	place."

	self runRounds: 10 from: 0 doing: [ :round |
		round = 4 ifTrue: [ gossA restart ] ].
	self assert: gossB endpoints keys size equals: 2.
	self assert: (gossB endpoints includesKey: endpointA)
]

{ #category : 'tests' }
GossipRestartDevsTest >> testWhatTheReturnedMemberSaysReplacesWhatWasHeld [
	"Replaced, not merged: a value the old incarnation published is gone, even
	though nobody withdrew it. That is the one way a gossip key can be taken back,
	and the reason RZNode>>announceServices can live with keys that cannot."

	self runRounds: 10 from: 0 doing: [ :round |
		round = 4 ifTrue: [
			gossA restart.
			gossA stateAt: 'service.test' put: 'after' ] ].
	self
		assert:
		((gossB endpoints endpointStateAt: endpointA) applicationStateAt:
			 'service.test') value
		equals: 'after'
]

{ #category : 'tests' }
GossipRestartDevsTest >> testWithoutARestartTheGenerationStands [
	"The counter-test, so that the one above measures the restart and not the
	passing of rounds."

	| before |
	before := nil.
	self runRounds: 10 from: 0 doing: [ :round |
		round = 4 ifTrue: [ before := self generationOfAAt: gossB ] ].
	self assert: (self generationOfAAt: gossB) equals: before
]
