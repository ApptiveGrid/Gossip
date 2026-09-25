"
Three members with a hole in the middle: A and C cannot reach each other at all, B talks to both. Everything C ever learns about A has been relayed.

This is the setup that showed the counter bug. A arrived at C exactly once, through the proactive half of a syn - B hands over everything the sender did not mention - and after that C had A in its digests, so the two compared counters instead. B's copy of A reported version 1 however far A had really come, C's said the same, and both concluded there was nothing to send. Since the counter follows the content, the relay keeps carrying.

With three members every gossiper talks to both others in every round - #gossipTargetCount is three and there are only two candidates - so nothing here depends on which ones chance picks.

Rounds have to overlap in simulated time, which is why they are not all issued before the run: queued at one instant they drain in lock-step - every syn of the whole run is handled before the first ack - and B answers C's syns while it has not yet heard of A itself. So a couple of rounds are preloaded and one more is added at every step, which also has to happen *while events are still pending*: a DEVS component that has run out of events is scheduled at infinity, and a message put into its queue from outside the model does not reschedule it.
"
Class {
	#name : 'GossipRelayDevsTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossA',
		'gossB',
		'gossC',
		'network',
		'router',
		'simulation',
		'endpointA'
	],
	#category : 'Gossip-Simulation-Tests',
	#package : 'Gossip-Simulation-Tests'
}

{ #category : 'running' }
GossipRelayDevsTest >> addHost: aString with: aGossiper [

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
GossipRelayDevsTest >> gossipRounds: aNumber [

	2 timesRepeat: [ self oneRound ].
	1 to: aNumber do: [ :each |
		simulation runTo: each * 12.
		self oneRound ].
	simulation runTo: aNumber * 12 + 200
]

{ #category : 'running' }
GossipRelayDevsTest >> gossiperOn: aPort [

	| gossiper |
	gossiper := DevsGossiper new.
	gossiper
		address: #[ 127 0 0 1 ];
		port: aPort;
		seedNodes: {
				(GossipEndpoint address: #[ 127 0 0 1 ] port: 9001).
				(GossipEndpoint address: #[ 127 0 0 1 ] port: 9002).
				(GossipEndpoint address: #[ 127 0 0 1 ] port: 9003) };
		devsServer: (self addHost: aPort printString with: gossiper).
	"Every member publishes something, as a deployed one does. Not decoration:
	GossipEndpoints>>endpointStateAt:overwrite: drops a state it considers empty, and
	a member that has announced nothing is exactly that - so without this nobody is
	relayed at all and the test would be measuring the wrong silence."
	gossiper stateAt: 'service.test' put: 'host:' , aPort printString.
	^ gossiper
]

{ #category : 'running' }
GossipRelayDevsTest >> knownVersionOfAAt: aGossiper [
	"What that image believes A's heartbeat stands at, or nil while it has never
	heard of A at all."

	^ (aGossiper endpoints endpointStateAt: endpointA ifAbsent: [ ^ nil ])
		  heartbeatState version
]

{ #category : 'running' }
GossipRelayDevsTest >> oneRound [

	gossA gossip.
	gossB gossip.
	gossC gossip
]

{ #category : 'running' }
GossipRelayDevsTest >> setUp [

	super setUp.
	network := DEVSNetwork new
		           name: #net;
		           yourself.
	router := network router: DEVSFaultInjectingNetworkRouter new.
	endpointA := GossipEndpoint address: #[ 127 0 0 1 ] port: 9001.
	gossA := self gossiperOn: 9001.
	gossB := self gossiperOn: 9002.
	gossC := self gossiperOn: 9003.
	"The hole: A and C never exchange a message, in either direction."
	router simulateNetworkPartition: '9001' and: '9003'.
	simulation := DEVSSimulation new
		              model: network;
		              coordinator: DEVSRootSolver new;
		              yourself
]

{ #category : 'tests' }
GossipRelayDevsTest >> testARelayedHeartbeatKeepsCounting [
	"The bug in one assertion. C hears of A through B and used to stop there: with
	the counter left behind, B's copy of A reported an old version, C's digest
	reported the same, and the two agreed there was nothing to send.

	Measured on this very setup with the old #applyChangesTo: in place: A at 16, C
	stuck at 9, and the gap grows with every further round. Hence keeping up rather
	than merely moving - a gap of one is the relay hop."

	self gossipRounds: 12.
	self assert: (self knownVersionOfAAt: gossC) notNil.
	self
		assert: gossA localEndpointState heartbeatState version
			- (self knownVersionOfAAt: gossC) <= 1
]

{ #category : 'tests' }
GossipRelayDevsTest >> testCHearsOfAAtAll [
	"The relay itself, which worked before and has to keep working: A is unreachable
	for C, and C knows it anyway."

	self gossipRounds: 12.
	self assert: (gossC endpoints includesKey: endpointA)
]

{ #category : 'tests' }
GossipRelayDevsTest >> testTheHoleIsReal [
	"That the two really cannot reach each other, in either direction - otherwise
	nothing here would say anything about relaying."

	self gossipRounds: 12.
	self assert: (router isPartitionedFrom: '9001' to: '9003').
	self assert: (router isPartitionedFrom: '9003' to: '9001')
]
