Class {
	#name : 'GossipDevsHardeningTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossA',
		'gossB',
		'serverA',
		'serverB',
		'network',
		'endpointA',
		'endpointB',
		'sim'
	],
	#category : 'Gossip-Simulation-Tests',
	#package : 'Gossip-Simulation-Tests'
}

{ #category : 'not defined protocol' }
GossipDevsHardeningTest >> runSimulationFor: ticks [
	sim := DEVSSimulation new.
	sim model: network.
	sim coordinator: DEVSRootSolver new.
	sim runTo: ticks
]

{ #category : 'not defined protocol' }
GossipDevsHardeningTest >> setUp [
	super setUp.
	serverA := DEVSPluggableServer new name: #serverA; port: 1; yourself.
	serverB := DEVSPluggableServer new name: #serverB; port: 1; yourself.

	network := DEVSNetwork new name: #net.
	network addHost: (DEVSNetworkHost new
		name: #hostA;
		address: '9001';
		addServer: serverA;
		yourself).
	network addHost: (DEVSNetworkHost new
		name: #hostB;
		address: '9002';
		addServer: serverB;
		yourself).

	endpointA := GossipEndpoint address: #[127 0 0 1] port: 9001.
	endpointB := GossipEndpoint address: #[127 0 0 1] port: 9002.

	gossA := DevsGossiper new.
	gossA address: #[127 0 0 1]; port: 9001; seedNodes: { endpointA. endpointB }; devsServer: serverA.
	gossB := DevsGossiper new.
	gossB address: #[127 0 0 1]; port: 9002; seedNodes: { endpointA. endpointB }; devsServer: serverB.

	serverA onIncomingDo: [ :message :srv |
		gossA received: message payload from: (GossipEndpoint address: #[127 0 0 1] port: message sourceAddress asInteger).
		nil ].
	serverB onIncomingDo: [ :message :srv |
		gossB received: message payload from: (GossipEndpoint address: #[127 0 0 1] port: message sourceAddress asInteger).
		nil ].
]

{ #category : 'not defined protocol' }
GossipDevsHardeningTest >> testApplicationStateValuePropagates [
	gossA localEndpointState applicationStateAt: #foo put: #bar.
	gossA gossip.
	gossB gossip.
	self runSimulationFor: 30.
	self assert: ((gossB endpoints endpointStateAt: endpointA) applicationStateAt: #foo) value equals: #bar
]

{ #category : 'not defined protocol' }
GossipDevsHardeningTest >> testEndpointsConverge [
	gossA gossip.
	gossB gossip.
	self runSimulationFor: 30.
	self assert: (gossA endpoints includesKey: endpointB).
	self assert: (gossB endpoints includesKey: endpointA)
]
