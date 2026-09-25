"
Where a syn is answered: at the sender it names, or - when it names none - where it came from.

No sockets: the gossiper keeps how it would answer. That the answer also leaves from the socket the question arrived at is GossipAnswerFromTheListeningSocketTest, and that it finds its way back through a translating gateway is GossipObserverBehindNatDevsTest.
"
Class {
	#name : 'GossipAnswerToSourceTest',
	#superclass : 'TestCase',
	#instVars : [
		'node',
		'named',
		'source'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipAnswerToSourceTest >> setUp [

	super setUp.
	node := GossipAnsweringGossiper new
		        address: #[ 127 0 0 1 ];
		        port: 9001;
		        yourself.
	node localEndpointState.
	named := GossipEndpoint address: #[ 10 11 0 2 ] port: 19999.
	source := GossipEndpoint address: #[ 10 10 0 4 ] port: 40123
]

{ #category : 'tests' }
GossipAnswerToSourceTest >> testASynNamingItsSenderIsAnsweredThere [
	"what a member does, unchanged: behind a port mapping the source is not an
	address that can be answered"

	node
		receivedMessage: (GossipSynMessage new
				 sender: named;
				 digests: #(  );
				 yourself)
		from: source.
	self assert: node answers asArray equals: { #send -> named }
]

{ #category : 'tests' }
GossipAnswerToSourceTest >> testASynNamingNobodyIsAnsweredWhereItCameFrom [

	node
		receivedMessage: (GossipSynMessage new
				 digests: #(  );
				 yourself)
		from: source.
	self assert: node answers asArray equals: { #reply -> source }
]

{ #category : 'tests' }
GossipAnswerToSourceTest >> testAnsweringTheSourceTeachesTheNodeNothing [
	"the node still does not learn who asked: there is no sender, and no state
	about it in the syn"

	node
		receivedMessage: (GossipSynMessage new
				 digests: #(  );
				 yourself)
		from: source.
	self assert: node endpoints keys asArray equals: { node localEndpoint }
]
