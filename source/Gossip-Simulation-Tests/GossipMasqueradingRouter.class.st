"
A router with a translating gateway in front of one host, the way a VPN gateway masquerades its clients into the cluster's network.

What leaves the inside host gets the gateway's address as its source, and the gateway remembers whom it was sent to. What arrives for the gateway is let back in - to the inside host - only when it comes from one of those; anything else for the gateway is dropped. The inside host's own address is not reachable from outside at all.

Ports play no part: a simulated host has one server, so a flow here is a pair of addresses. What this checks is the address an answer goes to, which is what went wrong on 2026-09-25 - the cluster answered the observer at the address it named, and that address was the inside one.
"
Class {
	#name : 'GossipMasqueradingRouter',
	#superclass : 'DEVSFaultInjectingNetworkRouter',
	#instVars : [
		'inside',
		'gateway',
		'flows'
	],
	#category : 'Gossip-Simulation-Tests',
	#package : 'Gossip-Simulation-Tests'
}

{ #category : 'running' }
GossipMasqueradingRouter >> externalTransition [

	(self translate: (self peekFrom: #in)) ifFalse: [ ^ self ].
	super externalTransition
]

{ #category : 'accessing' }
GossipMasqueradingRouter >> masquerade: anInsideAddress as: aGatewayAddress [

	inside := anInsideAddress.
	gateway := aGatewayAddress.
	flows := Set new
]

{ #category : 'running' }
GossipMasqueradingRouter >> translate: aMessage [
	"true when the message goes on, rewritten where the gateway rewrites it"

	aMessage sourceAddress = inside ifTrue: [
		flows add: aMessage destinationAddress.
		aMessage sourceAddress: gateway.
		^ true ].
	aMessage destinationAddress = gateway ifTrue: [
		(flows includes: aMessage sourceAddress) ifFalse: [ ^ false ].
		aMessage destinationAddress: inside.
		^ true ].
	^ aMessage destinationAddress ~= inside
]
