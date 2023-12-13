Class {
	#name : #BaselineOfGossip,
	#superclass : #BaselineOf,
	#category : #BaselineOfGossip
}

{ #category : #baselines }
BaselineOfGossip >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec
				package: 'Gossip' with: [ ];
				package: 'Gossip-Tests' with: [ spec requires: #('Gossip') ].

			spec
				group: 'default' with: #('Core');
				group: 'Core' with: #('Gossip' 'Gossip-Tests') ].
]
