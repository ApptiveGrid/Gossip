"
What a gossiper tells the others about itself, when that is not what its own socket sees.

Behind a port mapping the two come apart: the container binds one number, the host maps another one to it, and only the mapped one is reachable from outside. Gossip answers to the endpoint a message declares rather than to the socket it arrived from, so the published one is the one that has to be right - the same reason GossipServer>>address exists, one field further along.

No sockets here. Nothing is started; what is looked at is what the server says it is.
"
Class {
	#name : 'GossipPublishedEndpointTest',
	#superclass : 'TestCase',
	#instVars : [
		'gossiper'
	],
	#category : 'Gossip-Tests',
	#package : 'Gossip-Tests'
}

{ #category : 'running' }
GossipPublishedEndpointTest >> setUp [
	super setUp.
	gossiper := Gossiper new
		            address: #[ 127 0 0 1 ];
		            port: 1999;
		            yourself
]

{ #category : 'tests' }
GossipPublishedEndpointTest >> testASeedListMayNameTheImageByItsPublishedEndpoint [
	"Why this matters beyond being told the truth: a deployment hands every image
	the same seed list, and an image has to recognise its own entry in it. It only
	does when the entry and the local endpoint agree, which behind a mapping means
	the published port on both sides."

	| mine |
	gossiper publishedPort: 3601.
	mine := GossipEndpoint address: #[ 127 0 0 1 ] port: 3601.
	gossiper
		seedNodes: {
				mine.
				(GossipEndpoint address: #[ 127 0 0 2 ] port: 3700) }.
	gossiper localEndpointState.
	self assert: gossiper localEndpoint equals: mine.
	self deny: (gossiper randomNodes includes: mine)
]

{ #category : 'tests' }
GossipPublishedEndpointTest >> testTheBoundPortIsUntouchedByPublishing [
	"The socket keeps binding what it was told to bind."

	gossiper publishedPort: 3601.
	self assert: gossiper server port equals: 1999
]

{ #category : 'tests' }
GossipPublishedEndpointTest >> testWhatIsPublishedIsWhatTheEndpointSays [

	gossiper publishedPort: 3601.
	self assert: gossiper localEndpoint port equals: 3601.
	self assert: gossiper localEndpoint address equals: #[ 127 0 0 1 ]
]

{ #category : 'tests' }
GossipPublishedEndpointTest >> testWithoutAMappingItPublishesThePortItBinds [
	"Every deployment that has nothing in between, and every test: the two are the
	same number and nobody has to say so."

	self assert: gossiper server publishedPort equals: 1999.
	self assert: gossiper localEndpoint port equals: 1999
]
