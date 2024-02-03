Class {
	#name : #GossipAckMessageTest,
	#superclass : #TestCase,
	#category : #'Gossip-Tests'
}

{ #category : #tests }
GossipAckMessageTest >> testLocalEndpointNotPresent [
	| localEndpoint endpoints digest ack |
	localEndpoint := GossipEndpoint example1.
	endpoints := GossipEndpoints new.
	digest := GossipDigest endpoint: localEndpoint generation: 4321 version: 3.
	ack := GossipAckMessage new
		sender: localEndpoint.
	endpoints processDigests: { digest } forMessage: ack.
	self assert: ack digests size equals: 1.
	self assert: ack digests first version equals: 0
]

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasHigherGeneration [ 
	| localEndpoint endpoints endpointState digest ack |
	localEndpoint := GossipEndpoint example1.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints newEndpointStateFor: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation + 1 version: 3.
	ack := GossipAckMessage new
		sender: localEndpoint.
	endpoints processDigest: digest forMessage: ack.
	self assert: ack digests size equals: 1.
	self assert: ack digests first version equals: 0
]

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasHigherVersion [ 
	| localEndpoint endpoints endpointState digest ack |
	localEndpoint := GossipEndpoint example1.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints newEndpointStateFor: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation version: 3.
	ack := GossipAckMessage new
		sender: localEndpoint.
	endpoints processDigest: digest forMessage: ack.
	self assert: ack digests size equals: 1.
	self assert: ack digests first version equals: 2
]

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasLowerGeneration [ 
	| localEndpoint endpoints endpointState digest ack |
	localEndpoint := GossipEndpoint example1.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints newEndpointStateFor: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation - 1 version: 3.
	ack := GossipAckMessage new
		sender: localEndpoint.
	endpoints processDigest: digest forMessage: ack.
	self assert: ack delta size equals: 1.
	self assert: (ack delta includesKey: localEndpoint).
	self assert: ((ack delta at: localEndpoint) applicationStates at: #foo) version equals: 2
]

{ #category : #tests }
GossipAckMessageTest >> testRemoteStateHasLowerVersion [ 
	| localEndpoint endpoints endpointState digest ack |
	localEndpoint := GossipEndpoint example1.
	endpoints := GossipEndpoints new.
	endpointState := (endpoints newEndpointStateFor: localEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	digest := GossipDigest endpoint: localEndpoint generation: endpointState generation version: 1.
	ack := GossipAckMessage new
		sender: localEndpoint.
	endpoints processDigest: digest forMessage: ack.
	self assert: ack delta size equals: 1.
	self assert: (ack delta includesKey: localEndpoint).
	self assert: ((ack delta at: localEndpoint) applicationStates at: #foo) version equals: 2
]
