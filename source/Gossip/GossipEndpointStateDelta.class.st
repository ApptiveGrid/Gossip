Class {
	#name : #GossipEndpointStateDelta,
	#superclass : #Object,
	#instVars : [
		'heartbeatState',
		'applicationStates'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipEndpointStateDelta >> applicationStateAt: aString [ 
	^ applicationStates 
		at: aString 
		ifAbsent: [ KeyNotFound signal: 'state ', aString printString, ' not found' ]
]

{ #category : #accessing }
GossipEndpointStateDelta >> applicationStates [
	^ applicationStates
]

{ #category : #accessing }
GossipEndpointStateDelta >> applicationStates: aCollection [ 
	applicationStates := aCollection
]

{ #category : #accessing }
GossipEndpointStateDelta >> generation [
	^ self heartbeatState generation
]

{ #category : #accessing }
GossipEndpointStateDelta >> generation: anInteger [ 
	heartbeatState generation: anInteger 
]

{ #category : #accessing }
GossipEndpointStateDelta >> heartbeatState [
	^ heartbeatState
]

{ #category : #accessing }
GossipEndpointStateDelta >> heartbeatState: aGossipHeartbeatState [ 
	heartbeatState := aGossipHeartbeatState
]

{ #category : #initialization }
GossipEndpointStateDelta >> initialize [ 
	super initialize.
	applicationStates := Dictionary new
]

{ #category : #testing }
GossipEndpointStateDelta >> isEmpty [
	^ applicationStates isEmpty
]
