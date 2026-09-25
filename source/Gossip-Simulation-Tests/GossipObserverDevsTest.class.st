"
An observer against two real gossipers: it ends up holding what they hold, and neither of them ends up holding it.

The solver cannot be resumed, so every round is issued before the one run, and the observer's syns are held back by a latency on the router until the members have met.
"
Class {
	#name : 'GossipObserverDevsTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossA',
		'gossB',
		'observer',
		'network',
		'router',
		'endpointA',
		'endpointB',
		'endpointObserver'
	],
	#category : 'Gossip-Simulation-Tests',
	#package : 'Gossip-Simulation-Tests'
}

{ #category : 'running' }
GossipObserverDevsTest >> addHost: aString with: aGossiper [

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
GossipObserverDevsTest >> runSimulationFor: ticks [

	DEVSSimulation new
		model: network;
		coordinator: DEVSRootSolver new;
		runTo: ticks
]

{ #category : 'running' }
GossipObserverDevsTest >> setUp [

	super setUp.
	network := DEVSNetwork new
		           name: #net;
		           yourself.
	router := network router: DEVSFaultInjectingNetworkRouter new.
	endpointA := GossipEndpoint address: #[ 127 0 0 1 ] port: 9001.
	endpointB := GossipEndpoint address: #[ 127 0 0 1 ] port: 9002.
	endpointObserver := GossipEndpoint address: #[ 127 0 0 1 ] port: 9003.
	gossA := DevsGossiper new.
	gossB := DevsGossiper new.
	observer := GossipDevsObserver new.
	gossA
		address: #[ 127 0 0 1 ];
		port: 9001;
		seedNodes: { endpointA. endpointB };
		devsServer: (self addHost: '9001' with: gossA).
	gossB
		address: #[ 127 0 0 1 ];
		port: 9002;
		seedNodes: { endpointA. endpointB };
		devsServer: (self addHost: '9002' with: gossB).
	observer
		address: #[ 127 0 0 1 ];
		port: 9003;
		seedNodes: { endpointA. endpointB };
		devsServer: (self addHost: '9003' with: observer).
	gossA stateAt: #type put: #base.
	gossB stateAt: #type put: #metabase.
	"What the observer says arrives late, so that there is a converged table to
	read by the time it is heard - the one run has to stand in for rounds that
	come later."
	#( '9001' '9002' ) do: [ :each |
		router setLatencyBetween: '9003' and: each delay: 20 ]
]

{ #category : 'tests' }
GossipObserverDevsTest >> testItIsInNobodysTable [
	"The point of it all: the members have talked to it, and neither knows it."

	gossA gossip.
	gossB gossip.
	observer gossip.
	gossA gossip.
	gossB gossip.
	observer gossip.
	self runSimulationFor: 60.
	self assert: (observer endpoints includesKey: endpointA).
	self deny: (gossA endpoints includesKey: endpointObserver).
	self deny: (gossB endpoints includesKey: endpointObserver).
	self assert: gossA endpoints keys size equals: 2.
	self assert: gossB endpoints keys size equals: 2
]

{ #category : 'tests' }
GossipObserverDevsTest >> testItReadsTheWholeTable [
	"One node asked, both members known - with what they announce and when they
	were last seen."

	gossA gossip.
	gossB gossip.
	observer gossip.
	self runSimulationFor: 60.
	self assert: (observer endpoints keys asSet) equals: { endpointA. endpointB } asSet.
	self
		assert: ((observer endpoints endpointStateAt: endpointA) applicationStateAt: #type) value
		equals: #base.
	self
		assert: ((observer endpoints endpointStateAt: endpointB) applicationStateAt: #type) value
		equals: #metabase.
	self assert: (observer endpoints endpointStateAt: endpointA) lastSeen notNil
]

{ #category : 'tests' }
GossipObserverDevsTest >> testWhenItsNodeIsGoneItReadsFromAnother [
	"Its first node does not answer, so the next round goes elsewhere - and the
	table arrives all the same."

	| first |
	gossA gossip.
	gossB gossip.
	observer gossip.
	first := observer node.
	router
		dropNextNMessagesBetween: '9003'
		and: first port printString
		count: 100.
	observer gossip.
	self deny: observer node equals: first.
	self runSimulationFor: 60.
	self assert: (observer endpoints keys asSet) equals: { endpointA. endpointB } asSet
]
