"
Over real sockets on localhost: an observer asks from the socket it listens on, and the node answers from the socket it listens on.

The second half is what a translating gateway needs. It lets back only what comes from the address and port the question went to; an answer from the node's sending socket - a port of its own - is dropped there, even when it is sent to the right address. Localhost translates nothing, so the answer arrives either way; what is checked is the port it comes from.
"
Class {
	#name : 'GossipAnswerFromTheListeningSocketTest',
	#superclass : 'TestCase',
	#instVars : [
		'node',
		'observer'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipAnswerFromTheListeningSocketTest >> setUp [

	super setUp.
	node := Gossiper new
		        address: #[ 127 0 0 1 ];
		        port: 19811;
		        yourself.
	node stateAt: 'service.apptive-base' put: '10.10.0.6:3601'.
	observer := GossipListeningObserver new
		            address: #[ 127 0 0 1 ];
		            port: 19812;
		            seedNodes: { node localEndpoint };
		            yourself.
	node server run.
	observer server run
]

{ #category : 'running' }
GossipAnswerFromTheListeningSocketTest >> tearDown [

	observer stop.
	node stop.
	super tearDown
]

{ #category : 'tests' }
GossipAnswerFromTheListeningSocketTest >> testTheAnswerComesFromTheSocketTheQuestionWentTo [

	observer gossip.
	300 milliSeconds wait.
	self assert: (observer endpoints includesKey: node localEndpoint).
	self assert: observer sources notEmpty.
	self assert: (observer sources allSatisfy: [ :each | each port = 19811 ])
]
