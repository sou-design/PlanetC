initialization
broadcastRound
	server broadcast: (Dictionary new
		at: 'type' put: 'round';
		at: 'round' put: self cormasModel currentRound;
		yourself)