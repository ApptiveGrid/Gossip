"
That a copy of somebody else's state says how far it has actually come.

The counter of a `GossipEndpointState` has two jobs, and only the first was ever exercised: for the endpoint's own image it hands out version numbers, for every other image holding a copy it is what the digest reports. The second job was never done - applying a delta wrote the content and left the counter where it stood - so the copy told the next asker that nothing newer existed, and the delta was never requested.

Nothing here talks: deltas are built by hand and applied, which is exactly what an arriving message does one layer up.
"
Class {
	#name : 'GossipRelayedVersionTest',
	#superclass : 'TestCase',
	#instVars : [
		'endpoint',
		'state'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipRelayedVersionTest >> deltaWithHeartbeat: anInteger [
	"What a neighbour sends about a third party: its heartbeat and nothing else."

	^ GossipEndpointStateDelta new
		  heartbeatState: (GossipHeartbeatState new
				   generation: 7;
				   version: anInteger;
				   yourself);
		  yourself
]

{ #category : 'running' }
GossipRelayedVersionTest >> setUp [
	super setUp.
	endpoint := GossipEndpoint address: #[ 10 10 0 7 ] port: 1999.
	state := GossipEndpointState new
		         endpoint: endpoint;
		         generation: 7;
		         yourself
]

{ #category : 'tests' }
GossipRelayedVersionTest >> testAnApplicationStateCountsToo [
	"Both kinds are numbered from one counter, so a value that arrived later than
	the heartbeat is what the copy has to report."

	| delta |
	delta := self deltaWithHeartbeat: 30.
	delta applicationStates at: 'service.apptive-base' put: (GossipApplicationState new
			 maxVersion: 41;
			 value: '10.10.0.6:3601';
			 yourself).
	delta applyChangesTo: state.
	self assert: state maxVersion equals: 41
]

{ #category : 'tests' }
GossipRelayedVersionTest >> testAnOlderDeltaDoesNotUndoANewerOne [
	"Deltas arrive out of order. Lowering the counter would ask for state that is
	already held, and worse, would hide state that is not."

	(self deltaWithHeartbeat: 30) applyChangesTo: state.
	(self deltaWithHeartbeat: 12) applyChangesTo: state.
	self assert: state maxVersion equals: 30
]

{ #category : 'tests' }
GossipRelayedVersionTest >> testTheCopyReportsWhatItHolds [
	"The heartbeat arrives at 30, so that is what this image knows of the endpoint -
	and what its digest has to say. Before this, the counter stood at 1."

	(self deltaWithHeartbeat: 30) applyChangesTo: state.
	self assert: state heartbeatState version equals: 30.
	self assert: state maxVersion equals: 30
]

{ #category : 'tests' }
GossipRelayedVersionTest >> testTheDigestCarriesIt [
	"The consequence, one layer up and where it was felt: what this image publishes
	about a third party it only ever heard of through somebody else. A digest saying
	1 while the endpoint is at 30 means no asker ever requests the difference - which
	is why a relayed heartbeat used to arrive exactly once."

	| endpoints copy digest |
	endpoints := GossipEndpoints new.
	copy := (endpoints newEndpointStateFor: endpoint)
		        generation: 7;
		        yourself.
	(self deltaWithHeartbeat: 30) applyChangesTo: copy.
	digest := endpoints digests detect: [ :each | each endpoint = endpoint ].
	self assert: digest version equals: 30
]
