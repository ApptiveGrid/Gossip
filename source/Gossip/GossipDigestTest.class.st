Class {
	#name : #GossipDigestTest,
	#superclass : #TestCase,
	#category : #Gossip
}

{ #category : #tests }
GossipDigestTest >> testDifferentEndpoints [
 	| digest1 digest2 |
	digest1 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 100.
	digest2 := GossipDigest endpoint: GossipEndpoint example2 generation: 1 version: 100.
	self should: [ digest1 compareTo: digest2 ] raise: Error
]

{ #category : #tests }
GossipDigestTest >> testEqual [ 
 	| digest1 digest2 |
	digest1 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 100.
	digest2 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 100.
	self assert: (digest1 compareTo: digest2) equals: 0
]

{ #category : #tests }
GossipDigestTest >> testLargerGeneration [ 
 	| digest1 digest2 |
	digest1 := GossipDigest endpoint: GossipEndpoint example1 generation: 2 version: 100.
	digest2 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 100.
	self assert: (digest1 compareTo: digest2) equals: 1
]

{ #category : #tests }
GossipDigestTest >> testLargerMaxVersion [ 
 	| digest1 digest2 |
	digest1 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 102.
	digest2 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 101.
	self assert: (digest1 compareTo: digest2) equals: 1
]

{ #category : #tests }
GossipDigestTest >> testSmallerGeneration [ 
 	| digest1 digest2 |
	digest1 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 100.
	digest2 := GossipDigest endpoint: GossipEndpoint example1 generation: 2 version: 100.
	self assert: (digest1 compareTo: digest2) equals: -1
]

{ #category : #tests }
GossipDigestTest >> testSmallerMaxVersion [ 
 	| digest1 digest2 |
	digest1 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 100.
	digest2 := GossipDigest endpoint: GossipEndpoint example1 generation: 1 version: 101.
	self assert: (digest1 compareTo: digest2) equals: -1
]
