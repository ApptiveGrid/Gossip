Class {
	#name : #TestGossiper,
	#superclass : #Gossiper,
	#instVars : [
		'receivedMessages',
		'sentMessages'
	],
	#category : #'Gossip-Tests'
}

{ #category : #'as yet unclassified' }
TestGossiper >> hasReceivedMessages [
	^ receivedMessages notEmpty 
]

{ #category : #initialization }
TestGossiper >> initialize [ 
	super initialize.
	receivedMessages := OrderedCollection new.
	sentMessages := OrderedCollection new
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

{ #category : #'utilities - objectiveC' }
TestGossiper >> sendMessage: message toAdress: address  port: port [ 
	sentMessages add: message
]

{ #category : #accessing }
TestGossiper >> sentMessages [
	^ sentMessages 
]
