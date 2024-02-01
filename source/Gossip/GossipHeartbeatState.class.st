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

{ #category : #accessing }
GossipHeartbeatState >> version [

	^ version
]

{ #category : #accessing }
GossipHeartbeatState >> version: anObject [

	version := anObject
]
