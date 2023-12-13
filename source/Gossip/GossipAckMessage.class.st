Class {
	#name : #GossipAckMessage,
	#superclass : #GossipMessage,
	#instVars : [
		'digests'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipAckMessage >> digests: aCollection [ 
	digests := aCollection 
]

{ #category : #'as yet unclassified' }
GossipAckMessage >> processIn: aGossiper for: anEndpoint [ 
	| return message |
	return := digests collect: [ :digest |
		digest endpoint -> (aGossiper endpoints stateAt: digest endpoint) ].
	message := GossipAck2Message new 
		sender: aGossiper endpoint;
		states: return asDictionary.
	aGossiper sendMessage: message to: sender 
	
]
