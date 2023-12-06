Class {
	#name : #Endpoint,
	#superclass : #Object,
	#instVars : [
		'address',
		'port'
	],
	#category : #Gossip
}

{ #category : #'instance creation' }
Endpoint class >> fromUDP: result [ 
	^ self new 
		address: result second;
		port: result third
]

{ #category : #comparing }
Endpoint >> = anEndpoint [ 
	^ (anEndpoint address = address) and: [ 
		anEndpoint port = port ] 
]

{ #category : #accessing }
Endpoint >> address [

	^ address
]

{ #category : #accessing }
Endpoint >> address: anObject [

	address := anObject
]

{ #category : #comparing }
Endpoint >> hash [
	^ address hash bitXor: port hash
]

{ #category : #accessing }
Endpoint >> port [

	^ port
]

{ #category : #accessing }
Endpoint >> port: anObject [

	port := anObject
]

{ #category : #printing }
Endpoint >> printOn: aStream [ 
	aStream << ($. join: (address collect: #asString as: Array)) << ':' << port printString
]
