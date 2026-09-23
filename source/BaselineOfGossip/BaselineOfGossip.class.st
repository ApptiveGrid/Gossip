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
				group: 'default' with: #('Core' 'Simulation');
				"What an image takes that only has to speak the protocol. Every other
				group here carries tests: Core brings Gossip-Tests, and default brings
				Simulation on top, which requires PharoDEVS - so a deployed image asking
				for any of them would get a simulator with it."
				group: 'Runtime' with: #('Gossip');
				group: 'Core' with: #('Gossip' 'Gossip-Tests');
				group: 'Simulation' with: #('Gossip-Simulation-Tests') ].
]

{ #category : 'as yet unclassified' }
BaselineOfGossip >> pharodevs: spec [

	spec
		baseline: 'PharoDEVS' with: [ 
			spec 
				repository: 'github://soil-fabric/PharoDEVS:main/source']
]
