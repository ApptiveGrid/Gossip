"
Whom an observer asks, and what it keeps of its own - which is nothing.

No sockets and no clock: the sends are kept by TestGossipObserver, and an answer is handed in by hand. That an observer actually receives the table, and stays out of every member's, is shown in GossipObserverDevsTest, where real gossipers answer.
"
Class {
	#name : 'GossipObserverTest',
	#superclass : 'TestCase',
	#instVars : [
		'observer',
		'seedA',
		'seedB'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipObserverTest >> answerFrom: anEndpoint [
	"An empty ack, which is what a node that knows nothing new sends."

	observer
		receivedMessage: (GossipAckMessage new
				 sender: anEndpoint;
				 yourself)
		from: anEndpoint
]

{ #category : 'running' }
GossipObserverTest >> observerWithSeeds: aCollection [

	^ TestGossipObserver new
		  address: #[ 127 0 0 1 ];
		  port: 9003;
		  seedNodes: aCollection;
		  yourself
]

{ #category : 'running' }
GossipObserverTest >> setUp [

	super setUp.
	seedA := GossipEndpoint address: #[ 127 0 0 1 ] port: 9001.
	seedB := GossipEndpoint address: #[ 127 0 0 1 ] port: 9002.
	observer := self observerWithSeeds: {
			            seedA.
			            seedB }
]

{ #category : 'tests' }
GossipObserverTest >> testAloneItAsksNobody [

	observer := self observerWithSeeds: #(  ).
	observer gossip.
	self assert: observer sentMessages isEmpty
]

{ #category : 'tests' }
GossipObserverTest >> testAsksOneNodeARound [
	"No fan-out: the question is whether it hears from the cluster, not whether
	the cluster hears from it."

	observer gossip.
	self assert: observer sentSyns size equals: 1.
	self assert: ({ seedA. seedB } includes: observer node)
]

{ #category : 'tests' }
GossipObserverTest >> testFirstSynAsksForEverything [
	"Nothing known means an empty digest, and to an empty digest a node answers
	with every endpoint it holds. The node answers to the sender the syn names,
	which has no reader of its own - hence instVarNamed:."

	| syn |
	observer gossip.
	syn := observer sentSyns first key.
	self assert: syn digests isEmpty.
	self
		assert: (syn instVarNamed: #sender)
		equals: observer localEndpoint
]

{ #category : 'tests' }
GossipObserverTest >> testHasNoEntryOfItsOwn [
	"The one thing that would make it a member. A gossiper creates its entry on
	its first round; an observer never does, and refuses to."

	observer gossip.
	self assert: observer endpoints isEmpty.
	self should: [ observer localEndpointState ] raise: Error
]

{ #category : 'tests' }
GossipObserverTest >> testLearnedNodesAreAsked [
	"The seeds are the way in; once the table is filled, any member is a node to
	read from - which is what lets it move on when both seeds are gone."

	| learned |
	learned := GossipEndpoint address: #[ 127 0 0 1 ] port: 9004.
	observer endpoints newEndpointStateFor: learned.
	self assert: (observer candidateNodes includes: learned).
	self deny: (observer candidateNodes includes: observer localEndpoint)
]

{ #category : 'tests' }
GossipObserverTest >> testMovesOnWhenTheNodeDoesNotAnswer [

	| first |
	observer gossip.
	first := observer node.
	observer gossip.
	self deny: observer node equals: first.
	self assert: observer sentSyns last value equals: observer node
]

{ #category : 'tests' }
GossipObserverTest >> testStaysWithANodeThatAnswers [

	| first |
	observer gossip.
	first := observer node.
	self answerFrom: first.
	observer gossip.
	self assert: observer node equals: first.
	self assert: (observer sentSyns collect: #value) asArray equals: {
			first.
			first }
]

{ #category : 'tests' }
GossipObserverTest >> testWithOneWayInItKeepsAsking [
	"Silence from the only node there is, is no reason to stop asking it."

	observer := self observerWithSeeds: { seedA }.
	observer gossip.
	observer gossip.
	self assert: (observer sentSyns collect: #value) asArray equals: {
			seedA.
			seedA }
]
