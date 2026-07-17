Class {
	#name : 'GossipListValueDevsTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossA',
		'gossB',
		'gossC',
		'serverA',
		'serverB',
		'serverC',
		'network',
		'endpointA',
		'endpointB',
		'endpointC',
		'sim'
	],
	#category : 'Gossip-Simulation-Tests',
	#package : 'Gossip-Simulation-Tests'
}

{ #category : 'not defined protocol' }
GossipListValueDevsTest >> presentItemsAt: aGossiper for: anEndpoint [
	| state holder |
	state := (anEndpoint = aGossiper localEndpoint)
		ifTrue: [ aGossiper localEndpointState ]
		ifFalse: [ aGossiper endpoints endpointStateAt: anEndpoint ].
	holder := state applicationStateAt: #activeUsers ifAbsentPut: [ GossipApplicationState new ].
	^ holder value
		ifNil: [ #() ]
		ifNotNil: [ :v | v presentItems ]
]

{ #category : 'not defined protocol' }
GossipListValueDevsTest >> runSimulationFor: ticks [
	sim := DEVSSimulation new.
	sim model: network.
	sim coordinator: DEVSRootSolver new.
	sim runTo: ticks
]

{ #category : 'not defined protocol' }
GossipListValueDevsTest >> setUp [
	super setUp.
	serverA := DEVSPluggableServer new name: #serverA; port: 1; yourself.
	serverB := DEVSPluggableServer new name: #serverB; port: 1; yourself.
	serverC := DEVSPluggableServer new name: #serverC; port: 1; yourself.

	network := DEVSNetwork new name: #net.
	network addHost: (DEVSNetworkHost new name: #hostA; address: '9001'; addServer: serverA; yourself).
	network addHost: (DEVSNetworkHost new name: #hostB; address: '9002'; addServer: serverB; yourself).
	network addHost: (DEVSNetworkHost new name: #hostC; address: '9003'; addServer: serverC; yourself).

	endpointA := GossipEndpoint address: #[127 0 0 1] port: 9001.
	endpointB := GossipEndpoint address: #[127 0 0 1] port: 9002.
	endpointC := GossipEndpoint address: #[127 0 0 1] port: 9003.

	gossA := DevsGossiper new.
	gossA address: #[127 0 0 1]; port: 9001; seedNodes: { endpointA. endpointB. endpointC }; devsServer: serverA.
	gossB := DevsGossiper new.
	gossB address: #[127 0 0 1]; port: 9002; seedNodes: { endpointA. endpointB. endpointC }; devsServer: serverB.
	gossC := DevsGossiper new.
	gossC address: #[127 0 0 1]; port: 9003; seedNodes: { endpointA. endpointB. endpointC }; devsServer: serverC.

	serverA onIncomingDo: [ :message :srv |
		gossA received: message payload from: (GossipEndpoint address: #[127 0 0 1] port: message sourceAddress asInteger). nil ].
	serverB onIncomingDo: [ :message :srv |
		gossB received: message payload from: (GossipEndpoint address: #[127 0 0 1] port: message sourceAddress asInteger). nil ].
	serverC onIncomingDo: [ :message :srv |
		gossC received: message payload from: (GossipEndpoint address: #[127 0 0 1] port: message sourceAddress asInteger). nil ].
]

{ #category : 'not defined protocol' }
GossipListValueDevsTest >> testEndpointAAddPropagates [
	gossA addToList: #activeUsers item: 'user-123'.
	gossA gossip.
	self runSimulationFor: 30.
	self assert: (self presentItemsAt: gossB for: endpointA) asArray equals: #('user-123').
	self assert: (self presentItemsAt: gossC for: endpointA) asArray equals: #('user-123')
]

{ #category : 'not defined protocol' }
GossipListValueDevsTest >> testTombstoneConverges [
	gossA addToList: #activeUsers item: 'user-123'.
	gossA gossip.
	gossA removeFromList: #activeUsers item: 'user-123'.
	gossA gossip.
	self runSimulationFor: 60.
	self assert: (self presentItemsAt: gossB for: endpointA) isEmpty.
	self assert: (self presentItemsAt: gossC for: endpointA) isEmpty
]
