"
What gossip says about itself, on Pharo's own signal channel instead of straight on the Transcript.

A StringSignal, so anything already listening for StringSignal hears it as well, while an image that wants only gossip can start a logger for this class alone. Beacon-Core is part of the base image, so this costs Gossip no dependency.

What gets said is deliberately rare - see GossipEndpoints for which events earn a line, and why a delta arriving is not one of them.
"
Class {
	#name : 'GossipSignal',
	#superclass : 'StringSignal',
	#category : 'Gossip',
	#package : 'Gossip'
}
