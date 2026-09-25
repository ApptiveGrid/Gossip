Class {
	#name : 'GossipEndpointStateDelta',
	#superclass : 'Object',
	#instVars : [
		'heartbeatState',
		'applicationStates'
	],
	#category : 'Gossip',
	#package : 'Gossip'
}

{ #category : 'accessing' }
GossipEndpointStateDelta >> applicationStateAt: aString [ 
	^ applicationStates 
		at: aString 
		ifAbsent: [ KeyNotFound signal: 'state ', aString printString, ' not found' ]
]

{ #category : 'accessing' }
GossipEndpointStateDelta >> applicationStates [
	^ applicationStates
]

{ #category : 'accessing' }
GossipEndpointStateDelta >> applicationStates: aCollection [ 
	applicationStates := aCollection
]

{ #category : 'applying' }
GossipEndpointStateDelta >> applyChangesTo: endpointState [

	endpointState heartbeatState updateFrom: heartbeatState.
	applicationStates keysAndValuesDo: [ :key :value |
		endpointState applicationStateAt: key overwrite: value ].
	"The counter has to follow the content, or the copy lies about itself in the next
	digest - see GossipEndpointState>>catchUpVersionTo:."
	endpointState catchUpVersionTo: self highestVersion
]

{ #category : 'accessing' }
GossipEndpointStateDelta >> generation [
	^ self heartbeatState generation
]

{ #category : 'accessing' }
GossipEndpointStateDelta >> generation: anInteger [ 
	heartbeatState generation: anInteger 
]

{ #category : 'accessing' }
GossipEndpointStateDelta >> heartbeatState [
	^ heartbeatState
]

{ #category : 'accessing' }
GossipEndpointStateDelta >> heartbeatState: aGossipHeartbeatState [ 
	heartbeatState := aGossipHeartbeatState
]

{ #category : 'accessing' }
GossipEndpointStateDelta >> highestVersion [
	"How far this delta carries the endpoint's counter. Heartbeat and application
	states are numbered from the same counter, so the highest of either kind is the
	highest there is.

	Answers 0 for a delta that carries nothing numbered, which raises no counter."

	| highest |
	highest := heartbeatState
		           ifNil: [ 0 ]
		           ifNotNil: [ :each | each version ifNil: [ 0 ] ].
	applicationStates do: [ :each |
		each version ifNotNil: [ :version | highest := highest max: version ] ].
	^ highest
]

{ #category : 'initialization' }
GossipEndpointStateDelta >> initialize [ 
	super initialize.
	applicationStates := Dictionary new
]

{ #category : 'testing' }
GossipEndpointStateDelta >> isEmpty [
	^ applicationStates isEmpty
]
