Class {
	#name : #GossipDigest,
	#superclass : #Object,
	#instVars : [
		'endpoint',
		'generation',
		'maxVersion'
	],
	#category : #Gossip
}

{ #category : #'instance creation' }
GossipDigest class >> endpoint: aGossipEndpoint generation: generation version: version [ 
	^ self new 
		endpoint: aGossipEndpoint;
		generation: generation;
		maxVersion: version
]

{ #category : #'as yet unclassified' }
GossipDigest class >> exampleList [
	^ (1 to: 5) collect: [ :n | 
		 GossipDigest 
			endpoint: (GossipEndpoint address: { 1 . 2 . 3 . n } asByteArray port: 1000 + n)
				generation: n 
				version: n ]
]

{ #category : #'as yet unclassified' }
GossipDigest >> compareTo: aGossipDigest [ 
	(endpoint = aGossipDigest endpoint) ifFalse: [ Error signal: 'different endpoints' ].
	^ (generation = aGossipDigest generation)
		ifTrue: [ maxVersion - aGossipDigest maxVersion ]
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

{ #category : #accessing }
GossipDigest >> generation [
	^ generation
]

{ #category : #accessing }
GossipDigest >> generation: anInteger [ 
	generation := anInteger 
]

{ #category : #accessing }
GossipDigest >> maxVersion [
	^ maxVersion
]

{ #category : #versions }
GossipDigest >> maxVersion: anInteger [ 
	maxVersion := anInteger 
]

{ #category : #printing }
GossipDigest >> printOn: aStream [ 
	aStream << 'digest: '.
	endpoint printOn: aStream.
	aStream << '/' << generation asString << '/' << maxVersion asString
]
