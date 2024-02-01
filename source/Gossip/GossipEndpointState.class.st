Class {
	#name : #GossipEndpointState,
	#superclass : #Object,
	#instVars : [
		'heartbeatState',
		'applicationStates',
		'maxVersion'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipEndpointState >> generation: anInteger [ 
	heartbeatState generation: anInteger 
]

{ #category : #accessing }
GossipEndpointState >> heartbeatState [
	^ heartbeatState
]

{ #category : #initialization }
GossipEndpointState >> initialize [ 
	super initialize.
	applicationStates := Dictionary new.
	maxVersion := 0.
	heartbeatState := GossipHeartbeatState new
		version: self nextVersion
]

{ #category : #testing }
GossipEndpointState >> isEmpty [
	^ applicationStates isEmpty
]

{ #category : #accessing }
GossipEndpointState >> maxVersion [
	^ maxVersion 
]

{ #category : #utilities }
GossipEndpointState >> nextVersion [
	^ maxVersion := maxVersion + 1
]

{ #category : #accessing }
GossipEndpointState >> stateAt: aString [ 
	^ applicationStates 
		at: aString 
		ifAbsent: [ KeyNotFound signal: 'state ', aString printString, ' not found' ]
]

{ #category : #accessing }
GossipEndpointState >> stateAt: aString ifAbsentPut: aBlock [
	^ applicationStates 
		at: aString 
		ifAbsentPut: aBlock
]

{ #category : #accessing }
GossipEndpointState >> stateAt: aString put: anObject [	
	| valueHolder |
	valueHolder  := applicationStates 
		at: aString 
		ifAbsentPut: [ GossipApplicationState new ].
	valueHolder setValue: anObject endpointState: self
]
