Class {
	#name : 'TestGossiper',
	#superclass : 'Gossiper',
	#instVars : [
		'receivedMessages',
		'sentMessages',
		'loggedLines'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'as yet unclassified' }
TestGossiper >> hasReceivedMessages [
	^ receivedMessages notEmpty 
]

{ #category : 'initialization' }
TestGossiper >> initialize [ 
	super initialize.
	receivedMessages := OrderedCollection new.
	sentMessages := OrderedCollection new.
	loggedLines := OrderedCollection new
]

{ #category : 'logging' }
TestGossiper >> log: aString [
	"Kept rather than written out. A test that wants to know what was said can read
	it here, and the ones that do not are spared the Transcript."

	loggedLines add: aString
]

{ #category : 'logging' }
TestGossiper >> loggedLines [
	^ loggedLines
]

{ #category : 'as yet unclassified' }
TestGossiper >> received: aMessage from: endpoint [
	receivedMessages add: (endpoint -> aMessage).
	super received: aMessage from: endpoint.

]

{ #category : 'as yet unclassified' }
TestGossiper >> receivedMessages [
	^ receivedMessages 
]

{ #category : 'utilities - objectiveC' }
TestGossiper >> sendMessage: message toAdress: address  port: port [ 
	sentMessages add: message.
	super sendMessage: message toAdress: address  port: port 
]

{ #category : 'accessing' }
TestGossiper >> sentMessages [
	^ sentMessages 
]
