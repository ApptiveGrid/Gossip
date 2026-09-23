Class {
	#name : 'GossipHeartbeatState',
	#superclass : 'Object',
	#instVars : [
		'generation',
		'version'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
GossipHeartbeatState >> generation [

	^ generation
]

{ #category : 'accessing' }
GossipHeartbeatState >> generation: anObject [

	generation := anObject
]

{ #category : 'printing' }
GossipHeartbeatState >> printOn: aStream [ 
	aStream << 'heartbeat state: ' << generation printString << ':' << version printString
]

{ #category : 'as yet unclassified' }
GossipHeartbeatState >> updateFrom: aGossipHeartbeatState [
	"Two heartbeats of one and the same incarnation, merged: the higher version
	wins. Which incarnation this is was decided before we got here, by
	GossipEndpoints>>apply:to: - a heartbeat knows about counting, not about
	restarts, and it used to signal 'generation mismatch' for a case it could not
	decide."

	generation ifNil: [ generation := aGossipHeartbeatState generation ].
	version <= aGossipHeartbeatState version ifTrue: [
		version := aGossipHeartbeatState version ]
]

{ #category : 'accessing' }
GossipHeartbeatState >> version [

	^ version
]

{ #category : 'accessing' }
GossipHeartbeatState >> version: anObject [

	version := anObject
]
