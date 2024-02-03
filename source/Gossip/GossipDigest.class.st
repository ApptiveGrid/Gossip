Class {
	#name : #GossipDigest,
	#superclass : #Object,
	#instVars : [
		'endpoint',
		'generation',
		'version'
	],
	#category : #Gossip
}

{ #category : #'instance creation' }
GossipDigest class >> endpoint: aGossipEndpoint generation: generation version: version [ 
	^ self new 
		endpoint: aGossipEndpoint;
		generation: generation;
		version: version
]

{ #category : #'as yet unclassified' }
GossipDigest class >> exampleList [
	<example>
	^ GossipEndpoint exampleList collect: [ :endpoint | 
		 GossipDigest 
			endpoint: endpoint
			generation: 1
			version: 1 ]
]

{ #category : #'as yet unclassified' }
GossipDigest >> compareTo: aGossipDigest [ 
	(endpoint = aGossipDigest endpoint) ifFalse: [ Error signal: 'different endpoints' ].
	^ (generation = aGossipDigest generation)
		ifTrue: [ version - aGossipDigest version ]
		ifFalse: [ generation - aGossipDigest generation ]
]

{ #category : #accessing }
GossipDigest >> endpoint [
	^ endpoint
]

{ #category : #accessing }
GossipDigest >> endpoint: aGossipEndpoint [ 
	endpoint := aGossipEndpoint 
]

{ #category : #'instance creation' }
GossipDigest >> fromStart [
	^ self startingFrom: 0
]

{ #category : #accessing }
GossipDigest >> generation [
	^ generation
]

{ #category : #accessing }
GossipDigest >> generation: anInteger [ 
	generation := anInteger 
]

{ #category : #printing }
GossipDigest >> printOn: aStream [ 
	aStream << 'digest: '.
	endpoint printOn: aStream.
	aStream << '/' << generation asString << '/' << version asString
]

{ #category : #'as yet unclassified' }
GossipDigest >> startingFrom: anInteger [ 
	^ self class new 
		endpoint: endpoint;
		generation: generation;
		version: anInteger
]

{ #category : #accessing }
GossipDigest >> version [
	^ version
]

{ #category : #versions }
GossipDigest >> version: anInteger [ 
	version := anInteger 
]
