Class {
	#name : #VersionedState,
	#superclass : #Object,
	#instVars : [
		'state',
		'version'
	],
	#category : #Gossip
}

{ #category : #accessing }
VersionedState >> state [

	^ state
]

{ #category : #accessing }
VersionedState >> state: anObject [

	state := anObject
]

{ #category : #accessing }
VersionedState >> version [

	^ version
]

{ #category : #accessing }
VersionedState >> version: anObject [

	version := anObject
]
