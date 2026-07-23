Class {
	#name : 'GossipListValueTest',
	#superclass : 'TestCase',
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'as yet unclassified' }
GossipListValueTest >> testAddMakesItemPresent [
	| lv |
	lv := GossipListValue new.
	lv add: #a.
	self assert: (lv includes: #a).
	self assert: lv presentItems asArray equals: #(#a)
]

{ #category : 'as yet unclassified' }
GossipListValueTest >> testGcTombstonesOlderThanKeepsRecentTombstones [
	| lv |
	lv := GossipListValue new.
	lv add: #a.
	lv remove: #a.
	lv add: #b.
	lv gcTombstonesOlderThan: 5.
	self assert: (lv entries includesKey: #a)
]

{ #category : 'as yet unclassified' }
GossipListValueTest >> testGcTombstonesOlderThanNeverRemovesPresentItems [
	| lv |
	lv := GossipListValue new.
	lv add: #a.
	lv add: #b.
	lv add: #c.
	lv gcTombstonesOlderThan: 0.
	self assert: (lv entries includesKey: #a).
	self assert: lv presentItems asSortedCollection asArray equals: #(#a #b #c)
]

{ #category : 'as yet unclassified' }
GossipListValueTest >> testGcTombstonesOlderThanRemovesOldTombstones [
	| lv |
	lv := GossipListValue new.
	lv add: #a.
	lv remove: #a.
	lv add: #b.
	lv add: #c.
	lv gcTombstonesOlderThan: 1.
	self deny: (lv entries includesKey: #a)
]

{ #category : 'as yet unclassified' }
GossipListValueTest >> testRemoveTombstonesRatherThanDeletes [
	| lv |
	lv := GossipListValue new.
	lv add: #a.
	lv remove: #a.
	self deny: (lv includes: #a).
	self assert: lv presentItems isEmpty.
	self assert: (lv entries includesKey: #a)
]
