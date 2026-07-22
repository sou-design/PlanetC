initialization
broadcastPhase
	server broadcast: (Dictionary new
		at: 'type' put: 'phase';
		at: 'round' put: self cormasModel currentRound;
		at: 'phase' put: self cormasModel currentPhase;
		yourself)