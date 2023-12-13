Class {
	#name : #GossipEndpoint,
	#superclass : #Object,
	#instVars : [
		'address',
		'port'
	],
	#category : #Gossip
}

{ #category : #'as yet unclassified' }
GossipEndpoint class >> address: address port: port [
	^ self new 
		address: address;
		port: port
]

{ #category : #examples }
GossipEndpoint class >> example1 [ 
	<script> 
	^ self new 
		address: #[ 1 2 3 4];
		port: 1234
]

{ #category : #examples }
GossipEndpoint class >> example2 [
	<script> 
	^ self new 
		address: #[ 4 3 2 1 ];
		port: 4321
]

{ #category : #'instance creation' }
GossipEndpoint class >> fromUDP: result [ 
	^ self new 
		address: result second;
		port: result third
]

{ #category : #services }
GossipEndpoint class >> me [
	^ self new 
		address: #[ 0 0 0 0 ];
		port: 0
]

{ #category : #comparing }
GossipEndpoint >> = anEndpoint [ 
	^ (anEndpoint address = address) and: [ 
		anEndpoint port = port ] 
]

{ #category : #accessing }
GossipEndpoint >> address [

	^ address
]

{ #category : #accessing }
GossipEndpoint >> address: anObject [

	address := anObject
]

{ #category : #comparing }
GossipEndpoint >> hash [
	^ address hash bitXor: port hash
]

{ #category : #accessing }
GossipEndpoint >> port [

	^ port
]

{ #category : #accessing }
GossipEndpoint >> port: anObject [

	port := anObject
]

{ #category : #printing }
GossipEndpoint >> printOn: aStream [ 
	aStream << ($. join: (address collect: #asString as: Array)) << ':' << port printString
]
