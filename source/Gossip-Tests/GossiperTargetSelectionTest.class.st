"
Whom a gossiper talks to in a round.

Three at random out of everything it has learned, with a seed always among them. The seeds are the way in, not the conversation - which is the whole difference to what this used to do, when an image spoke to its seeds and to nobody else however many members it knew.

No sockets and no clock here: the endpoint table is filled by hand and the choice is looked at. The draw is random, so every claim about it is checked over many rounds rather than over one lucky one - with six candidates and three picked, a member that could be missed would have to be missed a hundred times in a row.
"
Class {
	#name : 'GossiperTargetSelectionTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossiper',
		'seed',
		'learned'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossiperTargetSelectionTest >> gossiperOnPort: anInteger seeds: aCollection [
	"A gossiper knows nobody, not even itself, until it first touches its own state."

	| new |
	new := Gossiper new
		       address: #[ 127 0 0 1 ];
		       port: anInteger;
		       seedNodes: aCollection;
		       yourself.
	new localEndpointState.
	^ new
]

{ #category : 'running' }
GossiperTargetSelectionTest >> rounds [
	"One draw proves nothing about a random choice."

	^ (1 to: 100) collect: [ :each | gossiper randomNodes ]
]

{ #category : 'running' }
GossiperTargetSelectionTest >> setUp [
	super setUp.
	seed := GossipEndpoint address: #[ 127 0 0 1 ] port: 9100.
	gossiper := self gossiperOnPort: 9001 seeds: { seed }.
	learned := (1 to: 5) collect: [ :each |
		           GossipEndpoint address: #[ 127 0 0 1 ] port: 9200 + each ].
	learned do: [ :each | gossiper endpoints newEndpointStateFor: each ]
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testASeedIsAlwaysAmongThem [
	"What carries a returning image back into a cluster: however the draw falls,
	one of the three is a seed."

	self rounds do: [ :each |
		self assert: (each includes: seed) ]
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testAloneItTalksToNobody [
	"Its own entry is not somebody to talk to, and a seed list that names only
	itself leaves it with nobody - which is the truth about a cluster of one."

	| alone |
	alone := self gossiperOnPort: 9100 seeds: { seed }.
	self assert: alone randomNodes isEmpty
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testBeforeAnythingIsLearnedItTalksToItsSeeds [
	"The way in: with an empty endpoint table the seeds are the only candidates
	there are, and without this a fresh image would never speak to anyone."

	| fresh |
	fresh := self gossiperOnPort: 9002 seeds: { seed }.
	self assert: fresh randomNodes asArray equals: (Array with: seed)
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testDrawsFromWhatItLearned [
	"The point of the change: members that are in no seed list are spoken to."

	| seen |
	seen := Set new.
	self rounds do: [ :each | seen addAll: each ].
	self assert: (learned allSatisfy: [ :each | seen includes: each ])
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testNeverTalksToItself [

	self rounds do: [ :each |
		self deny: (each includes: gossiper localEndpoint) ]
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testNobodyTwiceInOneRound [

	self rounds do: [ :each |
		self assert: each asSet size equals: each size ]
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testTalksToThreeOfThem [
	"Flat cost per round: six candidates here, and three of them are spoken to -
	the same three it would be with sixty."

	self rounds do: [ :each |
		self assert: each size equals: gossiper gossipTargetCount ]
]

{ #category : 'tests' }
GossiperTargetSelectionTest >> testWithoutSeedsItStillTalksToWhatItLearned [
	"A seed list is where to start, not a condition for speaking at all."

	gossiper seedNodes: #(  ).
	self rounds do: [ :each |
		self assert: each size equals: gossiper gossipTargetCount.
		self assert: (each allSatisfy: [ :endpoint | learned includes: endpoint ]) ]
]
