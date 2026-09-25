Class {
	#name : 'GossipEndpointState',
	#superclass : 'Object',
	#instVars : [
		'heartbeatState',
		'applicationStates',
		'maxVersion',
		'endpoint',
		'lastSeen'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'as yet unclassified' }
GossipEndpointState >> allStates [
	^ GossipEndpointStateDelta new
		heartbeatState: heartbeatState;
		applicationStates: applicationStates 

]

{ #category : 'accessing' }
GossipEndpointState >> applicationStateAt: aString [ 
	^ applicationStates 
		at: aString 
		ifAbsent: [ KeyNotFound signal: 'state ', aString printString, ' not found' ]
]

{ #category : 'accessing' }
GossipEndpointState >> applicationStateAt: aString ifAbsentPut: aBlock [
	^ applicationStates 
		at: aString 
		ifAbsentPut: aBlock
]

{ #category : 'accessing' }
GossipEndpointState >> applicationStateAt: aString overwrite: anObject [	
	applicationStates 
		at: aString 
		put: anObject

	
]

{ #category : 'accessing' }
GossipEndpointState >> applicationStateAt: aString put: anObject [	
	| valueHolder |
	valueHolder  := applicationStates 
		at: aString 
		ifAbsentPut: [ GossipApplicationState new ].
	valueHolder setValue: anObject endpointState: self
]

{ #category : 'as yet unclassified' }
GossipEndpointState >> applicationStatesAfterVersion: anInteger [ 
	^ GossipEndpointStateDelta new
		heartbeatState: heartbeatState;
		applicationStates: (applicationStates associations 
			select: [ :assoc | assoc value version > anInteger ]) asDictionary
]

{ #category : 'accessing' }
GossipEndpointState >> catchUpVersionTo: anInteger [
	"Raise the counter this image reports for the endpoint to what it has actually
	seen of it.

	For the endpoint's own image the counter is a source: #nextVersion hands numbers
	out, to #increaseHeartbeat and to GossipApplicationState>>setValue:endpointState:
	alike, so one counter covers both kinds. For every other image holding a copy it
	is a *mirror*, and it only stays one if arriving state moves it along - a copy
	whose counter stands still tells the next asker there is nothing newer, and the
	delta it would have got is never requested.

	Never lowers it. Deltas arrive out of order and an older one must not undo what a
	newer one already said."

	maxVersion := maxVersion max: anInteger
]

{ #category : 'accessing' }
GossipEndpointState >> endpoint [
	^ endpoint
]

{ #category : 'accessing' }
GossipEndpointState >> endpoint: aGossipEndpoint [ 
	endpoint := aGossipEndpoint 
]

{ #category : 'accessing' }
GossipEndpointState >> generation [
	^ self heartbeatState generation
]

{ #category : 'accessing' }
GossipEndpointState >> generation: anInteger [ 
	heartbeatState generation: anInteger 
]

{ #category : 'accessing' }
GossipEndpointState >> heartbeatState [
	^ heartbeatState
]

{ #category : 'accessing' }
GossipEndpointState >> heartbeatState: aGossipHeartbeatState [ 
	heartbeatState := aGossipHeartbeatState
]

{ #category : 'as yet unclassified' }
GossipEndpointState >> increaseHeartbeat [
	self heartbeatState version: self nextVersion 
]

{ #category : 'initialization' }
GossipEndpointState >> initialize [ 
	super initialize.
	applicationStates := Dictionary new.
	maxVersion := 0.
	heartbeatState := GossipHeartbeatState new
		version: self nextVersion
]

{ #category : 'testing' }
GossipEndpointState >> isEmpty [
	^ applicationStates isEmpty
]

{ #category : 'accessing' }
GossipEndpointState >> lastSeen [
	"When this image last saw this endpoint's own heartbeat move forward, or nil
	if it never has. Purely local knowledge: it is not part of what travels, and
	two images will not answer the same thing.

	It is an observation, not a judgement - nothing here decides whether the node
	is gone. See Rhizome decisions of 2026-09-22."
	^ lastSeen
]

{ #category : 'accessing' }
GossipEndpointState >> maxVersion [
	^ maxVersion 
]

{ #category : 'utilities' }
GossipEndpointState >> nextVersion [
	^ maxVersion := maxVersion + 1
]

{ #category : 'printing' }
GossipEndpointState >> printOn: aStream [ 
	aStream << 'endpoint state: ' << endpoint printString << ', maxVersion: ' << maxVersion printString
]

{ #category : 'as yet unclassified' }
GossipEndpointState >> processDigest: digest forMessage: message [
	(digest generation = self generation) ifFalse: [ 
		(digest generation > self generation)
			ifTrue: [  
				"remote side has been restarted so we need a complete state refresh"
				"digests add: digest fromStart."
				message endpointRestartFor: digest.
				^ self  ]
			ifFalse: [
				"our generation is more actual so we send the complete states"
				"delta at: endpointState endpoint put: endpointState allStates."
				message updateEndpoint: digest endpoint with: self allStates.
				^ self ]
		].
	"if both versions match there is nothing to do"
	(digest version = self maxVersion) ifFalse: [ 
		"if incoming version is larger than local version than we 
		need to acquire the delta between local and remote version"
		(digest version > self maxVersion) 
			ifTrue: [ 
				"sender has newer state so we acquire the delta between local
				and remote state"
				"digests add: (digest startingFrom: endpointState maxVersion)."
				message requestUpdatesFrom: digest since: self maxVersion.
				^ self  ]
			ifFalse: [ 
				"we have higher state version. So we generate the delta of states
				between the remote version and our local one"
				"delta at: endpointState endpoint put: (endpointState applicationStatesAfterVersion: digest version)"
				message updateEndpoint: digest endpoint with: (self applicationStatesAfterVersion: digest version) ] ] 
]

{ #category : 'accessing' }
GossipEndpointState >> seenAt: aTime [
	lastSeen := aTime
]
