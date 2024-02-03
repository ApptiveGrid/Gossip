Class {
	#name : #GossipAckMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'digests',
		'delta'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipAckMessage >> delta [

	^ delta
]

{ #category : #accessing }
GossipAckMessage >> delta: anObject [

	delta := anObject
]

{ #category : #accessing }
GossipAckMessage >> digests [
	^ digests
]

{ #category : #accessing }
GossipAckMessage >> digests: aCollection [ 
	digests := aCollection 
]

{ #category : #initialization }
GossipAckMessage >> initialize [ 
	super initialize.
	digests := OrderedCollection new.
	delta := Dictionary new
]

{ #category : #initialization }
GossipAckMessage >> initializeFromDigests: synDigests andEndpoints: endpoints [ 
	synDigests do: [ :digest |
		(endpoints endpointStateAt: digest endpoint ifAbsent: [ nil ])
			ifNotNil: [ :endpointState |
				self 
					processDigest: digest 
					forEndpointState: endpointState ]
			ifNil: [ 
				"if endpoint is not known we need request all states from
				remote peer"
				digests add: digest fromStart ] ].  
]

{ #category : #initialization }
GossipAckMessage >> processDigest: digest forEndpointState: endpointState [
		(digest generation = endpointState generation) ifFalse: [ 
			(digest generation > endpointState generation)
				ifTrue: [  
					"remote side has been restarted so we need a complete state refresh"
					digests add: digest fromStart.
					^ self  ]
				ifFalse: [
					"our generation is more actual so we send the complete states"
					delta at: endpointState endpoint put: endpointState allStates.
					^ self ]
			].
		"if both versions match there is nothing to do"
		(digest version = endpointState maxVersion) ifFalse: [ 
			"if incoming version is larger than local version than we 
			need to acquire the delta between local and remote version"
			(digest version > endpointState maxVersion) 
				ifTrue: [ 
					"sender has newer state so we acquire the delta between local
					and remote state"
					digests add: (digest startingFrom: endpointState maxVersion).
					^ self  ]
				ifFalse: [ 
					"we have higher state version. So we generate the delta of states
					between the remote version and our local one"
					delta at: endpointState endpoint put: (endpointState applicationStatesAfterVersion: digest version) ] ] 
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> processIn: aGossiper [
	| return message |
	delta ifNotEmpty: [ 
		delta keysAndValuesDo: [ :endpoint :state |
			aGossiper endpoints endpointStateAt: endpoint overwrite: state ] ].
	return := digests collect: [ :digest |
		digest endpoint -> (aGossiper endpoints stateAt: digest endpoint) ].
	message := (aGossiper newMessage: GossipAck2Message) 
		delta: return asDictionary.
	aGossiper sendMessage: message to: sender 
	
]
