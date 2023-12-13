Class {
	#name : #GossipAck2Message,
	#superclass : #GossipMessage,
	#instVars : [
		'states'
	],
	#category : #Gossip
}

{ #category : #'as yet unclassified' }
GossipAck2Message >> processIn: aGossiper for: anEndpoint [ 
	states keysAndValuesDo: [ :endpoint :s |
		aGossiper endpoints at: endpoint overwrite: s ]
]

{ #category : #accessing }
GossipAck2Message >> states [

	^ states
]

{ #category : #accessing }
GossipAck2Message >> states: anObject [

	states := anObject
]
