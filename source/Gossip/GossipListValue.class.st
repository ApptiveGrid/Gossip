Class {
	#name : 'GossipListValue',
	#superclass : 'Object',
	#instVars : [
		'entries',
		'versionCounter'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'not defined protocol' }
GossipListValue >> add: anItem [
	entries at: anItem put: (Array with: true with: self nextItemVersion)
]

{ #category : 'not defined protocol' }
GossipListValue >> entries [
	^ entries
]

{ #category : 'as yet unclassified' }
GossipListValue >> gcTombstonesOlderThan: aVersionGap [
	entries := entries reject: [ :pair | 
		pair first not and: [ (versionCounter - pair second) > aVersionGap ] ]
]

{ #category : 'not defined protocol' }
GossipListValue >> includes: anItem [
	^ (entries at: anItem ifAbsent: [ ^ false ]) first
]

{ #category : 'not defined protocol' }
GossipListValue >> initialize [
	super initialize.
	entries := Dictionary new.
	versionCounter := 0
]

{ #category : 'not defined protocol' }
GossipListValue >> nextItemVersion [
	versionCounter := versionCounter + 1.
	^ versionCounter
]

{ #category : 'not defined protocol' }
GossipListValue >> presentItems [
	^ (entries select: [ :pair | pair first ]) keys
]

{ #category : 'not defined protocol' }
GossipListValue >> printOn: aStream [
	aStream << 'GossipListValue(' << self presentItems asArray printString << ')'
]

{ #category : 'not defined protocol' }
GossipListValue >> remove: anItem [
	entries at: anItem put: (Array with: false with: self nextItemVersion)
]
