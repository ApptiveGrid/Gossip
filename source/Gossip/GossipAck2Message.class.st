Class {
	#name : #GossipAck2Message,
	#superclass : #GossipMessage,
	#instVars : [
		'delta'
	],
	#category : #Gossip
}

{ #category : #accessing }
GossipAck2Message >> delta [
	^ delta
]

{ #category : #accessing }
GossipAck2Message >> delta: anObject [

	delta := anObject
]

{ #category : #initialization }
GossipAck2Message >> initialize [ 
	super initialize.
	delta := Dictionary new
]

{ #category : #'as yet unclassified' }
GossipAck2Message >> processDigests: digestList in: endpoints [ 
	^ endpoints processDigests: digestList forMessage: self 
]

{ #category : #'as yet unclassified' }
GossipAck2Message >> processIn: aGossiper [
	aGossiper endpoints processAck2Message: self
]

{ #category : #'as yet unclassified' }
GossipAck2Message >> updateEndpoint: endpoint with: stateDelta [ 
	delta at: endpoint put: stateDelta 
]
