Class {
	#name : #GossipHeartbeatState,
	#superclass : #Object,
	#instVars : [
		'generation',
		'version'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipHeartbeatState >> generation [

	^ generation
]

{ #category : #accessing }
GossipHeartbeatState >> generation: anObject [

	generation := anObject
]

{ #category : #printing }
GossipHeartbeatState >> printOn: aStream [ 
	aStream << 'heartbeat state: ' << generation printString << ':' << version printString
]

{ #category : #'as yet unclassified' }
GossipHeartbeatState >> updateFrom: aGossipHeartbeatState [ 
	generation
		ifNotNil: [ (generation = aGossipHeartbeatState generation) ifFalse: [ Error signal: 'generation mismatch' ] ] 
		ifNil:[ 
			Transcript show: 'updating heartbeat to ', aGossipHeartbeatState generation printString ; cr.
			generation := aGossipHeartbeatState generation ].
	(version <= aGossipHeartbeatState version)
		ifTrue: [ version := aGossipHeartbeatState version ]
		ifFalse: [  ]
	
]

{ #category : #accessing }
GossipHeartbeatState >> version [

	^ version
]

{ #category : #accessing }
GossipHeartbeatState >> version: anObject [

	version := anObject
]
