Class {
	#name : #GossiperClusterTest,
	#superclass : #TestCase,
	#instVars : [
		'gossipers'
	],
	#category : #Gossip
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
	gossiper myEndpoint stateAt: #foo put: #bar.
	gossiper gossip.
	1 seconds wait.
	
]
