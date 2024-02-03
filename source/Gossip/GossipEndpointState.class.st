Class {
	#name : #GossipEndpointState,
	#superclass : #Object,
	#instVars : [
		'heartbeatState',
		'applicationStates',
		'maxVersion',
		'endpoint'
	],
	#category : #Gossip
}

{ #category : #'as yet unclassified' }
GossipEndpointState >> allStates [
	^ GossipEndpointStateDelta new
		heartbeatState: heartbeatState;
		applicationStates: applicationStates 

]

{ #category : #accessing }
GossipEndpointState >> applicationStateAt: aString [ 
	^ applicationStates 
		at: aString 
		ifAbsent: [ KeyNotFound signal: 'state ', aString printString, ' not found' ]
]

{ #category : #accessing }
GossipEndpointState >> applicationStateAt: aString ifAbsentPut: aBlock [
	^ applicationStates 
		at: aString 
		ifAbsentPut: aBlock
]

{ #category : #accessing }
GossipEndpointState >> applicationStateAt: aString put: anObject [	
	| valueHolder |
	valueHolder  := applicationStates 
		at: aString 
		ifAbsentPut: [ GossipApplicationState new ].
	valueHolder setValue: anObject endpointState: self
]

{ #category : #'as yet unclassified' }
GossipEndpointState >> applicationStatesAfterVersion: anInteger [ 
	^ GossipEndpointStateDelta new
		heartbeatState: heartbeatState;
		applicationStates: (applicationStates associations 
			select: [ :assoc | assoc value version > anInteger ]) asDictionary
]

{ #category : #accessing }
GossipEndpointState >> endpoint [
	^ endpoint
]

{ #category : #accessing }
GossipEndpointState >> endpoint: aGossipEndpoint [ 
	endpoint := aGossipEndpoint 
]

{ #category : #accessing }
GossipEndpointState >> generation [
	^ self heartbeatState generation
]

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

{ #category : #printing }
GossipEndpointState >> printOn: aStream [ 
	aStream << 'endpoint state: ' << endpoint printString << ', maxVersion: ' << maxVersion printString
]
