Class {
	#name : 'BaselineOfGossip',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGossip',
	#package : 'BaselineOfGossip'
}

{ #category : 'baselines' }
BaselineOfGossip >> baseline: spec [
	<baseline>
	self pharodevs: spec.
	spec
		for: #common
		do: [ 
			spec
				package: 'Gossip' with: [ ];
				package: 'Gossip-Tests' with: [ spec requires: #('Gossip') ];
				package: 'Gossip-Simulation-Tests' with: [ spec requires: #('Gossip' 'PharoDEVS') ].

			spec
				group: 'default' with: #('Core');
				group: 'Core' with: #('Gossip' 'Gossip-Tests') ].
]

{ #category : 'as yet unclassified' }
BaselineOfGossip >> pharodevs: spec [

	spec
		baseline: 'PharoDEVS' with: [ 
			spec 
				repository: 'github://ApptiveGrid/PharoDEVS/source']
]
