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
	gossiper myEndpoint applicationStateAt: #foo put: #bar.
	gossiper gossip.
	10 milliSeconds wait.
	gossipers do: #gossip.
	10 milliSeconds wait.
	self assert: (gossipers noneSatisfy: [ :g | g endpoints isEmpty ]).
]
