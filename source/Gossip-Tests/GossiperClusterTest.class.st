Class {
	#name : #GossiperClusterTest,
	#superclass : #TestCase,
	#instVars : [
		'gossipers'
	],
	#category : #'Gossip-Tests'
}

{ #category : #running }
GossiperClusterTest >> setUp [ 
	| list |
	super setUp.
	gossipers := OrderedCollection new.
	list := GossipEndpoint exampleList.
	list do: [ :endpoint |
		gossipers add: (Gossiper new 
			duration: 10 milliseconds;
			address: endpoint address; 
			port: endpoint port;
			seedNodes: (list first: 3);
			start) ].
	
]

{ #category : #running }
GossiperClusterTest >> tearDown [ 
	super tearDown.
	gossipers do: #stop
]

{ #category : #tests }
GossiperClusterTest >> testSendUpdate [
	| gossiper |
	gossiper := gossipers last.
	gossiper localEndpointState applicationStateAt: #foo put: #bar.
	300 milliSeconds wait.
	self assert: (gossipers allSatisfy: [ :g | g endpoints keys size = 5 ]).

]
