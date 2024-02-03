Class {
	#name : #GossipAck2MessageTest,
	#superclass : #TestCase,
	#category : #'Gossip-Tests'
}

{ #category : #tests }
GossipAck2MessageTest >> testRemoteHasOtherState [
	| localEndpoint endpoints ack remoteEndpoint ack2 |
	remoteEndpoint := GossipEndpoint example1.
	localEndpoint := GossipEndpoint example2.
	endpoints := GossipEndpoints new.
	ack := GossipAckMessage new
		sender: remoteEndpoint;
		delta: {
			remoteEndpoint -> (GossipEndpointState new 
				applicationStateAt: #foo put: #bar) allStates } asDictionary .
	ack2 := GossipAck2Message new
		sender: localEndpoint.
	endpoints processAckMessage: ack for: ack2.
	self assert: ack2 delta size equals: 0.
	self assert: ((endpoints endpointStateAt: remoteEndpoint) applicationStateAt: #foo) version equals: 2

]

{ #category : #tests }
GossipAck2MessageTest >> testRemoteNeedsAllStates [
	| localEndpoint endpoints endpointState ack remoteEndpoint ack2 |
	remoteEndpoint := GossipEndpoint example1.
	localEndpoint := GossipEndpoint example2.
	endpoints := GossipEndpoints new.
	ack := GossipAckMessage new
		sender: remoteEndpoint;
		digests: { remoteEndpoint generation: 4321 version: 0 }.
	endpointState := (endpoints newEndpointStateFor: remoteEndpoint)
		generation: 4321;
		applicationStateAt: #foo put: #bar;
		yourself.
	ack2 := GossipAck2Message new
		sender: localEndpoint.
	endpoints processAckMessage: ack for: ack2.
	self assert: ack2 delta size equals: 1.
	self assert: (ack2 delta at: remoteEndpoint) applicationStates values first version equals: 2
]

{ #category : #tests }
GossipAck2MessageTest >> testRemoteNeedsDeltaStates [
	| localEndpoint endpoints endpointState ack remoteEndpoint ack2 |
	remoteEndpoint := GossipEndpoint example1.
	localEndpoint := GossipEndpoint example2.
	endpoints := GossipEndpoints new.
	ack := GossipAckMessage new
		sender: remoteEndpoint;
		digests: { remoteEndpoint generation: 4321 version: 3 }.
	endpointState := (endpoints newEndpointStateFor: remoteEndpoint)
		generation: 4321;
		applicationStateAt: #one put: 1;
		applicationStateAt: #two put: 2;
		applicationStateAt: #three put: 3;
		applicationStateAt: #four put: 4;
		applicationStateAt: #five put: 5;
		
		yourself.
	ack2 := GossipAck2Message new
		sender: localEndpoint.
	endpoints processAckMessage: ack for: ack2.
	self assert: ack2 delta size equals: 1.
	self assert: (ack2 delta at: remoteEndpoint) applicationStates size equals: 3.

]
