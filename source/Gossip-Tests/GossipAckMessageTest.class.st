Class {
	#name : #GossipAckMessageTest,
	#superclass : #TestCase,
	#category : #'Gossip-Tests'
}

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasHigherGeneration [ 
	| localEndpoint endpoints endpointState digest ack remoteEndpoint |
	localEndpoint := GossipEndpoint example1.
	remoteEndpoint := GossipEndpoint example2.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints endpointStateAt: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation + 1 version: 3.
	ack := GossipAckMessage new
		sender: localEndpoint;
		initializeFromDigests:  { digest } andEndpoints: endpoints.
	self assert: ack digests size equals: 1.
	self assert: ack digests first version equals: 0
]

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasHigherVersion [ 
	| localEndpoint endpoints endpointState digest ack remoteEndpoint |
	localEndpoint := GossipEndpoint example1.
	remoteEndpoint := GossipEndpoint example2.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints endpointStateAt: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation version: 3.
	ack := GossipAckMessage new
		sender: localEndpoint;
		initializeFromDigests:  { digest } andEndpoints: endpoints.
	self assert: ack digests size equals: 1.
	self assert: ack digests first version equals: 2
]

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasLowerGeneration [ 
	| localEndpoint endpoints endpointState digest ack remoteEndpoint |
	localEndpoint := GossipEndpoint example1.
	remoteEndpoint := GossipEndpoint example2.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints endpointStateAt: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation - 1 version: 3.
	ack := GossipAckMessage new
		sender: localEndpoint;
		initializeFromDigests:  { digest } andEndpoints: endpoints.
	self assert: ack delta size equals: 1.
	self assert: (ack delta includesKey: localEndpoint).
	self assert: ((ack delta at: localEndpoint) at: #foo) version equals: 2
]

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasLowerVersion [ 
	| localEndpoint endpoints endpointState digest ack remoteEndpoint |
	localEndpoint := GossipEndpoint example1.
	remoteEndpoint := GossipEndpoint example2.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints endpointStateAt: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation version: 1.
	ack := GossipAckMessage new
		sender: localEndpoint;
		initializeFromDigests:  { digest } andEndpoints: endpoints.
	self assert: ack delta size equals: 1.
	self assert: (ack delta includesKey: localEndpoint).
	self assert: ((ack delta at: localEndpoint) at: #foo) version equals: 2 
]
