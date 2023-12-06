Class {
	#name : #GossipEndpoint,
	#superclass : #Object,
	#instVars : [
		'address',
		'port'
	],
	#category : #Gossip
}

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
