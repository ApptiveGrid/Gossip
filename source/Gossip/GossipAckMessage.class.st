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
GossipAckMessage >> digests: aCollection [ 
	digests := aCollection 
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> processIn: aGossiper for: anEndpoint [ 
	| return message |
	delta ifNotEmpty: [ 
		delta keysAndValuesDo: [ :endpoint :state |
			aGossiper endpoints at: endpoint overwrite: state ] ].
	return := digests collect: [ :digest |
		digest endpoint -> (aGossiper endpoints stateAt: digest endpoint) ].
	message := GossipAck2Message new 
		sender: aGossiper endpoint;
		states: return asDictionary.
	aGossiper sendMessage: message to: sender 
	
]
