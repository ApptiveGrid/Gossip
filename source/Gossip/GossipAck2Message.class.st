Class {
	#name : #GossipAck2Message,
	#superclass : #GossipMessage,
	#instVars : [
		'delta'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipAck2Message >> delta: anObject [

	delta := anObject
]

{ #category : #'as yet unclassified' }
GossipAck2Message >> processIn: aGossiper [
	delta keysAndValuesDo: [ :endpoint :s |
		aGossiper endpoints at: endpoint overwrite: s ]
]
