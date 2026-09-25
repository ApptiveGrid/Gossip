"
An observer behind a translating gateway, against two members in front of it - Greenhouse on a laptop on the VPN, reading alpha (2026-09-25).

The gateway rewrites the observer's address to its own and lets back only answers to what passed through it. Members answer a syn at the sender it names; a syn naming nobody is answered where it came from - which here is the gateway, and so it arrives.
"
Class {
	#name : 'GossipObserverBehindNatDevsTest',
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
GossipObserverBehindNatDevsTest >> addHost: aString with: aGossiper [

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
GossipObserverBehindNatDevsTest >> runSimulationFor: ticks [

	DEVSSimulation new
		model: network;
		coordinator: DEVSRootSolver new;
		runTo: ticks
]

{ #category : 'running' }
GossipObserverBehindNatDevsTest >> setUp [

	super setUp.
	network := DEVSNetwork new
		           name: #net;
		           yourself.
	router := network router: GossipMasqueradingRouter new.
	router masquerade: '9003' as: '9100'.
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
		seedNodes: { endpointA };
		devsServer: (self addHost: '9003' with: observer).
	gossA stateAt: 'service.apptive-base' put: '10.10.0.6:3601'.
	gossB stateAt: 'service.apptive-metabase' put: '10.10.0.7:3800'.
	"the observer's question arrives late, so that the members have met - the one
	run stands in for rounds that come later. The latency is keyed on the
	translated source, the gateway"
	#( '9001' '9002' ) do: [ :each |
		router setLatencyBetween: '9100' and: each delay: 20 ]
]

{ #category : 'tests' }
GossipObserverBehindNatDevsTest >> testAnAnswerToTheNamedAddressDoesNotComeBack [
	"what happened on 2026-09-25, kept as the reason for all this: a syn that names
	the observer's own address is answered there, and that address is not
	reachable from in front of the gateway"

	gossA gossip.
	gossB gossip.
	observer
		sendMessage: (GossipSynMessage new
				 sender: endpointObserver;
				 digests: #(  );
				 yourself)
		to: endpointA.
	self runSimulationFor: 60.
	self assert: observer endpoints isEmpty
]

{ #category : 'tests' }
GossipObserverBehindNatDevsTest >> testItReadsTheTableThroughTheGateway [

	gossA gossip.
	gossB gossip.
	observer gossip.
	self runSimulationFor: 60.
	self
		assert: observer endpoints keys asSet
		equals: { endpointA. endpointB } asSet.
	self deny: (gossA endpoints includesKey: endpointObserver).
	self deny: (gossA endpoints includesKey:
			 (GossipEndpoint address: #[ 127 0 0 1 ] port: 9100))
]
