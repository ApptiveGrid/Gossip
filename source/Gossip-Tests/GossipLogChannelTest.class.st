"
That the lines gossip writes go onto Beacon and not onto the Transcript.

Two things are worth holding still here. The signal carries the whole line including the endpoint that spoke, because a listener cannot work that out for itself - several gossipers can run in one image. And GossipSignal sits under StringSignal, so a logger started for StringSignal picks gossip up along with everything else, while one started for GossipSignal hears gossip alone.

The second point has teeth on the ApptiveGrid side: SignalLogger>>startFor: does not add a registration, it replaces the logger's subscriptions outright. Two calls in a row leave only the second one registered.
"
Class {
	#name : 'GossipLogChannelTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossiper'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipLogChannelTest >> setUp [
	super setUp.
	gossiper := Gossiper new
		            address: #[ 127 0 0 1 ];
		            port: 9001;
		            yourself
]

{ #category : 'tests' }
GossipLogChannelTest >> testALoggerForStringSignalHearsGossipToo [
	"Where the gain is. An image does not have to know that Gossip exists to see its
	lines - registering the general kind is enough, which is what the servers do."

	| logger |
	logger := MemoryLogger new.
	logger runFor: StringSignal during: [ gossiper log: 'anything' ].
	self assert: logger entries size equals: 1
]

{ #category : 'tests' }
GossipLogChannelTest >> testALogLineBecomesASignal [
	"Not a write to the Transcript. Whoever wants these lines says so by
	registering a logger; Gossip does not decide where they end up."

	| logger |
	logger := MemoryLogger new.
	logger runFor: GossipSignal during: [ gossiper log: 'something happened' ].
	self assert: logger entries size equals: 1.
	self assert:
		(logger entries first message includesSubstring: 'something happened')
]

{ #category : 'tests' }
GossipLogChannelTest >> testTheLineNamesWhoSpoke [
	"A listener cannot know which gossiper spoke, and in one image there can be
	several - so the line says it."

	| logger |
	logger := MemoryLogger new.
	logger runFor: GossipSignal during: [ gossiper log: 'something happened' ].
	self assert: (logger entries first message beginsWith:
			 gossiper localEndpoint asString , ': ')
]
