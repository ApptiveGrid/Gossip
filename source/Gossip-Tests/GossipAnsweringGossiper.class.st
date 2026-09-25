"
A gossiper that keeps how it would answer instead of answering: #sendMessage:to: for a sender a syn named, #reply:to: for where a syn came from.
"
Class {
	#name : 'GossipAnsweringGossiper',
	#superclass : 'Gossiper',
	#instVars : [
		'answers'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'accessing' }
GossipAnsweringGossiper >> answers [

	^ answers ifNil: [ answers := OrderedCollection new ]
]

{ #category : 'utilities - objectiveC' }
GossipAnsweringGossiper >> reply: aMessage to: anEndpoint [

	self answers add: #reply -> anEndpoint
]

{ #category : 'utilities - objectiveC' }
GossipAnsweringGossiper >> sendMessage: aMessage to: anEndpoint [

	self answers add: #send -> anEndpoint
]
