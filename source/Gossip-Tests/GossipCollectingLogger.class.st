"
A signal logger that keeps what it is handed, so a test can look at it.

Beacon's own MemoryLogger would do the job, but not across Pharo versions: what it answers is #recordings up to Pharo 12 and #entries from Pharo 13, where #recordings is deprecated with a transformWith: rule - one that rewrites the calling method's source when it fires. Either name breaks or mutates one half of Gossip's build matrix. SignalLogger>>nextPut: and runFor:during: have not moved, so the tests stand on those instead.
"
Class {
	#name : 'GossipCollectingLogger',
	#superclass : 'SignalLogger',
	#instVars : [
		'signals'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'initialization' }
GossipCollectingLogger >> initialize [
	super initialize.
	signals := OrderedCollection new
]

{ #category : 'accessing' }
GossipCollectingLogger >> nextPut: aSignal [
	signals add: aSignal
]

{ #category : 'accessing' }
GossipCollectingLogger >> signals [
	^ signals
]
