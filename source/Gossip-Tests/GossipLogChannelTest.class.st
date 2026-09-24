"
That the lines gossip writes go onto Beacon and not onto the Transcript.

Two things are worth holding still here. The signal carries the whole line including the endpoint that spoke, because a listener cannot work that out for itself - several gossipers can run in one image. And GossipSignal sits under StringSignal, so a logger started for StringSignal picks gossip up along with everything else, while one started for GossipSignal hears gossip alone.

The logger is Gossip-Tests' own rather than Beacon's MemoryLogger, because what that one answers was renamed between Pharo 12 and 13 - see GossipCollectingLogger.

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
GossipLogChannelTest >> aLine [
	^ GossipSignal new
		  message: '10.10.0.6:3601: new endpoint 10.10.0.7:3601';
		  yourself
]

{ #category : 'running' }
GossipLogChannelTest >> setUp [
	super setUp.
	gossiper := Gossiper new
		            address: #[ 127 0 0 1 ];
		            port: 9001;
		            yourself
]

{ #category : 'running' }
GossipLogChannelTest >> withTimestamp: aBoolean do: aBlock [
	"Class-side state in an image several tests share, so it goes back where it was
	whatever the block does."

	| before |
	before := GossipSignal printsTimestamp.
	GossipSignal printsTimestamp: aBoolean.
	[ aBlock value ] ensure: [ GossipSignal printsTimestamp: before ]
]

{ #category : 'tests' }
GossipLogChannelTest >> testALoggerForStringSignalHearsGossipToo [
	"Where the gain is. An image does not have to know that Gossip exists to see its
	lines - registering the general kind is enough, which is what the servers do."

	| logger |
	logger := GossipCollectingLogger new.
	logger runFor: StringSignal during: [ gossiper log: 'anything' ].
	self assert: logger signals size equals: 1
]

{ #category : 'tests' }
GossipLogChannelTest >> testALogLineBecomesASignal [
	"Not a write to the Transcript. Whoever wants these lines says so by
	registering a logger; Gossip does not decide where they end up."

	| logger |
	logger := GossipCollectingLogger new.
	logger runFor: GossipSignal during: [ gossiper log: 'something happened' ].
	self assert: logger signals size equals: 1.
	self assert:
		(logger signals first message includesSubstring: 'something happened')
]

{ #category : 'tests' }
GossipLogChannelTest >> testTheLineNamesWhoSpoke [
	"A listener cannot know which gossiper spoke, and in one image there can be
	several - so the line says it."

	| logger |
	logger := GossipCollectingLogger new.
	logger runFor: GossipSignal during: [ gossiper log: 'something happened' ].
	self assert: (logger signals first message beginsWith:
			 gossiper localEndpoint asString , ': ')
]

{ #category : 'tests' }
GossipLogChannelTest >> testTheTimestampCanBeLeftToTheLog [
	"Where the line ends up in a log that stamps its own time - a container behind
	docker's syslog driver, whose lines already carry date, host and container - a
	second date in the middle is noise. The switch takes it out; the class name
	stays, because it says which kind of signal spoke."

	self
		withTimestamp: false
		do: [
			self
				assert: self aLine printString
				equals: 'GossipSignal 10.10.0.6:3601: new endpoint 10.10.0.7:3601' ]
]

{ #category : 'tests' }
GossipLogChannelTest >> testTheTimestampIsThereUnlessAsked [
	"Beacon's own behaviour is what an image gets for doing nothing. Whoever wants
	it gone says so."

	self
		withTimestamp: true
		do: [ | line |
			line := self aLine.
			self assert: (line printString beginsWith: line timestamp asString) ]
]

{ #category : 'tests' }
GossipLogChannelTest >> testTheValueIsRestoredAfterwards [
	"The switch is class-side state in a shared image, so a test that moves it and
	leaves it moved poisons whatever runs next. This one asserts the setUp/tearDown
	pair actually puts it back."

	| before |
	before := GossipSignal printsTimestamp.
	self withTimestamp: before not do: [ ].
	self assert: GossipSignal printsTimestamp equals: before
]
