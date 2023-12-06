Class {
	#name : #TestGossiper,
	#superclass : #Gossiper,
	#instVars : [
		'receivedMessages'
	],
	#category : #Gossip
}

{ #category : #'as yet unclassified' }
TestGossiper >> hasReceivedMessages [
	^ receivedMessages notEmpty 
]

{ #category : #initialization }
TestGossiper >> initialize [ 
	super initialize.
	receivedMessages := OrderedCollection new
]

{ #category : #'as yet unclassified' }
TestGossiper >> received: aMessage from: endpoint [
	super received: aMessage from: endpoint.
	receivedMessages add: (endpoint -> aMessage)
]

{ #category : #'as yet unclassified' }
TestGossiper >> receivedMessages [
	^ receivedMessages 
]
